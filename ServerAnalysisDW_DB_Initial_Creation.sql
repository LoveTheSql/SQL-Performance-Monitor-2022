/* THIS DW DATABASE is only located on the server where reports are pulled 
	TESTED on SQL 2017+


*/

USE Master;
CREATE DATABASE ServerAnalysisDW;
GO




USE [ServerAnalysisDW]
GO
/****** Object:  DatabaseRole [db_executor]    Script Date: 10/12/2022 10:55:39 AM ******/
CREATE ROLE [db_executor]
GO
/****** Object:  Schema [Analysis]    Script Date: 10/12/2022 10:55:39 AM ******/
CREATE SCHEMA [Analysis]
GO
/****** Object:  UserDefinedFunction [Analysis].[ConvertMsToTime]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		David Speight
-- Create date: https://stackoverflow.com/questions/12757811/converting-milliseconds-to-days-hours-minutes-and-seconds
-- =============================================
CREATE FUNCTION [Analysis].[ConvertMsToTime]
(
@duration bigint
)
RETURNS VARCHAR(50) 
AS
BEGIN
	-- Declare the return variable here
	DECLARE @outnumber varchar(50);
	select  @outnumber =
      CONVERT(varchar(24),@duration/(1000*60*60))+CONVERT(varchar(24),':')+
      CONVERT(varchar(24),(@duration%(1000*60*60))/(1000*60))+CONVERT(varchar(24),':')+
      CONVERT(varchar(24),((@duration%(1000*60*60))%(1000*60))/1000)+CONVERT(varchar(24),'.')+
      CONVERT(varchar(24),((@duration%(1000*60*60))%(1000*60))%1000)

	RETURN @outNumber;

END

GO
/****** Object:  UserDefinedFunction [Analysis].[ConvertTicksToTime]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		David Speight
-- Create date: https://stackoverflow.com/questions/12757811/converting-milliseconds-to-days-hours-minutes-and-seconds
-- =============================================
CREATE FUNCTION [Analysis].[ConvertTicksToTime]
(
@duration bigint
)
RETURNS VARCHAR(50) 
AS
BEGIN
	-- Declare the return variable here
	DECLARE @outnumber varchar(50);
	SELECT @duration = @duration/1000;
	select  @outnumber =
      CONVERT(varchar(24),(@duration/(1000*60*60))) +CONVERT(varchar(24),':')+
      right(CONVERT(varchar(24),((@duration%(1000*60*60))/(1000*60))+100),2) +CONVERT(varchar(24),':')+
      right(CONVERT(varchar(24),(((@duration%(1000*60*60))%(1000*60))/1000)+100),2) +CONVERT(varchar(24),'.')+
      right(CONVERT(varchar(24),(((@duration%(1000*60*60))%(1000*60))%1000)+1000),3)

	RETURN @outNumber;

END

GO
/****** Object:  UserDefinedFunction [Analysis].[NegToZero]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [Analysis].[NegToZero]
(
@inNumber FLOAT
)
RETURNS FLOAT 
AS
BEGIN
	-- Declare the return variable here
	DECLARE @outNumber FLOAT 

	SELECT @outNumber = (CASE WHEN @inNumber < 0 THEN 0 ELSE @inNumber END);
	-- Return the result of the function
	RETURN @outNumber

END

GO
/****** Object:  UserDefinedFunction [dbo].[CreateDateTimeFrom2Strings]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- =============================================
CREATE FUNCTION [dbo].[CreateDateTimeFrom2Strings]
(
@DateString char(8),
@TimeString char(6)
)
RETURNS datetime
AS
BEGIN

	DECLARE @TheDateTime datetime;
	SELECT @TheDateTime =
					CONVERT(datetime,@DateString) +
					CONVERT(datetime,(CONCAT(LEFT(@TimeString,2),':',SUBSTRING(@TimeString,3,2),':',RIGHT(@TimeString,2))))
	RETURN @TheDateTime;

END
GO
/****** Object:  Table [Analysis].[PerfCounterStats]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Analysis].[PerfCounterStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LocationID] [int] NOT NULL,
	[ClusterID] [int] NOT NULL,
	[MetricID] [int] NOT NULL,
	[PartName] [varchar](250) NOT NULL,
	[DateKey] [int] NOT NULL,
	[TimeKey] [char](6) NOT NULL,
	[iVal] [bigint] NULL,
	[dVal] [decimal](10, 4) NULL,
	[UtcDate] [datetime] NULL,
 CONSTRAINT [PK_PerfCounterStats] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyTotal_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE     VIEW [Analysis].[pcv_IoDiskLatencyTotal_Latest]
AS

	-- Get Disk Latency Total (All)
	-- MetricID 351=reads  356=writes  371=stall
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					pc1.TimeKey, 
					pc1.iVal AS NumOfReads, 
					pc2.iVal AS NumOfWrites,
					pc3.iVal AS Stall,
					(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
						CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
						ELSE 0 END) AS DiscLatencyMs,					
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
					INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
							ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
							and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
					INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
							ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
							and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
			WHERE (pc1.MetricID = 351 and pc2.MetricID = 356 and pc3.MetricID = 371) and (pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112))
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal) gr
	WHERE gr.RowCt = 1;
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencySysDb_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE     VIEW [Analysis].[pcv_IoDiskLatencySysDb_Latest]
AS

	-- Get Disk Latency Sys DBs
	-- MetricID 352=reads  357=writes  372=stall
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					pc1.TimeKey, 
					pc1.iVal AS NumOfReads, 
					pc2.iVal AS NumOfWrites,
					pc3.iVal AS Stall,
					(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
						CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
						ELSE 0 END) AS DiscLatencyMs,					
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
					INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
							ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
							and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
					INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
							ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
							and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
			WHERE (pc1.MetricID = 352 and pc2.MetricID = 357 and pc3.MetricID = 372) and (pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112))
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal) gr
	WHERE gr.RowCt = 1;
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyDbLog_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE     VIEW [Analysis].[pcv_IoDiskLatencyDbLog_Latest]
AS

	-- Get Disk Latency User DBs
	-- MetricID 354=reads  359=writes  374=stall
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					pc1.TimeKey, 
					pc1.iVal AS NumOfReads, 
					pc2.iVal AS NumOfWrites,
					pc3.iVal AS Stall,
					(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
						CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
						ELSE 0 END) AS DiscLatencyMs,					
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
					INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
							ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
							and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
					INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
							ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
							and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
			WHERE (pc1.MetricID = 354 and pc2.MetricID = 359 and pc3.MetricID = 374) and (pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112))
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal) gr
	WHERE gr.RowCt = 1;
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyTempDb_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE     VIEW [Analysis].[pcv_IoDiskLatencyTempDb_Latest]
AS

	-- Get Disk Latency User DBs
	-- MetricID 355=reads  360=writes  3745=stall
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					pc1.TimeKey, 
					pc1.iVal AS NumOfReads, 
					pc2.iVal AS NumOfWrites,
					pc3.iVal AS Stall,
					(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
						CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
						ELSE 0 END) AS DiscLatencyMs,					
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
					INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
							ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
							and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
					INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
							ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
							and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
			WHERE (pc1.MetricID = 355 and pc2.MetricID = 360 and pc3.MetricID = 375) and (pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112))
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal) gr
	WHERE gr.RowCt = 1;
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyTempDb_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE       VIEW [Analysis].[pcv_IoDiskLatencyTempDb_01]
AS

	-- Get Disk Latency User DBs
	-- MetricID 355=reads  360=writes  3745=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			pc1.TimeKey, 
			pc1.iVal AS NumOfReads, 
			pc2.iVal AS NumOfWrites,
			pc3.iVal AS Stall,
			(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
				CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 355 and pc2.MetricID = 360 and pc3.MetricID = 375)
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal

	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyTempDb_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE      VIEW [Analysis].[pcv_IoDiskLatencyTempDb_10]
AS

	-- Get Disk Latency User DBs
	-- MetricID 355=reads  360=writes  3745=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
			AVG(pc1.iVal) AS NumOfReads, 
			AVG(pc2.iVal) AS NumOfWrites,
			AVG(pc3.iVal) AS Stall,
			(CASE WHEN (AVG(pc1.iVal) > 0 and AVG(pc2.iVal) > 0)  THEN 
				CONVERT(INT,((CAST(AVG(pc3.iVal) AS FLOAT) / (AVG(pc1.iVal) + AVG(pc2.iVal))   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 355 and pc2.MetricID = 360 and pc3.MetricID = 375)
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);

	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyDbLog_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE      VIEW [Analysis].[pcv_IoDiskLatencyDbLog_01]
AS

	-- Get Disk Latency User DBs
	-- MetricID 354=reads  359=writes  374=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			pc1.TimeKey, 
			pc1.iVal AS NumOfReads, 
			pc2.iVal AS NumOfWrites,
			pc3.iVal AS Stall,
			(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
				CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 354 and pc2.MetricID = 359 and pc3.MetricID = 374) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal;
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyDbLog_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  VIEW [Analysis].[pcv_IoDiskLatencyDbLog_10]
AS

	-- Get Disk Latency User DBs
	-- MetricID 354=reads  359=writes  374=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
			AVG(pc1.iVal) AS NumOfReads, 
			AVG(pc2.iVal) AS NumOfWrites,
			AVG(pc3.iVal) AS Stall,
			(CASE WHEN (AVG(pc1.iVal) > 0 and AVG(pc2.iVal) > 0)  THEN 
				CONVERT(INT,((CAST(AVG(pc3.iVal) AS FLOAT) / (AVG(pc1.iVal) + AVG(pc2.iVal))   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 354 and pc2.MetricID = 359 and pc3.MetricID = 374) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencySysDb_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE     VIEW [Analysis].[pcv_IoDiskLatencySysDb_01]
AS

	-- Get Disk Latency Sys DBs
	-- MetricID 352=reads  357=writes  372=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			pc1.TimeKey, 
			pc1.iVal AS NumOfReads, 
			pc2.iVal AS NumOfWrites,
			pc3.iVal AS Stall,
			(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
				CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 352 and pc2.MetricID = 357 and pc3.MetricID = 372) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal;
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencySysDb_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE     VIEW [Analysis].[pcv_IoDiskLatencySysDb_10]
AS

	-- Get Disk Latency Sys DBs
	-- MetricID 352=reads  357=writes  372=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
			AVG(pc1.iVal) AS NumOfReads, 
			AVG(pc2.iVal) AS NumOfWrites,
			AVG(pc3.iVal) AS Stall,
			(CASE WHEN (AVG(pc1.iVal) > 0 and AVG(pc2.iVal) > 0)  THEN 
				CONVERT(INT,((CAST(AVG(pc3.iVal) AS FLOAT) / (AVG(pc1.iVal) + AVG(pc2.iVal))   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 352 and pc2.MetricID = 357 and pc3.MetricID = 372) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyTotal_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE     VIEW [Analysis].[pcv_IoDiskLatencyTotal_01]
AS

	-- Get Disk Latency Total (All)
	-- MetricID 351=reads  356=writes  371=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			pc1.TimeKey, 
			pc1.iVal AS NumOfReads, 
			pc2.iVal AS NumOfWrites,
			pc3.iVal AS Stall,
			(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
				CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 351 and pc2.MetricID = 356 and pc3.MetricID = 371) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal;
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyTotal_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE     VIEW [Analysis].[pcv_IoDiskLatencyTotal_10]
AS

	-- Get Disk Latency Total (All)
	-- MetricID 351=reads  356=writes  371=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
			AVG(pc1.iVal) AS NumOfReads, 
			AVG(pc2.iVal) AS NumOfWrites,
			AVG(pc3.iVal) AS Stall,
			(CASE WHEN (AVG(pc1.iVal) > 0 and AVG(pc2.iVal) > 0)  THEN 
				CONVERT(INT,((CAST(AVG(pc3.iVal) AS FLOAT) / (AVG(pc1.iVal) + AVG(pc2.iVal))   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 351 and pc2.MetricID = 356 and pc3.MetricID = 371) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyUserDb_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE     VIEW [Analysis].[pcv_IoDiskLatencyUserDb_01]
AS

	-- Get Disk Latency User DBs
	-- MetricID 353=reads  358=writes  373=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			pc1.TimeKey, 
			pc1.iVal AS NumOfReads, 
			pc2.iVal AS NumOfWrites,
			pc3.iVal AS Stall,
			(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
				CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 353 and pc2.MetricID = 358 and pc3.MetricID = 373) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal;
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyUserDb_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE     VIEW [Analysis].[pcv_IoDiskLatencyUserDb_10]
AS

	-- Get Disk Latency User DBs
	-- MetricID 353=reads  358=writes  373=stall
	SELECT  pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
			AVG(pc1.iVal) AS NumOfReads, 
			AVG(pc2.iVal) AS NumOfWrites,
			AVG(pc3.iVal) AS Stall,
			(CASE WHEN (AVG(pc1.iVal) > 0 and AVG(pc2.iVal) > 0)  THEN 
				CONVERT(INT,((CAST(AVG(pc3.iVal) AS FLOAT) / (AVG(pc1.iVal) + AVG(pc2.iVal))   ))) 
				ELSE 0 END) AS DiscLatencyMs
	FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
					ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
					ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
					and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
	WHERE (pc1.MetricID = 353 and pc2.MetricID = 358 and pc3.MetricID = 373) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskReadBytesSecTotal_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE     VIEW [Analysis].[pcv_IoDiskReadBytesSecTotal_10]
AS
	-- MetricID: 361 - Virtual File IO: Num of Bytes Read (Total)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS ReadBytes, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 361) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskReadBytesSecSysDb_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE     VIEW [Analysis].[pcv_IoDiskReadBytesSecSysDb_10]
AS
	-- MetricID: 362 - Virtual File IO: Num of Bytes Read (Sys DBs)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS ReadBytes, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 362) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskReadBytesSecUserDb_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE     VIEW [Analysis].[pcv_IoDiskReadBytesSecUserDb_10]
AS
	-- MetricID: 363 - Virtual File IO: Num of Bytes Read (User DBs)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS ReadBytesCounter, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 363) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskReadBytesSecDbLog_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE     VIEW [Analysis].[pcv_IoDiskReadBytesSecDbLog_10]
AS
	-- MetricID: 364 - Virtual File IO: Num of Bytes Read (Log files)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS ReadBytes, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 364) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskReadBytesSecTempDb_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE     VIEW [Analysis].[pcv_IoDiskReadBytesSecTempDb_10]
AS
	-- MetricID: 365 - Virtual File IO: Num of Bytes Read (TempDb)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS ReadBytes, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 365) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskWriteBytesSecTotal_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [Analysis].[pcv_IoDiskWriteBytesSecTotal_10]
AS
	-- MetricID: 366 - Virtual File IO: Num of Bytes Write (Total)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS WriteBytesCounter, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey,  LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 366) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskWriteBytesSecSysDb_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [Analysis].[pcv_IoDiskWriteBytesSecSysDb_10]
AS
	-- MetricID: 367 - Virtual File IO: Num of Bytes Write (Sys DBs)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS WriteBytesCounter, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey,  LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 367) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskWriteBytesSecUserDb_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [Analysis].[pcv_IoDiskWriteBytesSecUserDb_10]
AS
	-- MetricID: 368 - Virtual File IO: Num of Bytes Write (User DBs)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS WriteBytesCounter, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey,  LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 368) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskWriteBytesSecDbLog_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE    VIEW [Analysis].[pcv_IoDiskWriteBytesSecDbLog_10]
AS
	-- MetricID: 369 - Virtual File IO: Num of Bytes Write (Log files)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS WriteBytesCounter, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey,  LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 369) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_IoDiskWriteBytesSecTempDb_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [Analysis].[pcv_IoDiskWriteBytesSecTempDb_10]
AS
	-- MetricID: 370 - Virtual File IO: Num of Bytes Write (TempDb)
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey,
					MAX(pc1.iVal) AS WriteBytesCounter, 	
					LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)) As MyLag,
					(MAX(pc1.iVal) - (LAG(MAX(pc1.iVal),1) OVER ( ORDER BY pc1.LocationID, pc1.ClusterID, pc1.DateKey,  LEFT(pc1.TimeKey,3))) ) / 600 AS BytesSec   -- 10 minutes = 600 sec
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
			WHERE	(pc1.MetricID = 370) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3)	
			) gr
	WHERE gr.MyLag IS NOT NULL
	 
GO
/****** Object:  View [Analysis].[pcv_DiskUsage_WatchList]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE       VIEW [Analysis].[pcv_DiskUsage_WatchList]
AS

	-- A list of drive letters to watch with less than 30% free
	-- MetricID 313
	SELECT q.LocationID, q.ClusterID, DateKey, STRING_AGG(PartName,', ') AS DiscWatchList
	FROM
			(select LocationID, ClusterID, DateKey, LEFT(PartName,1) AS PartName
			FROM [Analysis].[PerfCounterStats]  WITH(NOLOCK) 
			WHERE MetricID = 313 and Datekey = CONVERT(VARCHAR(10), GETDATE(),112)
			GROUP BY LocationID, ClusterID, DateKey, LEFT(PartName,1)
			HAVING MIN(dVal) < 30
			) as q
	GROUP BY LocationID, ClusterID, DateKey;

GO
/****** Object:  View [Analysis].[pcv_SignalWaits_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







create    VIEW [Analysis].[pcv_SignalWaits_Latest]
AS

	-- Get CPU Percentage Use Latest
	-- MetricID 447 =  OS Wait Stats: Signal Waits CPU %
	SELECT *
	FROM (
			SELECT	pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					pc1.TimeKey, 
					AVG(pc1.iVal) AS SignalWaits,
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1
			WHERE	pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112) and pc1.MetricID = 447
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey) gr
	WHERE gr.RowCt = 1;

GO
/****** Object:  View [Analysis].[pcv_IoDiskLatencyUserDb_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE     VIEW [Analysis].[pcv_IoDiskLatencyUserDb_Latest]
AS

	-- Get Disk Latency User DBs
	-- MetricID 353=reads  358=writes  373=stall
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					pc1.TimeKey, 
					pc1.iVal AS NumOfReads, 
					pc2.iVal AS NumOfWrites,
					pc3.iVal AS Stall,
					(CASE WHEN (pc1.iVal > 0 and pc2.iVal > 0)  THEN 
						CONVERT(INT,((CAST(pc3.iVal AS FLOAT) / (pc1.iVal + pc2.iVal)   ))) 
						ELSE 0 END) AS DiscLatencyMs,					
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1  WITH(NOLOCK)
					INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK)
							ON pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
							and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
					INNER JOIN Analysis.PerfCounterStats as pc3 WITH(NOLOCK)
							ON pc1.LocationID = pc3.LocationID and pc1.ClusterID = pc3.ClusterID
							and pc1.DateKey = pc3.DateKey and pc1.TimeKey = pc3.TimeKey
			WHERE  (pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112)) and (pc1.MetricID = 353 and pc2.MetricID = 358 and pc3.MetricID = 373) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc3.iVal) gr
	WHERE gr.RowCt = 1;
	 
GO
/****** Object:  View [Analysis].[pcv_MemoryInstUsage_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   VIEW [Analysis].[pcv_MemoryInstUsage_Latest]
AS

	-- Get CPU Percentage Use by one (1) minute interval
	-- MetricID 322 = SQL Memory: Total Size MBs | 321 = SQL Memory: Available Space MBs
	SELECT *
	FROM (
			SELECT	pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey,  
					pc1.TimeKey, 
					pc1.iVal AS MemoryInstAvailable, 
					pc2.iVal AS MemoryInstTotal,
					(pc2.iVal - pc1.iVal) AS MemoryInstInUse,
					(CASE WHEN pc2.iVal > 0 THEN
						CONVERT(INT,(((CAST(pc2.iVal AS FLOAT)-CAST(pc1.iVal AS FLOAT)) / pc2.iVal)*100)) 
						ELSE 0 END)AS MemoryInstPercentInUse,
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1
					INNER JOIN Analysis.PerfCounterStats as pc2 ON 
							pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
							and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			WHERE	(pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112)) and(pc1.MetricID = 322 and pc2.MetricID = 321) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal) gr
	WHERE gr.RowCt = 1;

GO
/****** Object:  View [Analysis].[pcv_DiskUsage_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE        VIEW [Analysis].[pcv_DiskUsage_Latest]
AS

	-- Get CPU Percentage Use by one (1) minute interval
	-- MetricID 311 = Server Drive: Total Size MBs   | 312 = Server Drive: Available Space MBs
	SELECT *
	FROM (
			SELECT	pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey,  
					pc1.TimeKey, 
					SUM(pc1.iVal) AS DiskSpaceAvailable, 
					SUM(pc2.iVal) AS DiskSpaceTotal,
					(SUM(pc2.iVal) - SUM(pc1.iVal)) AS DiskSpaceInUse,
					(CASE WHEN SUM(pc2.iVal) > 0 THEN
						CONVERT(INT,(((CAST(SUM(pc2.iVal) AS FLOAT)-CAST(SUM(pc1.iVal) AS FLOAT)) / SUM(pc2.iVal))*100)) 
						ELSE 0 END)AS DiskSpacePercentInUse,
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1
					INNER JOIN Analysis.PerfCounterStats as pc2 ON 
							pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
							and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			WHERE	(pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112)) and (pc1.MetricID = 312 and pc2.MetricID = 311)
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey) gr
	WHERE gr.RowCt = 1;

GO
/****** Object:  View [Analysis].[pcv_InstanceLastRestart]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE     VIEW [Analysis].[pcv_InstanceLastRestart]
AS
			SELECT	LocationID, ClusterID, MAX(UtcDate) AS UtcDate,
					MAX(CONVERT(datetime,PartName)) AS LastRestartDate,	
					CONCAT(
						((DATEDIFF(second,MAX(CONVERT(datetime,PartName)),GetUtcDate()))  / 3600 / 24)
						,' DAYS '
						,(DATEDIFF(second,MAX(CONVERT(datetime,PartName)),GetUtcDate()))  / 3600  % 24
						,' HRS '
						,(DATEDIFF(second,MAX(CONVERT(datetime,PartName)),GetUtcDate()))  / 60 % 60
						,' MIN '
						) AS RunDuration
			FROM	Analysis.PerfCounterStats WITH(NOLOCK)
			WHERE	(DateKey =  CONVERT(VARCHAR(10), GETDATE(),112)) and (MetricID = 201) 
			GROUP BY LocationID, ClusterID;


	 
GO
/****** Object:  View [Analysis].[pcv_DiskDriveUsageHistory_10day]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE      VIEW [Analysis].[pcv_DiskDriveUsageHistory_10day]
AS

	SELECT *
	FROM (
			SELECT	pc1.LocationID, 
								pc1.ClusterID, 
								pc1.DateKey,  
								pc1.iVal AS DiskSpaceAvailable, 
								pc2.iVal AS DiskSpaceTotal,
								(pc2.iVal - pc1.iVal) AS DiskSpaceInUse,
								REPLACE(pc1.PartName,' ()','') AS PartName,
								(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID, pc1.ClusterID, pc1.PartName, pc1.DateKey  ORDER BY pc1.PartName, pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
						FROM	Analysis.PerfCounterStats as pc1 WITH(NOLOCK)
								INNER JOIN Analysis.PerfCounterStats as pc2  WITH(NOLOCK) ON 
										pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
										and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
										and pc1.PartName = pc2.PartName
						WHERE	(pc1.DateKey >= CONVERT(VARCHAR(10), DATEADD(day,-9,GETUTCDATE()),112)) 
						and (pc1.MetricID = 312 and pc2.MetricID = 311)
						--and pc1.LocationID = 101874 and pc1.ClusterID = 704
						GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc1.PartName
			) gr
	WHERE gr.RowCt = 1;

GO
/****** Object:  View [Analysis].[pcv_DiskDriveUsageHistory_30day]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE      VIEW [Analysis].[pcv_DiskDriveUsageHistory_30day]
AS

	SELECT *
	FROM (
			SELECT	pc1.LocationID, 
								pc1.ClusterID, 
								pc1.DateKey,  
								pc1.iVal AS DiskSpaceAvailable, 
								pc2.iVal AS DiskSpaceTotal,
								(pc2.iVal - pc1.iVal) AS DiskSpaceInUse,
								REPLACE(pc1.PartName,' ()','') AS PartName,
								(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID, pc1.ClusterID, pc1.PartName, pc1.DateKey  ORDER BY pc1.PartName, pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
						FROM	Analysis.PerfCounterStats as pc1 WITH(NOLOCK)
								INNER JOIN Analysis.PerfCounterStats as pc2  WITH(NOLOCK) ON 
										pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
										and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
										and pc1.PartName = pc2.PartName
						WHERE	(pc1.DateKey >= CONVERT(VARCHAR(10), DATEADD(day,-29,GETUTCDATE()),112)) 
						and (pc1.MetricID = 312 and pc2.MetricID = 311)
						--and pc1.LocationID = 101874 and pc1.ClusterID = 704
						GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc1.PartName
			) gr
	WHERE gr.RowCt = 1;

GO
/****** Object:  View [Analysis].[pcv_DiskDriveUsageHistory]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE      VIEW [Analysis].[pcv_DiskDriveUsageHistory]
AS

	SELECT *
	FROM (
			SELECT	pc1.LocationID, 
								pc1.ClusterID, 
								pc1.DateKey,  
								pc1.iVal AS DiskSpaceAvailable, 
								pc2.iVal AS DiskSpaceTotal,
								(pc2.iVal - pc1.iVal) AS DiskSpaceInUse,
								REPLACE(pc1.PartName,' ()','') AS PartName,
								(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID, pc1.ClusterID, pc1.PartName, pc1.DateKey  ORDER BY pc1.PartName, pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
						FROM	Analysis.PerfCounterStats as pc1 WITH(NOLOCK)
								INNER JOIN Analysis.PerfCounterStats as pc2  WITH(NOLOCK) ON 
										pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
										and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
										and pc1.PartName = pc2.PartName
						WHERE	(pc1.DateKey = CONVERT(VARCHAR(10), DATEADD(day,-9,GETUTCDATE()),112))  
						and (pc1.MetricID = 312 and pc2.MetricID = 311)
						GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal, pc1.PartName
			) gr
	WHERE gr.RowCt = 1;

GO
/****** Object:  View [Analysis].[pcv_OsCpuUsagePercent_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE       VIEW [Analysis].[pcv_OsCpuUsagePercent_Latest]
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
/****** Object:  View [Analysis].[pcv_OsCpuUsagePercent_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE       VIEW [Analysis].[pcv_OsCpuUsagePercent_01]
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
/****** Object:  View [Analysis].[pcv_OsCpuUsagePercent_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE       VIEW [Analysis].[pcv_OsCpuUsagePercent_10]
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
/****** Object:  View [Analysis].[pcv_CpuUsagePercent_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE      VIEW [Analysis].[pcv_CpuUsagePercent_01]
AS

	-- Get CPU Percentage Use by minute interval
	-- MetricID 439 = OS Perf Counter: CPU usage % | 440 = OS Perf Counter: CPU usage % base
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			pc1.TimeKey, 
			pc1.iVal AS iVal1, 
			pc2.iVal AS iVal2,
			(CASE WHEN pc2.iVal > 0 THEN 
				CONVERT(INT,((CAST(pc1.iVal AS FLOAT) / pc2.iVal))*100) 
				ELSE 0 END) AS iValResult
	FROM	Analysis.PerfCounterStats as pc1
			INNER JOIN Analysis.PerfCounterStats as pc2 ON 
					pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
	WHERE (pc1.MetricID = 439 and pc2.MetricID = 440)
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc2.TimeKey, pc1.iVal, pc2.iVal;

GO
/****** Object:  View [Analysis].[pcv_CpuUsagePercent_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE      VIEW [Analysis].[pcv_CpuUsagePercent_10]
AS

	-- Get CPU Percentage Use by ten (10) minute interval
	-- MetricID 439 = OS Perf Counter: CPU usage % | 440 = OS Perf Counter: CPU usage % base
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey, 
			AVG(pc1.iVal) AS iVal1, 
			AVG(pc2.iVal) AS iVal2,
			(CASE WHEN AVG(pc2.iVal) > 0 THEN
				CONVERT(INT,((CAST(AVG(pc1.iVal) AS FLOAT) / AVG(pc2.iVal)))*100) 
				ELSE 0 END)AS iValResult
	FROM	Analysis.PerfCounterStats as pc1
			INNER JOIN Analysis.PerfCounterStats as pc2 ON 
					pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
	WHERE (pc1.MetricID = 439 and pc2.MetricID = 440)
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);

GO
/****** Object:  View [Analysis].[pcv_CpuUsagePercent_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE     VIEW [Analysis].[pcv_CpuUsagePercent_Latest]
AS

	-- Get LATEST (only) CPU Percentage Use by Location/cluster
	-- MetricID 439 = OS Perf Counter: CPU usage % | 440 = OS Perf Counter: CPU usage % base
	SELECT *
	FROM (
			SELECT  pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					pc1.TimeKey,
					pc1.UtcDate,
					pc1.iVal AS iVal1, 
					pc2.iVal AS iVal2,
					(CASE WHEN pc2.iVal > 0 THEN 
						CONVERT(INT,((CAST(pc1.iVal AS FLOAT) / pc2.iVal))*100) 
						ELSE 0 END) AS iValResult,
						(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1 WITH(NOLOCK)
					INNER JOIN Analysis.PerfCounterStats as pc2 WITH(NOLOCK) ON
							pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
							and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			WHERE (pc1.MetricID = 439 and pc2.MetricID = 440) and (pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112))
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.UtcDate, pc1.iVal, pc2.iVal) gr
	WHERE gr.RowCt = 1;
	 
GO
/****** Object:  View [Analysis].[pcv_MemoryInstUsage_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE     VIEW [Analysis].[pcv_MemoryInstUsage_10]
AS

	-- Get CPU Percentage Use by ten (10) minute interval
	-- MetricID 321 = Server Memory: Total Size MBs | 322 = Server Memory: Available Space MBs
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey, 
			AVG(pc1.iVal) AS MemoryInstAvailable, 
			AVG(pc2.iVal) AS MemoryInstTotal,
			AVG(pc2.iVal) - AVG(pc1.iVal) AS MemoryInstInUse,
			(CASE WHEN AVG(pc2.iVal) > 0 THEN
				CONVERT(INT,(((CAST(AVG(pc2.iVal) AS FLOAT)-CAST(AVG(pc1.iVal) AS FLOAT)) / AVG(pc2.iVal))*100)) 
				ELSE 0 END)AS MemoryInstPercentInUse
	FROM	Analysis.PerfCounterStats as pc1
			INNER JOIN Analysis.PerfCounterStats as pc2 ON 
					pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
	WHERE (pc1.MetricID = 322 and pc2.MetricID = 321) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);

GO
/****** Object:  View [Analysis].[pcv_MemorySqlUsage_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     VIEW [Analysis].[pcv_MemorySqlUsage_10]
AS

	-- Get CPU Percentage Use by ten (10) minute interval
	-- MetricID 482 = SQL Memory: Total Size MBs | 481 = SQL Memory: Available Space MBs
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey, 
			AVG(pc1.iVal) AS MemorySqlAvailable, 
			AVG(pc2.iVal) AS MemorySqlTotal,
			AVG(pc2.iVal) - AVG(pc1.iVal) AS MemorySqlInUse,
			(CASE WHEN AVG(pc2.iVal) > 0 THEN
				CONVERT(INT,(((CAST(AVG(pc2.iVal) AS FLOAT)-CAST(AVG(pc1.iVal) AS FLOAT)) / AVG(pc2.iVal))*100)) 
				ELSE 0 END)AS MemorySqlPercentInUse
	FROM	Analysis.PerfCounterStats as pc1
			INNER JOIN Analysis.PerfCounterStats as pc2 ON 
					pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
	WHERE (pc1.MetricID = 482 and pc2.MetricID = 481)
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);

GO
/****** Object:  View [Analysis].[pcv_MemorySqlUsage_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [Analysis].[pcv_MemorySqlUsage_01]
AS

	-- Get CPU Percentage Use by one (1) minute interval
	-- MetricID 482 = SQL Memory: Total Size MBs | 481 = SQL Memory: Available Space MBs
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey,  
			pc1.TimeKey, 
			pc1.iVal AS MemorySqlAvailable, 
			pc2.iVal AS MemorySqlTotal,
			(pc2.iVal - pc1.iVal) AS MemorySqlInUse,
			(CASE WHEN pc2.iVal > 0 THEN
				CONVERT(INT,(((CAST(pc2.iVal AS FLOAT)-CAST(pc1.iVal AS FLOAT)) / pc2.iVal)*100)) 
				ELSE 0 END)AS MemorySqlPercentInUse
	FROM	Analysis.PerfCounterStats as pc1
			INNER JOIN Analysis.PerfCounterStats as pc2 ON 
					pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
	WHERE (pc1.MetricID = 482 and pc2.MetricID = 481)
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal;

GO
/****** Object:  View [Analysis].[pcv_MemoryInstUsage_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE     VIEW [Analysis].[pcv_MemoryInstUsage_01]
AS

	-- Get CPU Percentage Use by one (1) minute interval
	-- MetricID 322 = SQL Memory: Total Size MBs | 321 = SQL Memory: Available Space MBs
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey,  
			pc1.TimeKey, 
			pc1.iVal AS MemoryInstAvailable, 
			pc2.iVal AS MemoryInstTotal,
			(pc2.iVal - pc1.iVal) AS MemoryInstInUse,
			(CASE WHEN pc2.iVal > 0 THEN
				CONVERT(INT,(((CAST(pc2.iVal AS FLOAT)-CAST(pc1.iVal AS FLOAT)) / pc2.iVal)*100)) 
				ELSE 0 END)AS MemoryInstPercentInUse
	FROM	Analysis.PerfCounterStats as pc1
			INNER JOIN Analysis.PerfCounterStats as pc2 ON 
					pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
					and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
	WHERE (pc1.MetricID = 322 and pc2.MetricID = 321) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal;

GO
/****** Object:  View [Analysis].[pcv_MemorySqlUsage_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [Analysis].[pcv_MemorySqlUsage_Latest]
AS

	-- Get CPU Percentage Use by one (1) minute interval
	-- MetricID 482 = SQL Memory: Total Size MBs | 481 = SQL Memory: Available Space MBs
	SELECT *
	FROM (
			SELECT	pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey,  
					pc1.TimeKey, 
					pc1.iVal AS MemorySqlAvailable, 
					pc2.iVal AS MemorySqlTotal,
					(pc2.iVal - pc1.iVal) AS MemorySqlInUse,
					(CASE WHEN pc2.iVal > 0 THEN
						CONVERT(INT,(((CAST(pc2.iVal AS FLOAT)-CAST(pc1.iVal AS FLOAT)) / pc2.iVal)*100)) 
						ELSE 0 END)AS MemorySqlPercentInUse,
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1
					INNER JOIN Analysis.PerfCounterStats as pc2 ON 
							pc1.LocationID = pc2.LocationID and pc1.ClusterID = pc2.ClusterID
							and pc1.DateKey = pc2.DateKey and pc1.TimeKey = pc2.TimeKey
			WHERE (pc1.MetricID = 482 and pc2.MetricID = 481) and (pc1.DateKey =  CONVERT(VARCHAR(10), GETDATE(),112))
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey, pc1.iVal, pc2.iVal) gr
	WHERE gr.RowCt = 1;

GO
/****** Object:  View [Analysis].[pcv_DiskUsage_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE       VIEW [Analysis].[pcv_DiskUsage_01]
AS

	-- Get CPU Percentage Use by one (1) minute or PULL DEFINED interval
	-- MetricID 311 = Server Drive: Total Size MBs   | 312 = Server Drive: Available Space MBs
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey,  
			pc1.TimeKey, 
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
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey

GO
/****** Object:  View [Analysis].[pcv_DiskUsage_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     VIEW [Analysis].[pcv_DiskUsage_10]
AS

	-- Get CPU Percentage Use by PULLED minute interval
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
/****** Object:  View [Analysis].[pcv_WaitDurationMs_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE    VIEW [Analysis].[pcv_WaitDurationMs_10]
AS

	-- Get CPU Percentage Use by PULLED minute interval
	-- MetricID 446 = OS Wait Stats: Wait Duration/ms
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey, 
			SUM(pc1.iVal) AS WaitTotal,
			AVG(pc1.iVal) AS WaitAverage
	FROM	Analysis.PerfCounterStats as pc1
	WHERE (pc1.MetricID = 446) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);

GO
/****** Object:  View [Analysis].[pcv_WaitDurationMs_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE    VIEW [Analysis].[pcv_WaitDurationMs_01]
AS

	-- Get CPU Percentage Use by 1 minute interval
	-- MetricID 446 = OS Wait Stats: Wait Duration/ms
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			pc1.TimeKey, 
			SUM(pc1.iVal) AS WaitTotal,
			AVG(pc1.iVal) AS WaitAverage
	FROM	Analysis.PerfCounterStats as pc1
	WHERE (pc1.MetricID = 446) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey;

GO
/****** Object:  View [Analysis].[pcv_WaitDurationMs_Latest]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE    VIEW [Analysis].[pcv_WaitDurationMs_Latest]
AS

	-- Get CPU Percentage Use Latest
	-- MetricID 446 = OS Wait Stats: Wait Duration/ms
	SELECT *
	FROM (
			SELECT	pc1.LocationID, 
					pc1.ClusterID, 
					pc1.DateKey, 
					pc1.TimeKey, 
					SUM(pc1.iVal) AS WaitTotal,
					AVG(pc1.iVal) AS WaitAverage,
					(ROW_NUMBER() OVER(PARTITION BY pc1.LocationID,pc1.ClusterID  ORDER BY pc1.DateKey DESC, pc1.TimeKey DESC)) AS RowCt
			FROM	Analysis.PerfCounterStats as pc1
			WHERE (pc1.MetricID = 446) 
			GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey) gr
	WHERE gr.RowCt = 1;

GO
/****** Object:  View [Analysis].[pcv_SignalWaits_01]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Analysis].[pcv_SignalWaits_01]
AS

	-- Get CPU Percentage Use by 1 minute interval
	-- MetricID 447 =  OS Wait Stats: Signal Waits CPU %
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			pc1.TimeKey, 
			AVG(pc1.iVal) AS SignalWaits
	FROM	Analysis.PerfCounterStats as pc1
	WHERE (pc1.MetricID = 447) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, pc1.TimeKey;

GO
/****** Object:  View [Analysis].[pcv_SignalWaits_10]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE    VIEW [Analysis].[pcv_SignalWaits_10]
AS

	-- Get CPU Percentage Use by PULLED minute interval
	-- MetricID 447 =  OS Wait Stats: Signal Waits CPU %
	SELECT	pc1.LocationID, 
			pc1.ClusterID, 
			pc1.DateKey, 
			CONCAT(LEFT(pc1.TimeKey,3),'000') AS TimeKey, 
			MAX(pc1.iVal) AS SignalWaits
	FROM	Analysis.PerfCounterStats as pc1
	WHERE (pc1.MetricID = 447) 
	GROUP BY pc1.LocationID, pc1.ClusterID, pc1.DateKey, LEFT(pc1.TimeKey,3);

GO
/****** Object:  Table [Analysis].[PerfCounterMetric]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Analysis].[PerfCounterMetric](
	[MetricID] [int] IDENTITY(1,1) NOT NULL,
	[MetricIntervalMinutes] [int] NOT NULL,
	[MetricName] [varchar](150) NULL,
	[MetricDurationDesc] [varchar](50) NULL,
	[MetricSubName] [varchar](250) NULL,
	[MetricTsql] [varchar](max) NULL,
 CONSTRAINT [PK_PerfCounterMetric] PRIMARY KEY CLUSTERED 
(
	[MetricID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Analysis].[PerfCounterStatsSnapshot]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Analysis].[PerfCounterStatsSnapshot](
	[SnapshotID] [int] IDENTITY(1,1) NOT NULL,
	[ID] [int] NULL,
	[LocationID] [int] NULL,
	[ClusterID] [int] NULL,
	[MetricID] [int] NULL,
	[PartName] [varchar](250) NULL,
	[DateKey] [int] NULL,
	[TimeKey] [char](6) NULL,
	[iVal] [bigint] NULL,
	[dVal] [decimal](10, 4) NULL,
	[UtcDate] [datetime] NULL,
 CONSTRAINT [PK_PerfCounterStatsSnapshot] PRIMARY KEY CLUSTERED 
(
	[SnapshotID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Analysis].[PerfLocation]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Analysis].[PerfLocation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LocationID] [int] NOT NULL,
	[ClusterID] [int] NOT NULL,
	[ServerID] [int] NOT NULL,
	[LocationName] [varchar](150) NULL,
	[ClusterName] [varchar](150) NULL,
	[ServerName] [varchar](150) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_PerfLocation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Analysis].[Server]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Analysis].[Server](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[ServerNm] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[connString] [varbinary](1500) NULL,
	[RAMmb] [int] NULL,
	[QueryStoreVersion] [int] NULL,
	[ServerResolvedName] [varchar](50) NULL,
	[IsCurrent] [bit] NULL,
	[LocationID] [int] NULL,
	[ClusterID] [int] NULL,
	[LocationName] [nvarchar](50) NULL,
	[ClusterName] [nvarchar](50) NULL,
	[ClusterServerID] [int] NULL,
	[PerfLocationID] [int] NULL,
 CONSTRAINT [PK_Server] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Analysis].[PerfCounterStats] ADD  CONSTRAINT [DF_PerfCounterStats_PartName]  DEFAULT ('') FOR [PartName]
GO
ALTER TABLE [Analysis].[Server] ADD  CONSTRAINT [DF_Server_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Instance_Overview]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220901
-- Based on  [Analysis].[PerfCounter_Rpt_Overview]
-- =============================================
CREATE     PROCEDURE [Analysis].[PerfCounter_Rpt_Instance_Overview] 
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

	-- Signnal Waits
	UPDATE r
	SET SignalWaits = ISNULL(sig.SignalWaits,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_SignalWaits_Latest sig  on sig.locationID = r.LocationID and sig.ClusterID = r.ClusterID;

	-- DiscLatency Ms
	UPDATE r
	SET DiscLatencyMs =  ISNULL(dlat.DiscLatencyMs,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_IoDiskLatencyTotal_Latest dlat on dlat.locationID = r.LocationID and dlat.ClusterID = r.ClusterID;
	
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
/****** Object:  StoredProcedure [Analysis].[PerfCounter_Rpt_Overview]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220901
-- =============================================
CREATE   PROCEDURE [Analysis].[PerfCounter_Rpt_Overview]
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

	-- Signnal Waits
	UPDATE r
	SET SignalWaits = ISNULL(sig.SignalWaits,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_SignalWaits_Latest sig  on sig.locationID = r.LocationID and sig.ClusterID = r.ClusterID;

	-- DiscLatency Ms
	UPDATE r
	SET DiscLatencyMs =  ISNULL(dlat.DiscLatencyMs,0)
	FROM @results AS r
	INNER JOIN Analysis.pcv_IoDiskLatencyTotal_Latest dlat on dlat.locationID = r.LocationID and dlat.ClusterID = r.ClusterID;
	
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
/****** Object:  StoredProcedure [Analysis].[PerfCounterCleanup]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220725
-- =============================================
CREATE   PROCEDURE [Analysis].[PerfCounterCleanup]
@DaysToKeep int
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @iDate int;
	DECLARE @dDate datetime;

	SELECT  @iDate = CONVERT(VARCHAR(10), DATEADD(day,(0-@DaysToKeep),GETUTCDATE()),112), 
			@dDate = DATEADD(day,(0-(@DaysToKeep*2)),GETUTCDATE());

	BEGIN TRY
		DELETE FROM [Analysis].[PerfCounterLog] WHERE DateKey < @iDate;
	END TRY
	BEGIN CATCH
		PRINT 'Table not found.'
	END CATCH;

	BEGIN TRY
		DELETE FROM [Analysis].[PerfCounterLogActions] WHERE RunStartUtc < @dDate;
	END TRY
	BEGIN CATCH
		PRINT 'Table not found.'
	END CATCH;


END
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounterCleanupDw]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220725
-- =============================================
CREATE PROCEDURE [Analysis].[PerfCounterCleanupDw]
@DaysToKeep int
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @iDate int;
	DECLARE @dDate datetime;

	SELECT  @iDate = CONVERT(VARCHAR(10), DATEADD(day,(0-@DaysToKeep),GETUTCDATE()),112), 
			@dDate = DATEADD(day,(0-(@DaysToKeep*2)),GETUTCDATE());

	BEGIN TRY
		DELETE FROM [Analysis].[PerfCounterStats] WHERE DateKey < @iDate;
	END TRY
	BEGIN CATCH
		PRINT 'Table not found.'
	END CATCH;


END
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounterMetricIntervalInsertJob]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220719
-- =============================================
CREATE PROCEDURE [Analysis].[PerfCounterMetricIntervalInsertJob]
@Interval int
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @iDate int;
	DECLARE @vTime char(6);
	DECLARE @Server varchar(150);
	DECLARE @tSQL varchar(max);
	DECLARE @iCount int=0;
	DECLARE @curMetricID int=0;
	DECLARE @tList TABLE (ID INT NOT NULL IDENTITY(1,1), MetricID INT);

	INSERT INTO @tList
	SELECT MetricID FROM [Analysis].[PerfCounterMetric] WHERE MetricIntervalMinutes =@Interval and MetricTsql is not null;
	SELECT @iCount = MAX(ID) FROM @tList;
	SELECT @Server = @@SERVERNAME, @iDate = CONVERT(VARCHAR(10), GETUTCDATE(),112), @vTime = REPLACE(CONVERT(VARCHAR(10), GETUTCDATE(),108),':','');

	WHILE @iCount > 0
	BEGIN
		SELECT @curMetricID = MetricID FROM @tList WHERE ID = @iCount;

		select @tSQL = REPLACE(REPLACE(REPLACE(MetricTsql,'[REPLACEiDate]',@iDate),'[REPLACEvTime]',@vTime),'[REPLACEserver]',@Server)
		FROM [Analysis].[PerfCounterMetric] WHERE MetricID = @curMetricID; 
		EXEC (@tSQL);

		SELECT @curMetricID=0, @iCount=@iCount-1;
	END;

END
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounterSnapshot]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Speight
-- Create date: 20220902
-- =============================================
CREATE PROCEDURE [Analysis].[PerfCounterSnapshot] 
@DateKey varchar(24) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT @DateKey =	(CASE	WHEN LEN(@DateKey) > 5 THEN @DateKey 
								ELSE REPLACE(EOMONTH(getutcdate(),-1),'-','') END) -- Last Day of previous month


	INSERT INTO [Analysis].[PerfCounterStatsSnapshot]
			([ID], [LocationID], [ClusterID], [MetricID], [PartName], [DateKey], [TimeKey], [iVal], [dVal], [UtcDate])
    SELECT	[ID], [LocationID], [ClusterID], p.[MetricID], [PartName], [DateKey], [TimeKey], [iVal], [dVal], [UtcDate]
	FROM	Analysis.PerfCounterMetric as m WITH(NOLOCK)
			inner join Analysis.PerfCounterStats as p WITH(NOLOCK) on m.MetricID = p.MetricID
	WHERE	m.MetricTsql is not null
			AND p.DateKey = CONVERT(INT,@DateKey)
			AND (m.MetricIntervalMinutes > 1 OR SUBSTRING(p.TimeKey,3,2) = '00')
	ORDER BY [LocationID], [ClusterID], p.[MetricID], [DateKey], [TimeKey];

END
GO
/****** Object:  StoredProcedure [Analysis].[PerfCounterStats_PerSecondGet]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Analysis].[PerfCounterStats_PerSecondGet]
@LocationID int,
@ClusterID int,
@MetricID int,
@DateKey int
AS

SELECT	q.LocationID, q.ClusterID, 
		p.ClusterName AS InstanceName,
		MetricID, PartName, DateKey, TimeKey, UtcDate, iVal, iValDiff, TotalMinutes*60 AS TotalSeconds,
		(CASE WHEN iValDiff > 0 and TotalMinutes > 0 THEN (iValDiff) / (TotalMinutes*60) ELSE iValDiff END) AS  iValResult
FROM			(SELECT 
				LocationID, ClusterID, MetricID, PartName, DateKey, TimeKey, UtcDate, iVal, 
				-- In this Metric, SQL keeps a runnning total, so we will compute the differnce between the current row value and the previous row value
				(iVal - (LAG(iVal,1,0) OVER (ORDER BY DateKey, TimeKey ASC)) ) AS iValDiff,
				TRY_CONVERT(int, DATEDIFF(minute, (LAG(UtcDate,1,0) OVER (ORDER BY DateKey, TimeKey ASC)),  UtcDate)   )  AS TotalMinutes
				FROM Analysis.PerfCounterStats
				WHERE 
					LocationID = @LocationID
					and ClusterID = @ClusterID
					and MetricID = @MetricID
					and DateKey >= @DateKey
				) as q
INNER JOIN Analysis.PerfLocation p ON q.LocationID = p.LocationID AND q.ClusterID = p.ClusterID
WHERE	iVal != iValDiff 
		and TotalMinutes < 35791383; -- integer overflow safety
GO
/****** Object:  StoredProcedure [Analysis].[ServerCurrentUpdate]    Script Date: 10/12/2022 10:55:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [Analysis].[ServerCurrentUpdate]
@Servername VARCHAR(50) = 'DBSQLRDS01'
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PerfLocationID INT=0;
	
	UPDATE [Analysis].[Server]
	SET IsCurrent = 1
	WHERE  IsCurrent !=1 and ServerNm = @@SERVERNAME;

	UPDATE [Analysis].[Server]
	SET IsCurrent = 0
	WHERE  IsCurrent !=0 and ServerNm != @@SERVERNAME;  

	if (select count(*) from [Analysis].[Server] where ServerNm = @@ServerName) = 0
	begin 
		-- The record shouldve been updated in the ServerAnalysis DB already, so the main table should be updated already.
		SELECT 	@PerfLocationID = id
		FROM Analysis.PerfLocation
		Where ServerName = @@ServerName;

		insert into Analysis.Server ( [ServerNm], [IsActive], [connString], [RAMmb], [QueryStoreVersion], [ServerResolvedName], [IsCurrent], LocationID, LocationName, ClusterName, ClusterServerID, PerfLocationID )
		Select TOP(1) @@ServerName,[IsActive], [connString], [RAMmb], [QueryStoreVersion],  ServerResolvedName, 1, LocationID, LocationName, ClusterName, ClusterServerID, @PerfLocationID
		from Analysis.Server 
		where ServerNm = @Servername;  
	end;

	SELECT TOP (1000) *  FROM [Analysis].[Server];
END
GO
