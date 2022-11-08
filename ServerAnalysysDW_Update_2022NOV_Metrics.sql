--- RUN THIS SCRPT ON EACH OF THE FOLLOWING DATABASES

--USE [ServerAnalysis];
USE [ServerAnalysisDW];
--USE [ServerAnalysisDwStaging];

GO


-- 251- OS Info: CPU usage %
UPDATE [Analysis].[PerfCounterMetric] SET [MetricIntervalMinutes]=1,
MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName, UtcDate)  
SELECT s.PerfLocationID, 251, [REPLACEiDate], ''[REPLACEvTime]'', AVG(100 - y.SystemIdle) as CPUpercent, NULL,NULL, getutcdate() 
FROM ServerAnalysis.Analysis.Server AS s, 
(SELECT record.value(''(./Record/@id)[1]'', ''int'') AS record_id, record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') AS SystemIdle, 
record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', ''int'') AS SQLProcessUtilization, record_time 
FROM (SELECT TOP(3) dateadd (ms, r.[timestamp] - sys.ms_ticks, getdate()) as record_time, cast(r.record as xml) record 
FROM sys.dm_os_ring_buffers r CROSS JOIN sys.dm_os_sys_info sys 
WHERE  ring_buffer_type=''RING_BUFFER_SCHEDULER_MONITOR'' AND record LIKE ''%<SystemHealth>%'' 
ORDER BY 1 DESC) AS x 
) AS y 
WHERE s.ServerNm = ''[REPLACEserver]''
GROUP BY s.PerfLocationID;'
WHERE [MetricID]=251;



-- 390 New code for bundled Server Properties
UPDATE [Analysis].[PerfCounterMetric] SET [MetricIntervalMinutes]=360, MetricName = 'Server Properties Bundled', MetricDurationDesc='',
MetricSubName = 'MachineName,ServerName,InstanceName,Clustered,NetBIOS,Edition,ProductLevel,Version,Build,Collation,FullText,IntegratedSecurityOnly,FilestreamLevel,HadrEnabled,HadrManagerStatus,XTPSupported,ClrVersion,HostDistribution,HostArch',
MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName, UtcDate) 
SELECT s.PerfLocationID, 390, [REPLACEiDate], ''[REPLACEvTime]'', NULL, NULL, 
CONCAT(
CONVERT(VARCHAR(24),SERVERPROPERTY(''MachineName'')), '','',
s.ServerResolvedName, '','', 
ISNULL(CONVERT(VARCHAR(24),SERVERPROPERTY(''InstanceName'')),''MSSQL''), '','', 
CONVERT(CHAR(1),SERVERPROPERTY(''IsClustered'')), '','', 
CONVERT(VARCHAR(24),SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'')), '','',
(CASE CONVERT(INT,SERVERPROPERTY(''ProductMajorVersion'')) 
	WHEN 16 then ''SQL Server 2022 ''
	WHEN 15 then ''SQL Server 2019 ''
	WHEN 14 then ''SQL Server 2017 ''
	WHEN 13 then ''SQL Server 2016 ''
	WHEN 12 then ''SQL Server 2012 ''
	ELSE ''SQL Server '' END), 
CONVERT(VARCHAR(24),SERVERPROPERTY(''Edition'')), '','',
CONVERT(VARCHAR(24),SERVERPROPERTY(''ProductUpdateLevel'')), '','',  
CONVERT(VARCHAR(24),SERVERPROPERTY(''ProductVersion'')), '','',
CONVERT(VARCHAR(24),SERVERPROPERTY(''ProductBuild'')), '','',
CONVERT(VARCHAR(24),SERVERPROPERTY(''Collation'')), '','', 
CONVERT(CHAR(1),SERVERPROPERTY(''IsFullTextInstalled'')), '','',
CONVERT(CHAR(1),SERVERPROPERTY(''IsIntegratedSecurityOnly'')), '','',
CONVERT(CHAR(1),SERVERPROPERTY(''FilestreamConfiguredLevel'')), '','',
CONVERT(CHAR(1),SERVERPROPERTY(''IsHadrEnabled'')), '','', 
CONVERT(CHAR(1),SERVERPROPERTY(''HadrManagerStatus'')), '','',
CONVERT(CHAR(1),SERVERPROPERTY(''IsXTPSupported'')), '','',
CONVERT(VARCHAR(24),SERVERPROPERTY(''BuildClrVersion'')), '','',
host_distribution, '','', host_architecture), getutcdate() 
FROM ServerAnalysis.Analysis.Server AS s, sys.dm_os_host_info AS h
WHERE s.ServerNm = ''[REPLACEserver]'';'
WHERE [MetricID]=390;



-- VERSION WARNING
-- PRE 2017 SQL NOTE:   REPLACE   container_type_desc  with   ''NONE''

