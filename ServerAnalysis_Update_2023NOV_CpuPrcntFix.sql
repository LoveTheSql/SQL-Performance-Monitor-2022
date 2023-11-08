


/*

UPDATE 20231108

			This update adds a new CPU Percentage Counter using the System Health idle value to calculate cpu usage.
			This may (or may not) be more accurate than the pervious counters installed.
			This is installed into the vacant Metric ID 411
			This script  includes:

							UPDATE to	[Analysis].[PerfCounterMetric]  ID = 411
								This should be installed on all ServerAnalysis databases on all instances.
								This should be installed on the ServerAnalysisDW database.

							These objects should be installed/udated on the ServerAnalysisDW database.

							NEW VIEW:		[Analysis].[pcv_SysCpuUsagePercent_01]
											[Analysis].[pcv_SysCpuUsagePercent_10]
											[Analysis].[pcv_SysCpuUsagePercent_Latest]

							UPDATE VIEW:	[Analysis].[pcv_bi_overview_today]

							UPDATE SPROC:	[Analysis].[PerfCounter_Rpt_Instance_Overview]
											 [Analysis].[PerfCounter_Rpt_Overview] 


*/


USE [ServerAnalysis]
GO

UPDATE [Analysis].[PerfCounterMetric] 
SET MetricIntervalMinutes = 1,
MetricName = 'System Health: CPU usage %',
MetricDurationDesc = 'min',
MetricSubName = 'preferred',
MetricTsql = 'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName)  
SELECT s.PerfLocationID, 411, [REPLACEiDate], ''[REPLACEvTime]'', (100 - c.SystemIdle), NULL, ''CPU usage %''  
FROM ServerAnalysis.Analysis.Server AS s, 
	(SELECT record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') AS SystemIdle
	FROM (	SELECT TOP(1) dateadd (ms, r.[timestamp] - sys.ms_ticks, getdate()) as record_time, cast(r.record as xml) record
			FROM sys.dm_os_ring_buffers r
			cross join sys.dm_os_sys_info sys
			WHERE  ring_buffer_type=''RING_BUFFER_SCHEDULER_MONITOR''
			AND record LIKE ''%<SystemHealth>%''
			ORDER BY 1 DESC
			) AS x ) AS c
WHERE s.ServerNm = ''[REPLACEserver]'';'
WHERE MetricID = 411;

GO

select * from [Analysis].[PerfCounterMetric]
where MetricID = 411

select *
FROM [Analysis].[PerfCounterLog] WITH(NOLOCK)
WHERE MetricID in (411) and DateKey > 20231107
ORDER BY MetricID, TimeKey


GO


USE [ServerAnalysisDW]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE  OR ALTER    VIEW [Analysis].[pcv_SysCpuUsagePercent_01]
AS

	-- Get CPU Percentage Use by minute interval
	-- MetricID 411 = System Health: CPU usage % 
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			pc1.TimeKey, 
			pc1.iVal
	FROM	Analysis.PerfCounterStats as pc1 WITH(NOLOCK)
	WHERE (pc1.MetricID = 411);

GO




GO

CREATE   OR ALTER   VIEW [Analysis].[pcv_SysCpuUsagePercent_10]
AS

	-- Get CPU Percentage Use by ten (10) minute interval
	-- MetricID 411 = System Health: CPU usage % 
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey, 
			AVG(pc1.iVal) AS iVal
	FROM	Analysis.PerfCounterStats as pc1 WITH(NOLOCK)
	WHERE pc1.MetricID = 411
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);

GO


CREATE     VIEW [Analysis].[pcv_SYSCpuUsagePercent_Latest]
AS

	-- Get LATEST (only) CPU Percentage Use by Location/cluster
	-- MetricID 411 = System Health: CPU usage % 
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					pc1.TimeKey,
					pc1.UtcDate,
					pc1.iVal AS iVal,
						(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1 WITH(NOLOCK)
			WHERE (pc1.MetricID = 411) and (pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112))
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.UtcDate, pc1.iVal) gr
	WHERE gr.RowCt = 1;
	 
GO






CREATE OR ALTER       VIEW [Analysis].[pcv_bi_overview_today]
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
			MAX(cpu.iVal) AS CpuPercent, 
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
	LEFT JOIN [Analysis].[pcv_SysCpuUsagePercent_10] cpu ON L.LocationID = cpu.LocationID and L.ClusterID = cpu.ClusterID and cpu.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = cpu.Timekey
	LEFT JOIN [Analysis].[pcv_SignalWaits_ByIntraval_10] sig ON L.LocationID = sig.LocationID and L.ClusterID = sig.ClusterID and sig.DateKey = CONVERT(VARCHAR(10), GETUTCDATE(),112) and t.Time6 = sig.Timekey
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


---- SPROCS



/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Instance_Overview]    Script Date: 11/8/2023 10:49:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220901
-- Revision on: 20221215 - Handles new view for Signal Waits and Latency Ms
--				20231108 - Switches CPU Usage to new Metric definition ID 411
-- Based on  [Analysis].[PerfCounter_Rpt_Overview] 
-- =============================================
ALTER     PROCEDURE [Analysis].[PerfCounter_Rpt_Instance_Overview]
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
	SET CpuPercent = ISNULL(cpu.iVal,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_SysCpuUsagePercent_Latest AS cpu on cpu.locationID = r.LocationID and cpu.ClusterID = r.ClusterID;

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
	ORDER BY	(CASE LocationID	WHEN 301035 THEN 999901			-- custom code
									WHEN 301166 THEN 999902
									ELSE LocationID END),	
				ClusterID, 
				ClusterName;


END


GO



/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Overview]    Script Date: 11/8/2023 10:52:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220901
-- Revision on: 20221215 - Handles new view for Signal Waits and Latency Ms
--				20231108 - Switches CPU Usage to new Metric definition ID 411
-- =============================================
ALTER   PROCEDURE [Analysis].[PerfCounter_Rpt_Overview]
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
	SET CpuPercent = ISNULL(cpu.iVal,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_SysCpuUsagePercent_Latest AS cpu on cpu.locationID = r.LocationID and cpu.ClusterID = r.ClusterID;

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
	ORDER BY	(CASE LocationID	WHEN 301035 THEN 999901			-- Custom code
									WHEN 301166 THEN 999902
									ELSE LocationID END),	
				ClusterID, 
				ClusterName;


END


GO



