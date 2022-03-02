DECLARE @String NVARCHAR(MAX)


SET @String = ' #NRH.'

SELECT
	Number,
	[Character] = SUBSTRING(@String,Number,1),
	[ASCII] = ASCII(SUBSTRING(@String,Number,1))


FROM
	(
	SELECT
		ROW_NUMBER() OVER (ORDER BY [object_id])
	FROM 
		sys.all_objects
	) AS n (Number)
WHERE
	Number > 0
	AND Number <= LEN(@String)