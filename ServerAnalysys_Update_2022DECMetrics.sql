--- RUN THIS SCRPT ON EACH OF THE FOLLOWING DATABASES
--USE [ServerAnalysis];
--USE [ServerAnalysisDW];
--USE [ServerAnalysisDwStaging];

GO

/*
	THIS UPDATE CONTAINS

	1. New definitions to capture actual BIGINT at time of pole, allowing to pull a SIGNAL WAIT stat for the current time interval.
			448 - OS Wait Stats: wait_time_ms_tot
			449 - OS Wait Stats: signal_wait_time_ms_tot
	2. Bug fix on the SPROC (used by SASRS and PowerBI) to capture Database metics for the dashboard at the database level
			The calculation for database growth was fixed and evaluates now only data within the past 30 days.
	3. New views for the above WAIT stats. New views to pull real time intraval for latency.
	4. UPDATE to two reporting overview SPROCs to use the new views for SIGNAL WAITs and LATENCY.

*/



---------  ServerAnalysis  --------------------------------------------------------------------

use ServerAnalysis;
-- 448 - OS Wait Stats: wait_time_ms_tot
UPDATE [Analysis].[PerfCounterMetric] SET [MetricName]='OS Wait Stats: wait_time_ms_tot', [MetricDurationDesc]='cur', 
[MetricIntervalMinutes]=1, MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName,UtcDate)    
SELECT s.PerfLocationID, 448, [REPLACEiDate], ''[REPLACEvTime]'', SUM(wait_time_ms), NULL, '''', getutcdate()  
FROM ServerAnalysis.Analysis.Server AS s, sys.dm_os_wait_stats AS w  
WHERE s.ServerNm = ''[REPLACEserver]''  
GROUP BY s.PerfLocationID OPTION (RECOMPILE);'
WHERE [MetricID]=448;

-- 449 OS Wait Stats: signal_wait_time_ms_tot
UPDATE [Analysis].[PerfCounterMetric] SET [MetricName]='OS Wait Stats: signal_wait_time_ms_tot', [MetricDurationDesc]='cur', 
[MetricIntervalMinutes]=1, MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName,UtcDate)    
SELECT s.PerfLocationID, 449, [REPLACEiDate], ''[REPLACEvTime]'', SUM(signal_wait_time_ms), NULL, '''', getutcdate()  
FROM ServerAnalysis.Analysis.Server AS s, sys.dm_os_wait_stats AS w  
WHERE s.ServerNm = ''[REPLACEserver]''  
GROUP BY s.PerfLocationID OPTION (RECOMPILE);'
WHERE [MetricID]=449;

GO

---------  ServerAnalysisDwStaging --------------------------------------------------------------------

USE [ServerAnalysisDwStaging];

-- 448 - OS Wait Stats: wait_time_ms_tot
UPDATE [Analysis].[PerfCounterMetric] SET [MetricName]='OS Wait Stats: wait_time_ms_tot', [MetricDurationDesc]='cur', 
[MetricIntervalMinutes]=1, MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName,UtcDate)    
SELECT s.PerfLocationID, 448, [REPLACEiDate], ''[REPLACEvTime]'', SUM(wait_time_ms), NULL, '''', getutcdate()  
FROM ServerAnalysis.Analysis.Server AS s, sys.dm_os_wait_stats AS w  
WHERE s.ServerNm = ''[REPLACEserver]''  
GROUP BY s.PerfLocationID OPTION (RECOMPILE);'
WHERE [MetricID]=448;

-- 449 OS Wait Stats: signal_wait_time_ms_tot
UPDATE [Analysis].[PerfCounterMetric] SET [MetricName]='OS Wait Stats: signal_wait_time_ms_tot', [MetricDurationDesc]='cur', 
[MetricIntervalMinutes]=1, MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName,UtcDate)    
SELECT s.PerfLocationID, 449, [REPLACEiDate], ''[REPLACEvTime]'', SUM(signal_wait_time_ms), NULL, '''', getutcdate()  
FROM ServerAnalysis.Analysis.Server AS s, sys.dm_os_wait_stats AS w  
WHERE s.ServerNm = ''[REPLACEserver]''  
GROUP BY s.PerfLocationID OPTION (RECOMPILE);'
WHERE [MetricID]=449;

GO

---------  ServerAnalysisDW  --------------------------------------------------------------------


USE [ServerAnalysisDW];

-- 448 - OS Wait Stats: wait_time_ms_tot
UPDATE [Analysis].[PerfCounterMetric] SET [MetricName]='OS Wait Stats: wait_time_ms_tot', [MetricDurationDesc]='cur', 
[MetricIntervalMinutes]=1, MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName,UtcDate)    
SELECT s.PerfLocationID, 448, [REPLACEiDate], ''[REPLACEvTime]'', SUM(wait_time_ms), NULL, '''', getutcdate()  
FROM ServerAnalysis.Analysis.Server AS s, sys.dm_os_wait_stats AS w  
WHERE s.ServerNm = ''[REPLACEserver]''  
GROUP BY s.PerfLocationID OPTION (RECOMPILE);'
WHERE [MetricID]=448;

-- 449 OS Wait Stats: signal_wait_time_ms_tot
UPDATE [Analysis].[PerfCounterMetric] SET [MetricName]='OS Wait Stats: signal_wait_time_ms_tot', [MetricDurationDesc]='cur', 
[MetricIntervalMinutes]=1, MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName,UtcDate)    
SELECT s.PerfLocationID, 449, [REPLACEiDate], ''[REPLACEvTime]'', SUM(signal_wait_time_ms), NULL, '''', getutcdate()  
FROM ServerAnalysis.Analysis.Server AS s, sys.dm_os_wait_stats AS w  
WHERE s.ServerNm = ''[REPLACEserver]''  
GROUP BY s.PerfLocationID OPTION (RECOMPILE);'
WHERE [MetricID]=449;

