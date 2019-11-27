DECLARE @expectedPath NVARCHAR(255) = N'C:\Users\ashis\OneDrive\Desktop\Project Final\loadAndRunScript\AppendixBAnswers\';
DECLARE @fileNameBase NVARCHAR(32) = N'AppBQuery';
DECLARE @fileEnding NVARCHAR(32) = N'.sql';
DECLARE @fileEndingActual NVARCHAR(32) = N'Model.sql';
DECLARE @expectedTableNameBase NVARCHAR(32) = N'tblExpected';

EXEC run_qureries @expectedPath,@fileNameBase,@fileEnding,@expectedTableNameBase;

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
	-- Get data for model table.
	SET @expectedFileName =  @expectedPath + @fileNameBase + @queryNumber + @fileEnding;
	SET @expectedTableName = 'tblActual';
	
	-- Dynamic SQL to get the contents of the file
	SET @loadSQLFromFileCommand = N'SELECT @sqlFromFile=BulkColumn FROM OPENROWSET(BULK ''' + @expectedFileName + ''',SINGLE_CLOB) ROW_SET';

	-- Get the file containg the SQL into a variable that can be run
	-- Note the sqlFromFile variable had to be declared
	EXEC sp_executesql @loadSQLFromFileCommand, N'@sqlFromFile NVARCHAR(MAX) OUTPUT', @sqlFromFile=@sqlToRun OUTPUT;

	-- Create a table for teh output answers to be stored
	SET @tableDDLCommand = N'IF OBJECT_ID(''' + @expectedTableName + ''') IS NOT NULL DROP TABLE ' + @expectedTableName;
	EXEC sp_executesql @tableDDLCommand;

	-- Adjust the query to run so that the results go into a table
	SET @sqlToRun = 'SELECT * INTO ' + @expectedTableName + ' FROM (' + @sqlToRun + ') AS ' + @expectedTableName;
	EXEC sp_executesql @sqlToRun;

BEGIN TRY
EXEC tSQLt.[AssertEqualsTableSchema] @expectedTableName, 'tblActual';
Print ('Test Case Passed : Both Query has same schema')
END TRY
BEGIN CATCH
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
 
 IF @ErrorNumber=207
   BEGIN
	set @ErrorMessage='Schema is different'  + @ErrorMessage; 
	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END
  END CATCH

BEGIN TRY
EXEC tSQLt.AssertEqualsTable @expectedTableName, 'tblActual';
Print ('Test Case Passed : Both Query results are equal')
END TRY
BEGIN CATCH
    DECLARE @ErrorNumber1 INT = ERROR_NUMBER();
    DECLARE @ErrorLine1 INT = ERROR_LINE();
    DECLARE @ErrorMessage1 NVARCHAR(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity1 INT = ERROR_SEVERITY();
    DECLARE @ErrorState1 INT = ERROR_STATE();
 
 IF @ErrorNumber=207
   BEGIN
   set @ErrorMessage1='Metadata not matched or column not matched : '  +@ErrorMessage1; 
   RAISERROR(@ErrorMessage1 , @ErrorSeverity1, @ErrorState1);
   END
 else
	begin
	set @ErrorMessage1= @ErrorMessage1 + ': '+'Number of Rows are different'; 
	RAISERROR(@ErrorMessage1, @ErrorSeverity1, @ErrorState1);
	END
  END CATCH