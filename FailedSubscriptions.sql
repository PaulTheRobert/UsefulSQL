/*
	This is a query provided by Parikshith Gari for monitoring the status of subscriptions.

	[dbo].[DS_FailedSubscriptions] 
	created on: 01/11/2022
	created by: paul davis (based on Parikshit Gari's query)

	last modification:
		[x] - filtered subscriptions table (a) on a.InactiveFlags = 0 to remove any disabled subscriptions
		[x] - added filter to check last status for the words '%Failure%'or '%not valid%')			
				-- Catching two error types 
					--	1. Failure sending mail, 
					--	2. The subscription contains parameter values that are not valid.
*/

--CREATE PROCEDURE [dbo].[DS_FailedSubscriptions]


--AS
WITH
	[Sub_Parameters] AS
(
	SELECT 
	[SubscriptionID],
	[Parameters] = CONVERT(XML,a.[Parameters])
	FROM [PowerBI].[dbo].[Subscriptions] a
),
	[MySubscriptions] AS
(
	SELECT DISTINCT
	[SubscriptionID],
	[ParameterName] = QUOTENAME(p.value('(Name)[1]', 'NVARCHAR(MAX)')),
	[ParameterValue] = p.value('(Value)[1]', 'NVARCHAR(MAX)')
	FROM [Sub_Parameters] a
	CROSS APPLY [Parameters].nodes('/ParameterValues/ParameterValue') t(p)
),
	[SubscriptionsAnalysis] AS
(
	SELECT
	a.[SubscriptionID],
	a.[ParameterName],
	[ParameterValue] = 
	(SELECT
	STUFF(( 
	SELECT [ParameterValue] + ', ' as [text()]
	FROM [MySubscriptions]
	WHERE 
	[SubscriptionID] = a.[SubscriptionID]
	AND [ParameterName] = a.[ParameterName]
	FOR XML PATH('')
	),1, 0, '')
	+'')
	FROM [MySubscriptions] a
	GROUP BY a.[SubscriptionID],a.[ParameterName]
)
SELECT
	a.[SubscriptionID],
	c.[UserName] AS Owner, 
	b.[Name],
	b.[Path],
	a.[Locale], 
	a.[InactiveFlags], 
	d.[UserName] AS Modified_by, 
	a.[ModifiedDate], 
	a.[Description], 
	a.[LastStatus], 
	a.[EventType], 
	a.[LastRunTime], 
	a.[DeliveryExtension],
	a.[Version],
	e.[ParameterName],
	LEFT(e.[ParameterValue],LEN(e.[ParameterValue])-1) as [ParameterValue],
	SUBSTRING(b.PATH,2,LEN(b.PATH)-(CHARINDEX('/',REVERSE(b.PATH))+1)) AS ProjectName

FROM      [PowerBI].[dbo].[Subscriptions] AS a 
     JOIN [PowerBI].[dbo].[Catalog]       AS b ON a.[Report_OID]     = b.[ItemID]
LEFT JOIN [PowerBI].[dbo].[Users]         AS c ON a.[OwnerID]        = c.[UserID]
LEFT JOIN [PowerBI].[dbo].[Users]         AS d ON a.[ModifiedByID]   = d.[UserID]
LEFT JOIN [SubscriptionsAnalysis]         AS e ON a.[SubscriptionID] = e.[SubscriptionID]

WHERE
	a.InactiveFlags = 0	-- we don't want to monitor inaactive subscriptions
	AND (
		a.[LastStatus] LIKE('%Failure%')
		OR  a.[LastStatus] LIKE('%not valid%')			-- Catching two error types 
		)														--	1. Failure sending mail, 
																--	2. The subscription contains parameter values that are not valid.