GO



-- SPROC REVISION / BUG FIX
USE [ServerAnalysisDW]
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Database_Properties]    Script Date: 12/13/2022 1:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221026
-- Revision on: 20221215 - Bug fix for calculating Database Growth 
-- =============================================
CREATE OR ALTER PROCEDURE [Analysis].[PerfCounter_Rpt_Database_Properties]
@LocationID int,
@ClusterID int
AS
BEGIN
	
	/*

	DATABASE DATASET
	https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-ver16

	*/
	DECLARE @DateKey INT = CONVERT(VARCHAR(10), GETDATE(),112);
	DECLARE @dsTable AS TABLE (	ID int IDENTITY(1,1) not null, 
								DatabaseName varchar(150), 
								LagDatabaseName varchar(150),
								RowID int,
								MdfFileName varchar(150), 							
								MdfMBs varchar(24),
								LdfMBs varchar(24),
								IOpcnt varchar(8),
								Model varchar(12),  --  1 = FULL, 2 = BULK_LOGGED, 3 = SIMPLE
								SqlVersion varchar(8),  -- 70,80,90.100,110,20,130, 140, 150
								DbState varchar(20),  -- 0 = ONLINE, 1 = RESTORING, 2 = RECOVERING, 3 = RECOVERY_PENDING, 4 = SUSPECT, 5 = EMERGENC, 6 = OFFLINE, 7 = COPYING, 10 = OFFLINE_SECONDARY 
								LastBackup varchar(24),
								DailyGrowth int);
	DECLARE @dTable AS TABLE (ID int IDENTITY(1,1) not null, DatabaseName varchar(150),  MdfFileName varchar(150), MdfPath varchar(350), DbMBs varchar(24), Growth int);
	DECLARE @iTable AS TABLE (ID int IDENTITY(1,1) not null, DataVal varchar(100));
	;
	WITH cteServerSpecs AS (	SELECT  PartName As DataVal, MAX(iVal) AS DbMBs
								FROM Analysis.PerfCounterStats WITH(NOLOCK) 
								WHERE MetricID in (123) and DateKey = @DateKey
								and LocationID = @LocationID and ClusterID = @ClusterID
								GROUP BY PartName
							),
			cteGrowth AS	(	SELECT  PartName,
								( ( MAX(iVal) - MIN(iVal)) / ISNULL(DATEDIFF(day,CONVERT(date,Convert(varchar(28),MIN(DateKey))),CONVERT(date,Convert(varchar(28),MAX(DateKey)))),1)  ) Growth
								FROM Analysis.PerfCounterStats WITH(NOLOCK) 
								WHERE MetricID in (123)
								and LocationID = @LocationID and ClusterID = @ClusterID
								-- 202212: Added to restrict evaluation to past 30 days only.
								and DateKey > CONVERT(VARCHAR(10),DATEADD(month,-1,getdate()),112)
								GROUP BY PartName
							)
	INSERT INTO @dTable
	SELECT 
		  SUBSTRING(t.DataVal, 1, CHARINDEX(',', t.DataVal)-1) as DatabaseName
		, SUBSTRING(t.DataVal, CHARINDEX(',', t.DataVal)+1, CHARINDEX(',', t.DataVal, CHARINDEX(',', t.DataVal)+1)-CHARINDEX(',', t.DataVal)-1) as MdfFileName
		, SUBSTRING(t.DataVal, CHARINDEX(',', t.DataVal, CHARINDEX(',', t.DataVal)+1)+1,len(t.DataVal)) as MdfPath
		, t.DbMBs 
		, g.Growth
	FROM  cteServerSpecs t INNER JOIN cteGrowth g ON t.DataVal = g.PartName
	ORDER BY DataVal;

	INSERT INTO @dsTable (DatabaseName, LagDatabaseName, MdfFileName, MdfMBs, DailyGrowth)
	SELECT DatabaseName, LAG(DatabaseName,1) OVER ( ORDER BY DatabaseName, ID), MdfFileName, DbMBs, Growth
	FROM @dTable
	WHERE RIGHT(MdfPath,4) != '.ldf' 
	ORDER BY DatabaseName, MdfFileName;

	UPDATE @dsTable
	SET RowID = (Case when LagDatabaseName = DatabaseName then 0 else 1 end); 

	UPDATE ds
	SET ds.LdfMBs = d.DbMBs
	FROM @dsTable as ds
	INNER JOIN @dTable as d ON ds.DatabaseName = d.DatabaseName
	WHERE RIGHT(d.MdfPath,4) = '.ldf' and ds.RowId = 1;

	-- 127 IO PERCENT PER DATABASE
	UPDATE ds
	SET ds.IOpcnt = d.IOpct
	FROM @dsTable as ds
	INNER JOIN (	SELECT q.PartName as DatabaseName, q.dVal as IOpct
					FROM (	select PartName, TimeKey, dVal, ROW_NUMBER() OVER(PARTITION BY PartName ORDER BY TimeKey DESC) AS RowID
							from ServerAnalysisDW.Analysis.PerfCounterStats with(nolock) 
							where MetricID=127 and DateKey = @DateKey
							and LocationID = @LocationID and ClusterID = @ClusterID
							) q
					WHERE q.RowID = 1 ) as d ON ds.DatabaseName = d.DatabaseName
	WHERE ds.RowId = 1;

	-- 144 model: Model varchar(12),  --  1 = FULL, 2 = BULK_LOGGED, 3 = SIMPLE
	UPDATE ds
	SET ds.Model = d.Model
	FROM @dsTable as ds
	INNER JOIN (	SELECT q.PartName as DatabaseName, (CASE q.iVal WHEN 1 THEN 'FULL' WHEN 2 THEN 'BULK_LOGGED' ELSE 'SIMPLE' END) as Model
					FROM (	select PartName, TimeKey, iVal, ROW_NUMBER() OVER(PARTITION BY PartName ORDER BY TimeKey DESC) AS RowID
							from ServerAnalysisDW.Analysis.PerfCounterStats with(nolock) 
							where MetricID=144 and DateKey = @DateKey
							and LocationID = @LocationID and ClusterID = @ClusterID
							) q
					WHERE q.RowID = 1
					) as d ON ds.DatabaseName = d.DatabaseName
	WHERE ds.RowId = 1;

	-- 143 version:  70,80,90.100,110,20,130, 140, 150
	UPDATE ds
	SET ds.SqlVersion = d.SqlVersion
	FROM @dsTable as ds
	INNER JOIN (	SELECT q.PartName as DatabaseName, q.iVal as SqlVersion
					FROM (	select PartName, TimeKey, iVal, ROW_NUMBER() OVER(PARTITION BY PartName ORDER BY TimeKey DESC) AS RowID
							from ServerAnalysisDW.Analysis.PerfCounterStats with(nolock) 
							where MetricID=143 and DateKey = @DateKey
							and LocationID = @LocationID and ClusterID = @ClusterID
							) q
					WHERE q.RowID = 1 ) as d ON ds.DatabaseName = d.DatabaseName
	WHERE ds.RowId = 1;

	-- 145 state: 0 = ONLINE, 1 = RESTORING, 2 = RECOVERING, 3 = RECOVERY_PENDING, 4 = SUSPECT, 5 = EMERGENC, 6 = OFFLINE, 7 = COPYING, 10 = OFFLINE_SECONDARY 
	UPDATE ds
	SET ds.DbState = d.DbState
	FROM @dsTable as ds
	INNER JOIN (	SELECT	q.PartName as DatabaseName, 
							(CASE q.iVal	WHEN 0 THEN 'ONLINE' 
											WHEN 1 THEN 'RESTORING' 
											WHEN 2 THEN 'RECOVERING' 
											WHEN 3 THEN 'RECOVERY_PENDING' 
											WHEN 4 THEN 'SUSPECT' 
											WHEN 5 THEN 'EMERGENC' 
											WHEN 6 THEN 'OFFLINE' 
											WHEN 7 THEN 'COPYING' 
											WHEN 10 THEN 'OFFLINE_SECONDARY' 
											ELSE '' END) as DbState
					FROM (	select PartName, TimeKey, iVal, ROW_NUMBER() OVER(PARTITION BY PartName ORDER BY TimeKey DESC) AS RowID
							from ServerAnalysisDW.Analysis.PerfCounterStats with(nolock) 
							where MetricID=145 and DateKey = @DateKey
							and LocationID = @LocationID and ClusterID = @ClusterID
							) q
					WHERE q.RowID = 1 ) as d ON ds.DatabaseName = d.DatabaseName
	WHERE ds.RowId = 1;					

	-- 101 Last Backup
	UPDATE ds
	SET ds.LastBackup = d.LastBackup
	FROM @dsTable as ds
	INNER JOIN (	SELECT q.PartName as DatabaseName, (CASE q.iVal WHEN 1 THEN 'TODAY' ELSE 'EXPIRED' END) as LastBackup
					FROM (	select PartName, TimeKey, iVal, ROW_NUMBER() OVER(PARTITION BY PartName ORDER BY TimeKey DESC) AS RowID
							from ServerAnalysisDW.Analysis.PerfCounterStats with(nolock) 
							where MetricID=101 and DateKey = @DateKey
							and LocationID = @LocationID and ClusterID = @ClusterID
							) q
					WHERE q.RowID = 1 ) as d ON ds.DatabaseName = d.DatabaseName
	WHERE ds.RowId = 1;
 
	-- OUTPUT FINAL RESULTSET
	SELECT DatabaseName, MdfFileName, MdfMBs, LdfMBs, IOpcnt, Model, SqlVersion, DbState, LastBackup, DailyGrowth
	FROM @dsTable;

