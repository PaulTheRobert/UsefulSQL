
/*
*	Tables
*/

USE DCIDSPRODUCTION_REPLICATED
SELECT
	*
FROM
	(
	SELECT 
		T.[schema_id]
		,t.[name]
		,SUM(P.[rows]) as [RowCount]

	FROM
		--INFORMATION_SCHEMA.TABLES T
		sys.tables T

		JOIN sys.partitions P
		
		
			
		ON
			T.[object_id]=P.[object_id]
			AND
			P.index_id IN (0,1)
	GROUP BY
			T.[schema_id]
			,t.[name]
	) AS T1

WHERE
	T1.[RowCount]>0

ORDER BY T1.[RowCount] DESC