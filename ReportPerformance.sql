SELECT
	CAT.[Name]
	,CAT.[Path]
	-- Count
	--,COUNT(EL.[ReportID]) AS [countRun]
	,EL.[Status]
	,SUM(COUNT(EL.[ExecutionId]))OVER(PARTITION BY CAT.[Path], EL.[Status]) AS [countStatus]
	-- AVG
	,AVG(EL.[TimeDataRetrieval]/1000) AS [AvgTimeDataRetrieval(s)]
	,AVG(EL.[TimeProcessing]/1000) AS [AvgTimeProcessing(s)]
	,AVG(EL.[TimeRendering]/1000) AS [AvgTimeRendering(s)]
	,AVG(EL.[RowCount]) AS [AvgRowCount]
	-- MAX
	,MAX(EL.[TimeDataRetrieval]/1000) AS [MaxTimeDataRetrieval(s)]
	,MAX(EL.[TimeProcessing]/1000) AS [MaxTimeProcessing(s)]
	,MAX(EL.[TimeRendering]/1000) AS [MaxTimeRendering(s)]
	,MAX(EL.[RowCount]) AS [MaxRowCount]
	-- MIN
	,MIN(EL.[TimeDataRetrieval]/1000) AS [MinTimeDataRetrieval(s)]
	,MIN(EL.[TimeProcessing]/1000) AS [MinTimeProcessing(s)]
	,MIN(EL.[TimeRendering]/1000) AS [MinTimeRendering(s)]
	,MIN(EL.[RowCount]) AS [MinRowCount]

FROM
	
	dbo.[Catalog] CAT

	LEFT JOIN dbo.[ExecutionLog3] EL ON
		CAT.[Path] = EL.[ItemPath]
WHERE
	CAT.[type] = 2
	AND
	(
		--(	EL.[TimeStart] >= @StartDate
		--	AND EL.[TimeStart] <= @EndDate
		--)
	--OR
		(
			EL.[TimeStart] IS NULL
		)
	)
GROUP BY
	 CAT.[Name]
	,CAT.[Path]
	,EL.[Status]
	
ORDER BY
	CAT.[Path]
	--AVG(EL.[TimeDataRetrieval]) DESC
	--,AVG(EL.[TimeProcessing]) DESC
	--,AVG(EL.[TimeRendering]) DESC