END


GO






USE [ServerAnalysisDW]
GO
/****** Object:  View [Analysis].[pcv_SignalWaits_ByIntraval]   Script Date: 12/15/2022 1:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221215
-- =============================================
CREATE OR ALTER VIEW [Analysis].[pcv_SignalWaits_ByIntraval]
AS


	-- Get SignalWait Use by 1 minute interval, evaluating only that minute
	-- MetricID 448 and 440 
	/* --	10 MIN INTRAVAL SAMPLE QUERY:
			select LocationID, CLusterID, DateKey, LEFT(TimeKey,3), (SUM(WaitSignal) / COUNT(WaitSignal) ) AS SignalWait
			from [Analysis].[pcv_SignalWaits_ByIntraval]
			where LocationID = 101874 and ClusterID = 701
			GROUP BY LocationID, CLusterID, DateKey, LEFT(TimeKey,3)
			ORDER BY LocationID, CLusterID, DateKey, LEFT(TimeKey,3);
	*/
 
	 SELECT	q.LocationID, q.ClusterID, q.DateKey, q.TimeKey,
			CAST(100.0 * q.SignalMs / q.WaitMs AS NUMERIC(20,2)) AS WaitSignal
	 FROM	(
			SELECT	w.LocationID, w.ClusterID, w.DateKey, w.TimeKey, w.iVal
					, (w.iVal) - (LAG(w.iVal,1) OVER ( ORDER BY w.LocationID, w.ClusterID, w.DateKey, w.TimeKey)) As WaitMs
					, (s.iVal) - ( LAG(s.iVal,1) OVER ( ORDER BY w.LocationID, w.ClusterID, w.DateKey, w.TimeKey)) As SignalMs
			FROM	Analysis.PerfCounterStats as w with(nolock)
			INNER JOIN Analysis.PerfCounterStats as s with(nolock) on w.LocationID = s.LocationID 
																					and w.ClusterID = s.ClusterID
																					and w.DateKey = s.DateKey
																					and w.TimeKey = s.TimeKey
																					and w.MetricID = 448
																					and s. MetricID = 449
		WHERE	w.UtcDate > CONVERT(VARCHAR(10), GETUTCDATE(),112) -- Look at only todays data
		) q
	WHERE (q.iVal is not null)  and (q.SignalMs is not null);
	

