-- Script to load Appendix B answers

-- Expected use:	Creating expected table for using in tSQL to compare with student query result using
--					EXEC tSQLt.AssertEqualsTable @expectedTableName, @actualTableName

-- Loops thotugh all the supplied files in a directory with a provided naming convention
-- as proof of concept.  May be implemented differently.
-- Answer table created probably belongs in a different class or as a temporary table
-- There is no error checking if file exists - needs to be done

-- The file where I am getting the model from
-- Edit for correct data, or create a stored procedure and pass as parameters

-- Student Queries 
Create or Alter procedure run_qureries @expectedPath NVARCHAR(255),@fileNameBase NVARCHAR(255),@fileEnding NVARCHAR(32), @expectedTableNameBase NVARCHAR(32)
As

DECLARE @numberQueries INT = 6; -- Must be between 1 and 99

-- Local variables required to create file names
DECLARE @i INT = 1;	-- Loop counter
DECLARE @queryNumber NVARCHAR(2);
DECLARE @expectedFileName NVARCHAR(255);
DECLARE @expectedTableName NVARCHAR(255);

-- Variables for storing SQL strings that wil get the data
-- The command that will load the file into an SQL command 
	DECLARE @loadSQLFromFileCommand NVARCHAR(255);
-- The SQL that will be run
	DECLARE @sqlToRun NVARCHAR(MAX);
-- SQL for deleting table where output will be stored
	DECLARE @tableDDLCommand NVARCHAR(255);

-- Program
-- Loop through the answers
WHILE @i <= @numberQueries
BEGIN
	-- Get teh query number
	IF (@i < 10) 
		SET @queryNumber = N'0';
	ELSE
		SET @queryNumber = N'';
	SET @queryNumber = @queryNumber + CAST(@i AS NVARCHAR(2));
	
	-- Filename and tablename for model answer
	SET @expectedFileName =  @expectedPath + @fileNameBase + @queryNumber + @fileEnding;
	SET @expectedTableName = @expectedTableNameBase + @queryNumber;
	
	PRINT 'Testing: ' + @expectedTableName

	-- Dynamic SQL to get the contents of the file
	SET @loadSQLFromFileCommand = N'SELECT @sqlFromFile=BulkColumn FROM OPENROWSET(BULK ''' + @expectedFileName + ''',SINGLE_CLOB) ROW_SET';

	-- Get teh file containg the SQL into a variable that can be run
	-- Note the sqlFromFile variable had to be declared
	EXEC sp_executesql @loadSQLFromFileCommand, N'@sqlFromFile NVARCHAR(MAX) OUTPUT', @sqlFromFile=@sqlToRun OUTPUT;

-- Debug code to check correct query coming from file
-- PRINT @sqlToRun -- debug code
-- EXEC sp_executesql @sqltorun;

	-- Create a table for teh output answers to be stored
	SET @tableDDLCommand = N'IF OBJECT_ID(''' + @expectedTableName + ''') IS NOT NULL DROP TABLE ' + @expectedTableName;
	EXEC sp_executesql @tableDDLCommand;

	-- Adjust the query to run so that the results go into a table
	SET @sqlToRun = 'SELECT * INTO ' + @expectedTableName + ' FROM (' + @sqlToRun + ') AS ' + @expectedTableName;
	EXEC sp_executesql @sqlToRun;

	-- Increment loop counter
	SET @i = @i + 1;
END;