
/*
Update for SQL Performance Monitor Project NOVEMBER 2022.

TEST AND USE AT YOUR OWN RISK

www.lovethesql.com


*/





USE [ServerAnalysisDW]
GO


/****** Object:  StoredProcedure [Analysis].[PerfCounter_Bi_DatabaseProperties]    Script Date: 11/8/2022 11:26:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221026
-- =============================================
CREATE OR ALTER PROCEDURE [Analysis].[PerfCounter_Bi_DatabaseProperties]
AS
BEGIN

		DECLARE @id as TABLE (ID int identity(1,1), LocationID int, ClusterID int, ClusterName varchar(150))
		DECLARE @dB as TABLE (	ID int identity(1,1), 
								LocationID int, 
								ClusterID int, 
								LocationName varchar(250),
								ClusterName varchar(250),
								ClusterFullName varchar(250), 
								DatabaseName varchar(150), 
								MdfFileName varchar(150), 							
								MdfMBs varchar(24),
								LdfMBs varchar(24),
								IOpcnt varchar(8),
								Model varchar(12),  --  1 = FULL, 2 = BULK_LOGGED, 3 = SIMPLE
								SqlVersion varchar(8),  -- 70,80,90.100,110,20,130, 140, 150
								DbState varchar(20),  -- 0 = ONLINE, 1 = RESTORING, 2 = RECOVERING, 3 = RECOVERY_PENDING, 4 = SUSPECT, 5 = EMERGENC, 6 = OFFLINE, 7 = COPYING, 10 = OFFLINE_SECONDARY 
								LastBackup varchar(24),
								DailyGrowth int);
		DECLARE @iLoopP INT;
		DECLARE @cLocationID INT;
		DECLARE @cClusterID INT;
		DECLARE @cLocationName varchar(250); 
		DECLARE @cClusterName varchar(250); 
		DECLARE @cClusterFullName varchar(250); 

		INSERT INTO @Id (LocationID, ClusterID, ClusterName)
		SELECT LocationID, ClusterID, ClusterName
		FROM Analysis.PerfLocation 
		WHERE IsActive = 1 and ServerID = 1
		ORDER BY LocationID DESC, ClusterID DESC;

		SELECT @iLoopP = MAX(ID) FROM @id;

		WHILE @iLoopP > 0
		BEGIN

			SELECT	@cLocationID = LocationID, 
					@cClusterID = ClusterID,
					@cLocationName = (CASE LocationID	WHEN 101123 THEN 'MyCompany-US'
													WHEN 201123 THEN 'MyCompany-QA'
													WHEN 301123 THEN 'MyCompany-DEV'
													ELSE 'Undefined' END),
					@cClusterName = ClusterName,
					@cClusterFullName = CONCAT(ClusterName,' (',
								(CASE LocationID	WHEN 101123 THEN 'MyCompany-US'
													WHEN 201123 THEN 'MyCompany-QA'
													WHEN 301123 THEN 'MyCompany-DEV'
													ELSE 'Undefined' END)    ,')') 
			FROM @id
			WHERE ID = @iLoopP;

			INSERT INTO @dB (DatabaseName,MdfFileName,MdfMBs,LdfMBs,IOpcnt,Model,SqlVersion,DbState,LastBackup,DailyGrowth)
			EXEC [Analysis].[PerfCounter_Rpt_Database_Properties]  @cLocationID, @cClusterID;

			UPDATE @dB
			SET LocationID = @cLocationID, 
				ClusterID = @cClusterID,
				LocationName = @cLocationName,
				ClusterName = @cClusterName,
				ClusterFullName = @cClusterFullName
			WHERE LocationID IS NULL;

			SELECT	@cLocationID = 0, 
					@cClusterID = 0,  
					@cLocationName = '',
					@cClusterName = '',
					@cClusterFullName = '', 
					@iLoopP = @iLoopP-1
		END;

		SELECT * FROM @dB ORDER BY LocationID, ClusterID;

END
GO

/****** Object:  StoredProcedure [Analysis].[PerfCounter_Bi_ServerProperties]    Script Date: 11/8/2022 11:26:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		David Speight
-- Create date: 20221026
-- =============================================
CREATE OR ALTER PROCEDURE [Analysis].[PerfCounter_Bi_ServerProperties]
AS
BEGIN


		DECLARE @id as TABLE (ID int identity(1,1), LocationID int, ClusterID int, ClusterName varchar(150))
		DECLARE @d as TABLE (	ID int identity(1,1), 
								LocationID int, 
								ClusterID int, 
								LocationName varchar(250),
								ClusterName varchar(250),
								ClusterFullName varchar(250), 
								Property varchar(250), 
								DataVal varchar(250))
		DECLARE @iLoopP INT;
		DECLARE @cLocationID INT;
		DECLARE @cClusterID INT;
		DECLARE @cLocationName varchar(250); 
		DECLARE @cClusterName varchar(250); 
		DECLARE @cClusterFullName varchar(250); 

		INSERT INTO @Id (LocationID, ClusterID, ClusterName)
		SELECT LocationID, ClusterID, ClusterName
		FROM Analysis.PerfLocation 
		WHERE IsActive = 1 and ServerID = 1
		ORDER BY LocationID DESC, ClusterID DESC;

		SELECT @iLoopP = MAX(ID) FROM @id;

		WHILE @iLoopP > 0
		BEGIN

			SELECT	@cLocationID = LocationID, 
					@cClusterID = ClusterID,
					@cLocationName = (CASE LocationID	WHEN 101123 THEN 'MyCompany-US'
													WHEN 201123 THEN 'MyCompany-QA'
													WHEN 301123 THEN 'MyCompany-DEV'
													ELSE 'Undefined' END),
					@cClusterName = ClusterName,
					@cClusterFullName = CONCAT(ClusterName,' (',
								(CASE LocationID	WHEN 101123 THEN 'MyCompany-US'
													WHEN 201123 THEN 'MyCompany-QA'
													WHEN 301123 THEN 'MyCompany-DEV'
													ELSE 'Undefined' END)    ,')') 
			FROM @id
			WHERE ID = @iLoopP;

			INSERT INTO @d (Property, DataVal)
			EXEC [Analysis].[PerfCounter_Rpt_Server_Properties]  @cLocationID, @cClusterID;

			UPDATE @d
			SET LocationID = @cLocationID, 
				ClusterID = @cClusterID,
				LocationName = @cLocationName,
				ClusterName = @cClusterName,
				ClusterFullName = @cClusterFullName
			WHERE LocationID IS NULL;

			SELECT	@cLocationID = 0, 
					@cClusterID = 0,  
					@cLocationName = '',
					@cClusterName = '',
					@cClusterFullName = '', 
					@iLoopP = @iLoopP-1
		END;

		SELECT * FROM @d ORDER BY LocationID, ClusterID;

END
GO

/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Database_Properties]    Script Date: 11/8/2022 11:26:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		David Speight
-- Create date: 20221026
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

/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Server_Properties]    Script Date: 11/8/2022 11:26:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		David Speight
-- Create date: 202210211
-- =============================================
CREATE OR ALTER PROCEDURE [Analysis].[PerfCounter_Rpt_Server_Properties]
@LocationID int,
@ClusterID int
AS
BEGIN
	
	-- This sproc uses data collected into the monitoring tables. It pulls the MOST RECENT ENTRY for TODAY!

	-- 390 	Server Properties Bundled
	--MetricSubName = 'MachineName,ServerName,InstanceName,Clustered,NetBIOS,Edition,ProductLevel,Version,Build,Collation,FullText,IntegratedSecurityOnly,FilestreamLevel,HadrEnabled,HadrManagerStatus,XTPSupported,ClrVersion,HostDistribution,HostArch',

	-- 392 	System Info Bundled
	--MetricSubName = 'Physical Memory,Affinity Type,Virtual Machine Type,Container Type,Numa Nodes, Sockets,Cores per Socket,CPUs,Hyperthread Ratio',

	-- SET UP variables we'll need and a custom ordering for the first bundle.
	DECLARE @sTable AS TABLE (ID int IDENTITY(1,1) not null, Property varchar(50), DataVal varchar(100), OrderID INT);
	DECLARE @dTable AS TABLE (ID int IDENTITY(1,1) not null, DataVal varchar(100));
	DECLARE @iTable AS TABLE (ID int IDENTITY(1,1) not null, DataVal varchar(100));
	DECLARE @sOrder AS TABLE (ID int IDENTITY(1,1) not null, OrderID varchar(100));
	DECLARE @OrderId AS varchar(100) = '12,11,14,21,13,15,16,17,18,19,22,23,24,25,26,27,20,1,2';

	-- Store the custom order into a temp table variable.
	INSERT INTO  @sOrder
	SELECT a.value AS Data
	FROM STRING_SPLIT(@OrderId,',') a;

	-- GET SERVER PROPERTIES BUNDLED and UNBUNDLE
	-- Get the list of SERVER Properties stored.
	INSERT INTO @sTable
	SELECT TRIM(ss.value), '' AS DataVal , 1
	FROM  Analysis.PerfCounterMetric as pc WITH(NOLOCK) 
	CROSS APPLY STRING_SPLIT(pc.MetricSubName,',') ss
	WHERE pc.MetricID = 390;

	;
	-- Get the most recent SERVER Property (TODAY) data stored and insert it into a temp table variable.
	WITH cteServerSpecs AS (	SELECT  TOP(1) PartName
								FROM Analysis.PerfCounterStats as pc WITH(NOLOCK) 
								WHERE pc.MetricID = 390 and pc.DateKey = CONVERT(VARCHAR(10), GETDATE(),112)
								and pc.LocationID = @LocationID and pc.ClusterID = @ClusterID
								ORDER BY TimeKey DESC
	)

	INSERT INTO @dTable
	SELECT  ss.value
	FROM  cteServerSpecs as pc WITH(NOLOCK) 
	CROSS APPLY STRING_SPLIT(pc.PartName,',') ss;

	-- TRANSFORM the data and input it into our final table for output later.
	UPDATE s
	SET s.DataVal = (CASE d.DataVal WHEN '0' THEN 'Disabled' WHEN '1' THEN 'Enabled' ELSE  d.DataVal END)
	FROM @sTable as s
	INNER JOIN @dTable as d ON s.ID = d.ID;

	-- TRANSFORM the ORDERID column for our custom ordering.
	UPDATE s
	SET s.OrderID = r.OrderID
	FROM @sTable as s
	INNER JOIN @sOrder as r ON s.ID = r.ID;

	--------------------------
	-- GET SYSTEM INFO BUNDLED and UNBUNDLE
	-- Insert the header definitions for our SYSTEM INFO.
	INSERT INTO @sTable
	SELECT TRIM(ss.value), '' AS DataVal , 99
	FROM  Analysis.PerfCounterMetric as pc WITH(NOLOCK) 
	CROSS APPLY STRING_SPLIT(pc.MetricSubName,',') ss
	WHERE pc.MetricID = 392;

	;
	-- Grab the latest SYSTEM INFO that wal polled TODAY annd insert it into a temp table variable.
	WITH cteSysInfo AS (	SELECT  TOP(1) PartName
								FROM Analysis.PerfCounterStats as pc WITH(NOLOCK) 
								WHERE pc.MetricID = 392 and pc.DateKey = CONVERT(VARCHAR(10), GETDATE(),112)
								and pc.LocationID = @LocationID and pc.ClusterID = @ClusterID
								ORDER BY TimeKey DESC
	)

	INSERT INTO @iTable
	SELECT  ss.value
	FROM  cteSysInfo as pc WITH(NOLOCK) 
	CROSS APPLY STRING_SPLIT(pc.PartName,',') ss;

	-- TRANSFORM our SYSTEM INFO and insert it into our final table.
	UPDATE s
	SET s.DataVal = i.DataVal, s.OrderID = i.ID
	FROM @sTable as s
	INNER JOIN @iTable as i ON s.ID = (i.ID+19)
	WHERE s.OrderID = 99;

	-- Add a couple HEADER ROWS into our final table.
	INSERT INTO @sTable (Property, DataVal, OrderID)
	VALUES ('HOST PROPERTIES','',0), ('SQL SERVER PROPERTIES','',10);

	-- OUPUT the final results.
	SELECT  Property, DataVal FROM  @sTable ORDER BY OrderID;



END


GO


/****** Object:  View [Analysis].[pcv_PageSpiltsSec_10]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Analysis].[pcv_PageSpiltsSec_10]
AS

	-- From OS Perf Counter: Page Splits/sec
	-- MetricID 423
	SELECT	LocationID, 
			ClusterID, 
			DateKey, 
			CONCAT(LEFT(TimeKey,3),'000') AS TimeKey, 
			(MAX(iVal) - MIN(iVal)) / COUNT(iVal) AS PageSplitSec
	FROM	Analysis.PerfCounterStats 
	WHERE (MetricID = 423) 
	GROUP BY LocationID, ClusterID, DateKey, LEFT(TimeKey,3)
GO

/****** Object:  View [Analysis].[pcv_BatchRequestsSec_10]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE OR ALTER VIEW [Analysis].[pcv_BatchRequestsSec_10]
AS

	-- From OS Perf Counter: Batch Requests/sec
	-- MetricID 430
	SELECT	LocationID, 
			ClusterID, 
			DateKey, 
			CONCAT(LEFT(TimeKey,3),'000') AS TimeKey, 
			(MAX(iVal) - MIN(iVal)) / COUNT(iVal) AS BatchRequestsSec
	FROM	Analysis.PerfCounterStats 
	WHERE (MetricID = 430) 
	GROUP BY LocationID, ClusterID, DateKey, LEFT(TimeKey,3)
GO

/****** Object:  View [Analysis].[pcv_FullScansSec_10]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE OR ALTER VIEW [Analysis].[pcv_FullScansSec_10]
AS

	-- From OS Perf Counter: Batch Requests/sec
	-- MetricID 422
	SELECT	LocationID, 
			ClusterID, 
			DateKey, 
			CONCAT(LEFT(TimeKey,3),'000') AS TimeKey, 
			(MAX(iVal) - MIN(iVal)) / COUNT(iVal) AS FullScansSec
	FROM	Analysis.PerfCounterStats 
	WHERE (MetricID = 422) 
	GROUP BY LocationID, ClusterID, DateKey, LEFT(TimeKey,3)
GO

/****** Object:  View [Analysis].[pcv_SqlCompilationsSec_10]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE OR ALTER VIEW [Analysis].[pcv_SqlCompilationsSec_10]
AS

	-- From OS Perf Counter: Sql Compilations/Sec
	-- MetricID 431
	SELECT	LocationID, 
			ClusterID, 
			DateKey, 
			CONCAT(LEFT(TimeKey,3),'000') AS TimeKey, 
			(MAX(iVal) - MIN(iVal)) / (COUNT(iVal)*10) AS SqlCompilationsSec
	FROM	Analysis.PerfCounterStats 
	WHERE (MetricID = 431) 
	GROUP BY LocationID, ClusterID, DateKey, LEFT(TimeKey,3);
GO

/****** Object:  View [Analysis].[pcv_SqlReCompilationsSec_10]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE OR ALTER VIEW [Analysis].[pcv_SqlReCompilationsSec_10]
AS

	-- From OS Perf Counter: Sql ReCompilations/Sec
	-- MetricID 432
	SELECT	LocationID, 
			ClusterID, 
			DateKey, 
			CONCAT(LEFT(TimeKey,3),'000') AS TimeKey, 
			(MAX(iVal) - MIN(iVal)) / (COUNT(iVal)*10) AS SqlReCompilationsSec
	FROM	Analysis.PerfCounterStats 
	WHERE (MetricID = 432) 
	GROUP BY LocationID, ClusterID, DateKey, LEFT(TimeKey,3);
GO

/****** Object:  View [Analysis].[pcv_DiskUsage_10]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [Analysis].[pcv_DiskUsage_10]
AS

	-- MetricID 311 = Server Drive: Total Size MBs   | 312 = Server Drive: Available Space MBs
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey,  
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,  
			SUM(pc1.iVal) AS DiskSpaceAvailable, 
			SUM(pc2.iVal) AS DiskSpaceTotal,
			(SUM(pc2.iVal) - SUM(pc1.iVal)) AS DiskSpaceInUse,
			(CASE WHEN SUM(pc2.iVal) > 0 THEN
				CONVERT(INT,(((CAST(SUM(pc2.iVal) AS FLOAT)-CAST(SUM(pc1.iVal) AS FLOAT)) / SUM(pc2.iVal))*100)) 
				ELSE 0 END)AS DiskSpacePercentInUse
	FROM	Analysis.PerfCounterStats as pc1
			INNER JOIN Analysis.PerfCounterStats as pc2 ON 
					pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
	WHERE (pc1.MetricID = 312 and pc2.MetricID = 311)
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);

GO

/****** Object:  View [Analysis].[pcv_bi_overview_today]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE OR ALTER VIEW [Analysis].[pcv_bi_overview_today]
AS

	SELECT L.LocationID, L.ClusterID, L.ClusterName, 
			CONCAT(ClusterName,' (',
						(CASE L.LocationID	WHEN 101123 THEN 'MyCompany-US'
											WHEN 201123 THEN 'MyCompany-QA'
											WHEN 301123 THEN 'MyCompany-DEV'
											ELSE 'Undefined' END)    ,')') AS ClusterFullName,
	
			t.Time4s, 
			MAX(cpu.iValResult) AS CpuPercent, 
			MAX(sig.SignalWaits) AS SignalWaits, 
			MAX(lat.DiscLatencyMs) AS DiscLatencyMs, 
			MAX(mem.MemoryInstPercentInUse) AS MemoryInstPercentInUse,
			MAX(du.DiskSpacePercentInUse) AS DiskSpacePercentInUse, 
			MAX(bat.BatchRequestsSec) as BatchRequestsSec, 
			MAX(ps.PageSplitSec) AS PageSplitSec, 
			MAX(fs.FullScansSec) AS FullScansSec, 
			MAX(comp.SqlCompilationsSec) AS SqlCompilationsSec, 
			MAX(rcomp.SqlReCompilationsSec) AS SqlReCompilationsSec
	FROM Analysis.PerfLocation L WITH(NOLOCK) CROSS JOIN  dbo.TimeTens t WITH(NOLOCK)
	LEFT JOIN [Analysis].[pcv_CpuUsagePercent_10] cpu ON L.LocationID = cpu.LocationID and L.ClusterID = cpu.ClusterID and cpu.DateKey = 20221101 and t.Time6 = cpu.Timekey
	LEFT JOIN [Analysis].[pcv_SignalWaits_10] sig ON L.LocationID = sig.LocationID and L.ClusterID = sig.ClusterID and sig.DateKey = 20221101 and t.Time6 = sig.Timekey
	LEFT JOIN  [Analysis].[pcv_IoDiskLatencyTotal_10] lat ON L.LocationID = lat.LocationID and L.ClusterID = lat.ClusterID and lat.DateKey = 20221101 and t.Time6 = lat.Timekey
	LEFT JOIN  [Analysis].[pcv_MemoryInstUsage_10] mem  ON L.LocationID = mem.LocationID and L.ClusterID = mem.ClusterID and mem.DateKey = 20221101 and t.Time6 = mem.Timekey
	LEFT JOIN [Analysis].[pcv_DiskUsage_10] du ON L.LocationID = du.LocationID and L.ClusterID = du.ClusterID and du.DateKey = 20221101 and t.Time6 = du.Timekey -- Only for overview chart uses 60 days
	LEFT JOIN  [Analysis].[pcv_BatchRequestsSec_10] bat ON L.LocationID = bat.LocationID and L.ClusterID = bat.ClusterID and bat.DateKey = 20221101 and t.Time6 = bat.Timekey
	LEFT JOIN [Analysis].[pcv_PageSpiltsSec_10] ps ON L.LocationID = ps.LocationID and L.ClusterID = ps.ClusterID and ps.DateKey = 20221101 and t.Time6 = ps.Timekey
	LEFT JOIN  [Analysis].[pcv_FullScansSec_10] fs ON L.LocationID = fs.LocationID and L.ClusterID = fs.ClusterID and fs.DateKey = 20221101 and t.Time6 = fs.Timekey
	LEFT JOIN [Analysis].[pcv_SqlCompilationsSec_10] comp  ON L.LocationID = comp.LocationID and L.ClusterID = comp.ClusterID and comp.DateKey = 20221101 and t.Time6 = comp.Timekey
	LEFT JOIN [Analysis].[pcv_SqlReCompilationsSec_10] rcomp  ON L.LocationID = rcomp.LocationID and L.ClusterID = rcomp.ClusterID and rcomp.DateKey = 20221101 and t.Time6 = rcomp.Timekey
	WHERE L.IsActive = 1 and L.ServerID = 1
	and  CONVERT(TIME, t.dtTime) <  CONVERT(TIME, getutcdate())
	GROUP BY L.LocationID, L.ClusterID,  L.ClusterName, t.Time4s;
GO

/****** Object:  View [Analysis].[InstanceList]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE OR ALTER VIEW [Analysis].[InstanceList]
AS

	SELECT	p.LocationID, 
			p.ClusterID, 
			p.ClusterName,
			CONCAT(ClusterName,' (',
						(CASE p.LocationID	WHEN 101123 THEN 'MyCompany-US'
											WHEN 201123 THEN 'MyCompany-QA'
											WHEN 301123 THEN 'MyCompany-DEV'
											ELSE 'Undefined' END)    ,')') AS ClusterFullName,
			r.LastRestartDate, 
			r.RunDuration,
			d.DiscWatchList
	FROM	Analysis.PerfLocation p
			LEFT JOIN [Analysis].[pcv_InstanceLastRestart]  r on p.LocationID = r.LocationID and p.ClusterID = R.ClusterID
			LEFT JOIN [Analysis].[pcv_DiskUsage_WatchList] d  on p.LocationID = d.LocationID and p.ClusterID = d.ClusterID
	WHERE	p.IsActive = 1 and p.ServerID = 1;
GO

/****** Object:  View [Analysis].[pcv_DatabaseBackupFull_Today]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create OR ALTER VIEW [Analysis].[pcv_DatabaseBackupFull_Today]
AS

	-- Today's Backup Verification
	-- MetricID 101
	SELECT	LocationID, ClusterID, PartName, MIN(iVal) as iVal, MAX(TimeKey) as TimeKey
	FROM	Analysis.PerfCounterStats  WITH(NOLOCK)
	WHERE	DateKey =  CONVERT(VARCHAR(10), GETDATE(),112) and MetricID = 101
	Group BY LocationID, ClusterID, PartName;

GO

/****** Object:  View [Analysis].[pcv_OsCpuUsagePercent_10]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [Analysis].[pcv_OsCpuUsagePercent_10]
AS

	-- Get LATEST (only) CPU Percentage Use by Location/cluster
	-- MetricID 221 = OS Info: CPU usage % base
	SELECT LocationID, 
			ClusterID, 
			DateKey, 
			CONCAT(LEFT(TimeKey,3),'000') AS TimeKey, 
			iVal
	FROM	Analysis.PerfCounterStats  WITH(NOLOCK)
	WHERE (MetricID = 251) and (DateKey =  CONVERT(INT,CONVERT(VARCHAR(10), GETDATE(),112)));
	 
GO

/****** Object:  View [Analysis].[pcv_OsCpuUsagePercent_Latest]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [Analysis].[pcv_OsCpuUsagePercent_Latest]
AS

	-- Get LATEST (only) CPU Percentage Use by Location/cluster
	-- MetricID 221 = OS Info: CPU usage % base
	SELECT TOP(1) LocationID, 
			ClusterID, 
			DateKey, 
			TimeKey,
			iVal
	FROM	Analysis.PerfCounterStats  WITH(NOLOCK)
	WHERE (MetricID = 251) and (DateKey =  CONVERT(INT,CONVERT(VARCHAR(10), GETDATE(),112)))
	ORDER BY TimeKey DESC;
	 
GO

/****** Object:  View [Analysis].[pcv_OsCpuUsagePercent_01]    Script Date: 11/8/2022 11:26:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [Analysis].[pcv_OsCpuUsagePercent_01]
AS

	-- Get LATEST (only) CPU Percentage Use by Location/cluster
	-- MetricID 221 = OS Info: CPU usage % base
	SELECT  LocationID, 
			ClusterID, 
			DateKey, 
			TimeKey,
			iVal
	FROM	Analysis.PerfCounterStats  WITH(NOLOCK)
	WHERE (MetricID = 251) and (DateKey =  CONVERT(INT,CONVERT(VARCHAR(10), GETDATE(),112)));
	
	 
GO