GO

USE [ServerAnalysisDW]
GO
/****** Object:  View [Analysis].[pcv_SignalWaits_ByIntraval_Latest]   Script Date: 12/15/2022 1:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221215
-- =============================================
CREATE OR ALTER VIEW [Analysis].[pcv_SignalWaits_ByIntraval_Latest]
AS

	-- Get SignalWait Use by 1 minute interval, evaluating only that minute
	-- MetricID 448 and 440 
	 SELECT	q.LocationID, q.ClusterID, q.DateKey, q.TimeKey,
			CAST(100.0 * q.SignalMs / q.WaitMs AS NUMERIC(20,2)) AS WaitSignal
	 FROM	(
			SELECT	w.LocationID, w.ClusterID, w.DateKey, w.TimeKey, w.iVal
					, (w.iVal) - (LAG(w.iVal,1) OVER ( ORDER BY w.LocationID, w.ClusterID, w.DateKey, w.TimeKey)) As WaitMs
					, (s.iVal) - ( LAG(s.iVal,1) OVER ( ORDER BY w.LocationID, w.ClusterID, w.DateKey, w.TimeKey)) As SignalMs
					, (ROW_NUMBER() OVER(PARTITION BY w.LocationID,w.ClusterID  ORDER BY w.DateKey DESC, w.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as w with(nolock)
			INNER JOIN Analysis.PerfCounterStats as s with(nolock) on w.LocationID = s.LocationID 
																					and w.ClusterID = s.ClusterID
																					and w.DateKey = s.DateKey
																					and w.TimeKey = s.TimeKey
																					and w.MetricID = 448
																					and s. MetricID = 449
		WHERE	w.UtcDate > CONVERT(VARCHAR(10), GETUTCDATE(),112) -- Look at only todays data
		) q
	WHERE (q.iVal is not null)  and (q.SignalMs is not null) and q.RowCt = 1;
	
GO


USE [ServerAnalysisDW]
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatency_Intraval_01]   Script Date: 12/15/2022 1:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221215
-- =============================================
CREATE OR ALTER VIEW [Analysis].[pcv_IoDiskLatency_Intraval_01]
AS

	-- Get Disk Latency Intraval by row
	-- MetricID 351=reads  356=writes  371=stall
	/*		--	10 MIN INTRAVAL SAMPLE QUERY:
			select LocationID, CLusterID, DateKey, LEFT(TimeKey,3), (SUM(LatencyMs) / COUNT(LatencyMs) ) AS LatencyMs
			from [Analysis].[pcv_IoDiskLatency_Intraval_01]
			where LocationID = 101874 and ClusterID = 701
			GROUP BY LocationID, CLusterID, DateKey, LEFT(TimeKey,3)
			ORDER BY LocationID, CLusterID, DateKey, LEFT(TimeKey,3);
	*/

	SELECT iq.LocationID, iq.ClusterID, iq.DateKey, iq.TimeKey, 
	CONVERT(INT,((CAST(iq.IntravalStall AS FLOAT) / (iq.IntravalReads + iq.IntravalWrites)   ))) AS LatencyMs
	FROM
			( -- Inner query to find difference between this row and previous row
			SELECT sq.LocationID, sq.ClusterID, sq.DateKey, sq.TimeKey 
			, (sq.Reads) - (LAG(sq.Reads,1) OVER ( ORDER BY LocationID, ClusterID, DateKey, TimeKey)) As IntravalReads
			, (sq.Writes) - (LAG(sq.Writes,1) OVER ( ORDER BY LocationID, ClusterID, DateKey, TimeKey)) As IntravalWrites
			, (sq.Stall) - (LAG(sq.Stall,1) OVER ( ORDER BY LocationID, ClusterID, DateKey, TimeKey)) As IntravalStall
			FROM 
						( -- Subquery to get totals for read,write,stall
						SELECT	r.LocationID, r.ClusterID, r.DateKey, r.TimeKey, SUM(r.iVal) AS Reads, SUM(w.iVal) AS Writes, SUM(s.iVal) AS Stall
						FROM	Analysis.PerfCounterStats as r with(nolock)
						INNER JOIN .Analysis.PerfCounterStats as w with(nolock) on  r.LocationID = w.LocationID 
																				and r.ClusterID = w.ClusterID
																				and r.DateKey = w.DateKey
																				and r.TimeKey = w.TimeKey
																				and r.MetricID = 351
																				and w. MetricID = 356
						INNER JOIN .Analysis.PerfCounterStats as s with(nolock) on  r.LocationID = s.LocationID 
																				and r.ClusterID = s.ClusterID
																				and r.DateKey = s.DateKey
																				and r.TimeKey = s.TimeKey
																				and r.MetricID = 351
																				and s. MetricID = 371
						where r.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112) -- Limit to today's data only.
			
						group by r.LocationID, r.ClusterID, r.DateKey, r.TimeKey			
						) sq
			) iq;

	 
GO





