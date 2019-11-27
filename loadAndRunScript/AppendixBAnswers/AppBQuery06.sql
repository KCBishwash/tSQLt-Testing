SELECT itemId, SUM(quantity) AS quantityOrdered FROM OrderLine AS ol 
	INNER JOIN [Order] AS o ON ol.orderId = o.id
	INNER JOIN Item AS i ON ol.itemId = i.id
WHERE o.orderBranch = 'TIM1' AND CAST(o.orderDate AS date) = '2019/09/16'
Order BY itemId