-- 392 New code for System Bundled info
UPDATE [Analysis].[PerfCounterMetric] SET [MetricIntervalMinutes]=360, MetricName = 'System Info Bundled', MetricDurationDesc='',
MetricSubName = 'Physical Memory,Affinity Type,Virtual Machine Type,Container Type,Numa Nodes, Sockets,Cores per Socket,CPUs,Hyperthread Ratio',
MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName, UtcDate) 
SELECT s.PerfLocationID, 392, [REPLACEiDate], ''[REPLACEvTime]'', NULL, NULL, 
CONCAT(
physical_memory_kb/1024,'','', 
affinity_type_desc,'','',
virtual_machine_type_desc, '','',
container_type_desc,'','',
numa_node_count,'','',
socket_count,'','',
cores_per_socket,'','',
cpu_count,'','',
hyperthread_ratio),
getutcdate() 
WHERE s.ServerNm = ''[REPLACEserver]'';'
WHERE [MetricID]=392;


-- 123 Bug fix
UPDATE analysis.PerfCounterMetric SET MetricIntervalMinutes=360, MetricTsql=
'DECLARE @iLoop int; SELECT @iLoop =  MAX(database_id) from sys.databases;  
WHILE  @iLoop > 0   BEGIN   DECLARE @tSql varchar(1000);   
SELECT @tSql = CONCAT(      ''INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName,UtcDate)       
SELECT s.PerfLocationID, (CASE RIGHT(d.physical_name,3) WHEN ''''ldf'''' THEN 125 ELSE 123 END),        
[REPLACEiDate], ''''[REPLACEvTime]'''',  
CAST((d.size/128.0) AS INT), NULL, 
CONCAT('''''',DB_NAME(@iLoop),'''''','''','''',d.name,'''','''',d.physical_name), getutcdate()      
FROM ServerAnalysis.Analysis.Server AS s, ['',DB_NAME(@iLoop),''].[sys].[database_files] d     
WHERE  s.ServerNm = ''''[REPLACEserver]'''';'');   
BEGIN TRY    EXEC(@Tsql);   END TRY   BEGIN CATCH    PRINT(@Tsql);   END CATCH;   SELECT @iLoop = @iLoop-1;   END;'
where Metricid =123;



-- 127 Bug fix
UPDATE Analysis.PerfCounterMetric
SET MetricIntervalMinutes = 180, MetricName = 'Database IO Percentage', MetricDurationDesc='Database IO Percentage [PartName = DatabaseName]'
WHERE MetricID=127;

UPDATE [Analysis].[PerfCounterMetric] SET [MetricIntervalMinutes]=180,
MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName, UtcDate)  
SELECT s.PerfLocationID, 127, [REPLACEiDate], ''[REPLACEvTime]'', NULL, CAST(ag.io_in_mb/ SUM(ag.io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)), ag.DatabaseName, getutcdate() 
FROM ServerAnalysis.Analysis.Server AS s, 
(SELECT DB_NAME(database_id) AS DatabaseName,
		CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) 
GROUP BY database_id) ag
WHERE s.ServerNm = ''[REPLACEserver]'';'
WHERE [MetricID]=127;


-- Bug fix where IDs were mismatched
UPDATE Analysis.PerfCounterMetric 
SET MetricTsql = replace(MetricTsql,'(CASE d.recovery_model_desc WHEN ''SIMPLE'' THEN 1 WHEN ''FULL'' then 2 ELSE 3 END)','d.recovery_model')
where metricid= 144;


-- Bug fix for date error
use ServerAnalysis;
UPDATE [Analysis].[PerfCounterMetric] SET [MetricIntervalMinutes]=180,
MetricTsql = 
'INSERT INTO ServerAnalysis.Analysis.PerfCounterLog (PerfLocationID,MetricID,DateKey,TimeKey,iVal,dVal,PartName, UtcDate)    
SELECT s.PerfLocationID, 101, [REPLACEiDate], ''[REPLACEvTime]'', (CASE WHEN MAX(a.FileDate) IS NULL THEN 0 ELSE 1 END), NULL, r.name, 
(CASE WHEN MAX(a.FileDate) IS NULL THEN ''1901-01-01 00:00:01.000'' ELSE CONVERT(varchar(50),MAX(a.FileDate))  END)
FROM ServerAnalysis.Analysis.Server AS s, 
(select name from sys.databases) as r 
LEFT JOIN  [Audit].[dbo].[DatabaseBackupCheck] AS a ON r.name = REPLACE(a.DatabaseName,''.bak'','''')  
WHERE s.ServerNm = ''[REPLACEserver]''  
GROUP BY s.PerfLocationID, r.name 
HAVING MAX(a.FileDate) > DATEADD(hour,-30,GETUTCDATE()) or MAX(a.FileDate) IS NULL;'
WHERE [MetricID]=101;

-- Bug fix for locations where there is not a 60 MINUTE job running, only 180, 360 and 1440.
UPDATE Analysis.PerfCounterMetric
SET MetricIntervalMinutes = 180
WHERE MetricIntervalMinutes = 60;













