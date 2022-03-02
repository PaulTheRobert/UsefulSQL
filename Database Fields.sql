SELECT 
     TBL.[name] AS [TableName]
	,COL.name AS [Column Name]
    ,TYP.Name 'Data type'
    ,COL.max_length 'Max Length'
    ,COL.precision
    ,COL.scale
    ,COL.is_nullable
    ,ISNULL(i.is_primary_key, 0) 'Primary Key'
FROM 
	
	sys.tables TBL 
	
    LEFT JOIN sys.columns COL ON TBL.object_id = COL.object_id

	INNER JOIN 
		sys.types TYP ON COL.user_type_id = TYP.user_type_id

	LEFT OUTER JOIN 
		sys.index_columns IC ON IC.object_id = COL.object_id AND IC.column_id = COL.column_id

	LEFT OUTER JOIN 
		sys.indexes I ON IC.object_id = I.object_id AND IC.index_id = I.index_id