USE [ServerAnalysisDW]
GO
/****** Object:  View [Analysis][pcv_IoDiskLatency_Intraval_Latest]   Script Date: 12/15/2022 1:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221215
-- =============================================
CREATE OR ALTER    VIEW [Analysis].[pcv_IoDiskLatency_Intraval_Latest]
AS

	-- Get Disk Latency Intraval by row
	-- MetricID 351=reads  356=writes  371=stall

	SELECT iq.LocationID, iq.ClusterID, iq.DateKey, iq.TimeKey, 
	CONVERT(INT,((CAST(iq.IntravalStall AS FLOAT) / (iq.IntravalReads + iq.IntravalWrites)   ))) AS LatencyMs
	FROM
			( -- Inner query to find difference between this row and previous row
			SELECT sq.LocationID, sq.ClusterID, sq.DateKey, sq.TimeKey 
			, (sq.Reads) - (LAG(sq.Reads,1) OVER ( ORDER BY LocationID, ClusterID, DateKey, TimeKey)) As IntravalReads
			, (sq.Writes) - (LAG(sq.Writes,1) OVER ( ORDER BY LocationID, ClusterID, DateKey, TimeKey)) As IntravalWrites
			, (sq.Stall) - (LAG(sq.Stall,1) OVER ( ORDER BY LocationID, ClusterID, DateKey, TimeKey)) As IntravalStall
			, (ROW_NUMBER() OVER(PARTITION BY LocationID, ClusterID  ORDER BY DateKey DESC, TimeKey DESC)) AS RowCt
			FROM 
						( -- Subquery to get totals for read,write,stall
						SELECT	r.LocationID, r.ClusterID, r.DateKey, r.TimeKey, SUM(r.iVal) AS Reads, SUM(w.iVal) AS Writes, SUM(s.iVal) AS Stall
						FROM	Analysis.PerfCounterStats as r with(nolock)
						INNER JOIN .Analysis.PerfCounterStats as w with(nolock) on  r.LocationID = w.LocationID 
																				and r.ClusterID = w.ClusterID
																				and r.DateKey = w.DateKey
																				and r.TimeKey = w.TimeKey
																				and r.MetricID = 351
																				and w. MetricID = 356
						INNER JOIN .Analysis.PerfCounterStats as s with(nolock) on  r.LocationID = s.LocationID 
																				and r.ClusterID = s.ClusterID
																				and r.DateKey = s.DateKey
																				and r.TimeKey = s.TimeKey
																				and r.MetricID = 351
																				and s. MetricID = 371
						where r.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112) -- Limit to today's data only.
			
						group by r.LocationID, r.ClusterID, r.DateKey, r.TimeKey			
						) sq
			) iq
	WHERE (iq.IntravalStall is not null)  and (iq.IntravalReads is not null) and (iq.IntravalWrites is not null) and iq.RowCt = 1;;

	 
GO






USE [ServerAnalysisDW]
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Instance_Overview]    Script Date: 12/15/2022 8:01:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220901
-- Revision on: 20221215 - Handles new view for Signal Waits and Latency Ms
-- Based on  [Analysis].[PerfCounter_Rpt_Overview] 
-- =============================================
CREATE OR ALTER     PROCEDURE [Analysis].[PerfCounter_Rpt_Instance_Overview]
@LocationID int,
@ClusterID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		DECLARE @results as TABLE (	LocationID INT, 
								ClusterID INT, 
								ClusterName VARCHAR(250), 
								ClusterFullName VARCHAR(500),
								ClusterStatus VARCHAR(8),
								CpuPercent INT,
								SignalWaits INT,
								DiscLatencyMs INT,
								MemoryInstPercentInUse INT,
								DiskSpacePercentInUse INT,
								RunDuration VARCHAR(36),
								DiscWatchList VARCHAR(50))

	INSERT INTO @results (LocationID, CLusterID, ClusterName, ClusterFullName,
	ClusterStatus, CpuPercent, SignalWaits, DiscLatencyMs, MemoryInstPercentInUse, DiskSpacePercentInUse, RunDuration, DiscWatchList)
	SELECT	L.LocationID, 
			L.ClusterID, 
			L.ClusterName, 
			CONCAT(L.ClusterName,' (',
						(CASE L.LocationID	WHEN 101874 THEN 'CBG-US'
											WHEN 211098 THEN 'CBG-EU'
											WHEN 211874 THEN 'CBG-EU'
											WHEN 301035 THEN 'UPIC IMPL'
											WHEN 301166 THEN 'UPIC DEV'
											WHEN 301463 THEN 'UPIC PROD'
						ELSE 'Undefined' END)    			,')') 	AS ClusterFullName,
			'DOWN',0,0,0,0,0,'',''
	FROM	Analysis.PerfLocation as L WITH(NOLOCK)
	WHERE L.IsActive = 1
		and (L.LocationID = @LocationID and L.ClusterID = @ClusterID)
	GROUP BY L.LocationID, L.ClusterID, L.ClusterName;

	-- CPU
	UPDATE r
	SET CpuPercent = ISNULL(cpu.iValResult,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_CpuUsagePercent_Latest AS cpu on cpu.locationID = r.LocationID and cpu.ClusterID = r.ClusterID;

	-- Signnal Waits : Rev 20221215
	UPDATE r
	SET SignalWaits = ISNULL(sig.WaitSignal,0)
	FROM @results AS r
	--INNER JOIN Analysis.pcv_SignalWaits_Latest sig  on sig.locationID = r.LocationID and sig.ClusterID = r.ClusterID;
	INNER JOIN Analysis.pcv_SignalWaits_ByIntraval_Latest sig  on sig.locationID = r.LocationID and sig.ClusterID = r.ClusterID;

	-- DiscLatency Ms : Rev 20221215
	UPDATE r
	SET DiscLatencyMs =  ISNULL(dlat.LatencyMs,0)
	FROM @results AS r
	--INNER JOIN Analysis.pcv_IoDiskLatencyTotal_Latest dlat on dlat.locationID = r.LocationID and dlat.ClusterID = r.ClusterID;
	INNER JOIN Analysis.pcv_IoDiskLatency_Intraval_Latest dlat on dlat.locationID = r.LocationID and dlat.ClusterID = r.ClusterID;

	--MemoryInstPercentInUse
	UPDATE r
	SET MemoryInstPercentInUse = ISNULL(mem.MemoryInstPercentInUse,0) 
	FROM @results AS r
	INNER JOIN Analysis.pcv_MemoryInstUsage_Latest mem on mem.locationID = r.LocationID and mem.ClusterID = r.ClusterID;

	--DiskSpacePercentInUse
	UPDATE r
	SET DiskSpacePercentInUse = ISNULL(dsk.DiskSpacePercentInUse,0) 
	FROM @results AS r
	INNER JOIN Analysis.pcv_DiskUsage_Latest dsk on dsk.locationID = r.LocationID and dsk.ClusterID = r.ClusterID;

	--RunDuration
	UPDATE r
	SET RunDuration = ISNULL(rst.RunDuration,'') 
	FROM @results AS r
	INNER JOIN Analysis.pcv_InstanceLastRestart rst on rst.locationID = r.LocationID and rst.ClusterID = r.ClusterID;

	--DiscWatchList
	UPDATE r
	SET DiscWatchList = ISNULL(duw.DiscWatchList,'')
	FROM @results AS r
	INNER JOIN Analysis.pcv_DiskUsage_WatchList duw on duw.locationID = r.LocationID and duw.ClusterID = r.ClusterID

	-- Cluster Status
	UPDATE @results
	SET ClusterStatus = 'UP'
	WHERE (LEN(RunDuration) > 1 AND CpuPercent > 0) or ((SignalWaits + DiscLatencyMs + MemoryInstPercentInUse) > 0);

	SELECT		LocationID, 
				ClusterID, 
				ClusterName, 
				ClusterFullName,
				ClusterStatus,
				CpuPercent,
				SignalWaits,
				DiscLatencyMs,
				MemoryInstPercentInUse,
				DiskSpacePercentInUse,
				RunDuration,
				DiscWatchList
	FROM		@results
	ORDER BY	(CASE LocationID	WHEN 301035 THEN 999901			-- Place IMPL ande DEV last in list
									WHEN 301166 THEN 999902
									ELSE LocationID END),	
				ClusterID, 
				ClusterName;


END


GO







USE [ServerAnalysisDW]
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Overview]    Script Date: 12/15/2022 8:17:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220901
-- Revision on: 20221215 - Handles new view for Signal Waits and Latency Ms
-- =============================================
CREATE OR ALTER   PROCEDURE [Analysis].[PerfCounter_Rpt_Overview]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		DECLARE @results as TABLE (	LocationID INT, 
								ClusterID INT, 
								ClusterName VARCHAR(250), 
								ClusterFullName VARCHAR(500),
								ClusterStatus VARCHAR(8),
								CpuPercent INT,
								SignalWaits INT,
								DiscLatencyMs INT,
								MemoryInstPercentInUse INT,
								DiskSpacePercentInUse INT,
								RunDuration VARCHAR(36),
								DiscWatchList VARCHAR(50))

	INSERT INTO @results (LocationID, CLusterID, ClusterName, ClusterFullName,
	ClusterStatus, CpuPercent, SignalWaits, DiscLatencyMs, MemoryInstPercentInUse, DiskSpacePercentInUse, RunDuration, DiscWatchList)
	SELECT	L.LocationID, 
			L.ClusterID, 
			L.ClusterName, 
			CONCAT(L.ClusterName,' (',
						(CASE L.LocationID	WHEN 101874 THEN 'CBG-US'
											WHEN 211098 THEN 'CBG-EU'
											WHEN 211874 THEN 'CBG-EU'
											WHEN 301035 THEN 'UPIC IMPL'
											WHEN 301166 THEN 'UPIC DEV'
											WHEN 301463 THEN 'UPIC PROD'
						ELSE 'Undefined' END)    			,')') 	AS ClusterFullName,
			'DOWN',0,0,0,0,0,'',''
	FROM	Analysis.PerfLocation as L WITH(NOLOCK)
	WHERE L.IsActive = 1
	GROUP BY L.LocationID, L.ClusterID, L.ClusterName;

	-- CPU
	UPDATE r
	SET CpuPercent = ISNULL(cpu.iValResult,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_CpuUsagePercent_Latest AS cpu on cpu.locationID = r.LocationID and cpu.ClusterID = r.ClusterID;

	-- Signnal Waits : Rev 20221215
	UPDATE r
	SET SignalWaits = ISNULL(sig.WaitSignal,0)
	FROM @results AS r
	--INNER JOIN Analysis.pcv_SignalWaits_Latest sig  on sig.locationID = r.LocationID and sig.ClusterID = r.ClusterID;
	INNER JOIN Analysis.pcv_SignalWaits_ByIntraval_Latest sig  on sig.locationID = r.LocationID and sig.ClusterID = r.ClusterID;

	-- DiscLatency Ms : Rev 20221215
	UPDATE r
	SET DiscLatencyMs =  ISNULL(dlat.LatencyMs,0)
	FROM @results AS r
	--INNER JOIN Analysis.pcv_IoDiskLatencyTotal_Latest dlat on dlat.locationID = r.LocationID and dlat.ClusterID = r.ClusterID;
	INNER JOIN Analysis.pcv_IoDiskLatency_Intraval_Latest dlat on dlat.locationID = r.LocationID and dlat.ClusterID = r.ClusterID;

	
	--MemoryInstPercentInUse
	UPDATE r
	SET MemoryInstPercentInUse = ISNULL(mem.MemoryInstPercentInUse,0) 
	FROM @results AS r
	INNER JOIN Analysis.pcv_MemoryInstUsage_Latest mem on mem.locationID = r.LocationID and mem.ClusterID = r.ClusterID;

	--DiskSpacePercentInUse
	UPDATE r
	SET DiskSpacePercentInUse = ISNULL(dsk.DiskSpacePercentInUse,0) 
	FROM @results AS r
	INNER JOIN Analysis.pcv_DiskUsage_Latest dsk on dsk.locationID = r.LocationID and dsk.ClusterID = r.ClusterID;

	--RunDuration
	UPDATE r
	SET RunDuration = ISNULL(rst.RunDuration,'') 
	FROM @results AS r
	INNER JOIN Analysis.pcv_InstanceLastRestart rst on rst.locationID = r.LocationID and rst.ClusterID = r.ClusterID;

	--DiscWatchList
	UPDATE r
	SET DiscWatchList = ISNULL(duw.DiscWatchList,'')
	FROM @results AS r
	INNER JOIN Analysis.pcv_DiskUsage_WatchList duw on duw.locationID = r.LocationID and duw.ClusterID = r.ClusterID

	-- Cluster Status
	UPDATE @results
	SET ClusterStatus = 'UP'
	WHERE (LEN(RunDuration) > 1 AND CpuPercent > 0) or ((SignalWaits + DiscLatencyMs + MemoryInstPercentInUse) > 0);

	SELECT		LocationID, 
				ClusterID, 
				ClusterName, 
				ClusterFullName,
				ClusterStatus,
				CpuPercent,
				SignalWaits,
				DiscLatencyMs,
				MemoryInstPercentInUse,
				DiskSpacePercentInUse,
				RunDuration,
				DiscWatchList
	FROM		@results
	ORDER BY	(CASE LocationID	WHEN 301035 THEN 999901			-- Place IMPL ande DEV last in list
									WHEN 301166 THEN 999902
									ELSE LocationID END),	
				ClusterID, 
				ClusterName;


END


GO







USE [ServerAnalysisDW]
GO
/****** Object:  View [Analysis].[pcv_SignalWaits_ByIntraval_10]  Script Date: 12/15/2022 1:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221215
-- =============================================
CREATE OR ALTER VIEW [Analysis].[pcv_SignalWaits_ByIntraval_10]
AS

	-- Get SignalWait Use by 10  minute interval, evaluating only that period.
	-- MetricID 448 and 440 

	 SELECT	q.LocationID, q.ClusterID, q.DateKey, CONCAT(LEFT(q.TimeKey,3),'000') AS TimeKey, 
			CAST(100.0 * ( SUM(q.SignalMs) / COUNT(q.SignalMs)) / ( SUM(q.WaitMs) / COUNT(q.WaitMs)) AS NUMERIC(20,2)) AS WaitSignal
	 FROM	(
			SELECT	w.LocationID, w.ClusterID, w.DateKey, w.TimeKey, w.iVal
					, (w.iVal) - (LAG(w.iVal,1) OVER ( ORDER BY w.LocationID, w.ClusterID, w.DateKey, w.TimeKey)) As WaitMs
					, (s.iVal) - ( LAG(s.iVal,1) OVER ( ORDER BY w.LocationID, w.ClusterID, w.DateKey, w.TimeKey)) As SignalMs
			FROM	ServerAnalysisDW.Analysis.PerfCounterStats as w with(nolock)
			INNER JOIN ServerAnalysisDW.Analysis.PerfCounterStats as s with(nolock) on w.LocationID = s.LocationID 
																					and w.ClusterID = s.ClusterID
																					and w.DateKey = s.DateKey
																					and w.TimeKey = s.TimeKey
																					and w.MetricID = 448
																					and s. MetricID = 449
		WHERE	w.UtcDate > CONVERT(VARCHAR(10), GETUTCDATE(),112) -- Look at only todays data
		) q
	WHERE (q.iVal is not null)  and (q.SignalMs is not null)
	GROUP BY q.LocationID, q.ClusterID, q.DateKey, CONCAT(LEFT(q.TimeKey,3),'000');
	
GO


USE [ServerAnalysisDW]
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatency_Intraval_10] Script Date: 12/15/2022 1:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221215
-- =============================================
CREATE OR ALTER VIEW [Analysis].[pcv_IoDiskLatency_Intraval_10]
AS

	-- Get Disk Latency Intraval by row 10 minute intraval
	-- MetricID 351=reads  356=writes  371=stall
	SELECT iq.LocationID, iq.ClusterID, iq.DateKey, CONCAT(LEFT(iq.TimeKey,3),'000') AS TimeKey, 
	CONVERT(INT,((CAST(  (SUM(iq.IntravalStall) / COUNT(iq.IntravalStall))    AS FLOAT) / ((SUM(iq.IntravalReads) / COUNT(iq.IntravalReads)) + ( SUM(iq.IntravalWrites) / COUNT(iq.IntravalWrites))  )   ))) AS LatencyMs
	FROM
			( -- Inner query to find difference between this row and previous row
			SELECT sq.LocationID, sq.ClusterID, sq.DateKey, sq.TimeKey 
			, (sq.Reads) - (LAG(sq.Reads,1) OVER ( ORDER BY LocationID, ClusterID, DateKey, TimeKey)) As IntravalReads
			, (sq.Writes) - (LAG(sq.Writes,1) OVER ( ORDER BY LocationID, ClusterID, DateKey, TimeKey)) As IntravalWrites
			, (sq.Stall) - (LAG(sq.Stall,1) OVER ( ORDER BY LocationID, ClusterID, DateKey, TimeKey)) As IntravalStall
			FROM 
						( -- Subquery to get totals for read,write,stall
						SELECT	r.LocationID, r.ClusterID, r.DateKey, r.TimeKey, SUM(r.iVal) AS Reads, SUM(w.iVal) AS Writes, SUM(s.iVal) AS Stall
						FROM	Analysis.PerfCounterStats as r with(nolock)
						INNER JOIN .Analysis.PerfCounterStats as w with(nolock) on  r.LocationID = w.LocationID 
																				and r.ClusterID = w.ClusterID
																				and r.DateKey = w.DateKey
																				and r.TimeKey = w.TimeKey
																				and r.MetricID = 351
																				and w. MetricID = 356
						INNER JOIN .Analysis.PerfCounterStats as s with(nolock) on  r.LocationID = s.LocationID 
																				and r.ClusterID = s.ClusterID
																				and r.DateKey = s.DateKey
																				and r.TimeKey = s.TimeKey
																				and r.MetricID = 351
																				and s. MetricID = 371
						where r.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112) -- Limit to today's data only.
			
						group by r.LocationID, r.ClusterID, r.DateKey, r.TimeKey			
						) sq
			) iq	
	GROUP BY iq.LocationID, iq.ClusterID, iq.DateKey, CONCAT(LEFT(iq.TimeKey,3),'000');
	
	 
GO



/****** Object:  View [Analysis].[pcv_IoDiskLatency_Intraval_10] Script Date: 12/15/2022 1:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221026
-- Revision on: 20221215 - Bug fix where Datekey was hard coded. New Signal Wait and new Latency views updated.
-- =============================================

CREATE   OR ALTER    VIEW [Analysis].[pcv_bi_overview_today]
AS

	SELECT L.LocationID, L.ClusterID, L.ClusterName, 
			CONCAT(ClusterName,' (',
						(CASE L.LocationID	WHEN 101874 THEN 'CBG-US'
											WHEN 211098 THEN 'CBG-EU'
											WHEN 211874 THEN 'CBG-EU'
											WHEN 301035 THEN 'UPIC IMPL'
											WHEN 301166 THEN 'UPIC DEV'
											WHEN 301463 THEN 'UPIC PROD'
											ELSE 'Undefined' END)    ,')') AS ClusterFullName,
	
			t.Time4s, 
			MAX(cpu.iValResult) AS CpuPercent, 
			MAX(sig.WaitSignal) AS SignalWaits, 
			MAX(lat.LatencyMs) AS DiscLatencyMs, 
			MAX(mem.MemoryInstPercentInUse) AS MemoryInstPercentInUse,
			MAX(du.DiskSpacePercentInUse) AS DiskSpacePercentInUse, 
			MAX(bat.BatchRequestsSec) as BatchRequestsSec, 
			MAX(ps.PageSplitSec) AS PageSplitSec, 
			MAX(fs.FullScansSec) AS FullScansSec, 
			MAX(comp.SqlCompilationsSec) AS SqlCompilationsSec, 
			MAX(rcomp.SqlReCompilationsSec) AS SqlReCompilationsSec
	FROM Analysis.PerfLocation L WITH(NOLOCK) CROSS JOIN  dbo.TimeTens t WITH(NOLOCK)
	LEFT JOIN [Analysis].[pcv_CpuUsagePercent_10] cpu ON L.LocationID = cpu.LocationID and L.ClusterID = cpu.ClusterID and cpu.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = cpu.Timekey
	--LEFT JOIN [Analysis].[pcv_SignalWaits_10] sig ON L.LocationID = sig.LocationID and L.ClusterID = sig.ClusterID and sig.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = sig.Timekey
	LEFT JOIN [Analysis].[pcv_SignalWaits_ByIntraval_10] sig ON L.LocationID = sig.LocationID and L.ClusterID = sig.ClusterID and sig.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = sig.Timekey
	--LEFT JOIN  [Analysis].[pcv_IoDiskLatencyTotal_10] lat ON L.LocationID = lat.LocationID and L.ClusterID = lat.ClusterID and lat.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = lat.Timekey
	LEFT JOIN  [Analysis].[pcv_IoDiskLatency_Intraval_10] lat ON L.LocationID = lat.LocationID and L.ClusterID = lat.ClusterID and lat.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = lat.Timekey
	LEFT JOIN  [Analysis].[pcv_MemoryInstUsage_10] mem  ON L.LocationID = mem.LocationID and L.ClusterID = mem.ClusterID and mem.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = mem.Timekey
	LEFT JOIN [Analysis].[pcv_DiskUsage_10] du ON L.LocationID = du.LocationID and L.ClusterID = du.ClusterID and du.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = du.Timekey -- Only for overview chart uses 60 days
	LEFT JOIN  [Analysis].[pcv_BatchRequestsSec_10] bat ON L.LocationID = bat.LocationID and L.ClusterID = bat.ClusterID and bat.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = bat.Timekey
	LEFT JOIN [Analysis].[pcv_PageSpiltsSec_10] ps ON L.LocationID = ps.LocationID and L.ClusterID = ps.ClusterID and ps.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = ps.Timekey
	LEFT JOIN  [Analysis].[pcv_FullScansSec_10] fs ON L.LocationID = fs.LocationID and L.ClusterID = fs.ClusterID and fs.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = fs.Timekey
	LEFT JOIN [Analysis].[pcv_SqlCompilationsSec_10] comp  ON L.LocationID = comp.LocationID and L.ClusterID = comp.ClusterID and comp.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = comp.Timekey
	LEFT JOIN [Analysis].[pcv_SqlReCompilationsSec_10] rcomp  ON L.LocationID = rcomp.LocationID and L.ClusterID = rcomp.ClusterID and rcomp.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = rcomp.Timekey
	WHERE L.IsActive = 1 and L.ServerID = 1
	and  CONVERT(TIME, t.dtTime) <  CONVERT(TIME, getutcdate())
	GROUP BY L.LocationID, L.ClusterID,  L.ClusterName, t.Time4s;
GO

