
/* THIS DATABASE is only located on the instance where all the data is staged before importing into the DW. 
	TESTED on SQL 2017+


*/

USE Master;
CREATE DATABASE [ServerAnalysisDwStaging];
GO




USE [ServerAnalysisDwStaging]
GO
/****** Object:  Schema [Analysis]    Script Date: 10/12/2022 10:57:20 AM ******/
CREATE SCHEMA [Analysis]
GO
/****** Object:  UserDefinedFunction [dbo].[CreateDateTimeFrom2Strings]    Script Date: 10/12/2022 10:57:20 AM ******/
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
/****** Object:  Table [Analysis].[PerfCounterLogStaging]    Script Date: 10/12/2022 10:57:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Analysis].[PerfCounterLogStaging](
	[ID] [varchar](50) NULL,
	[PerfLocationID] [varchar](50) NULL,
	[MetricID] [varchar](50) NULL,
	[DateKey] [varchar](50) NULL,
	[TimeKey] [varchar](50) NULL,
	[iVal] [varchar](50) NULL,
	[dVal] [varchar](50) NULL,
	[PartName] [varchar](250) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Analysis].[PerfCounterMetric]    Script Date: 10/12/2022 10:57:20 AM ******/
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
/****** Object:  Table [Analysis].[PerfCounterStats]    Script Date: 10/12/2022 10:57:20 AM ******/
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
/****** Object:  Table [Analysis].[PerfFileExtractionLog]    Script Date: 10/12/2022 10:57:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Analysis].[PerfFileExtractionLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[ParentID] [int] NULL,
	[ServerName] [varchar](150) NULL,
	[FilPath] [varchar](250) NULL,
	[FileName] [varchar](550) NULL,
	[RunStartUtc] [datetime] NULL,
	[RunEndUtc] [datetime] NULL,
	[RunSuccess] [bit] NULL,
	[RowsAffected] [int] NULL,
	[ErrorCount] [int] NULL,
 CONSTRAINT [PK_PerfFileExtractionLog] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Analysis].[PerfLocation]    Script Date: 10/12/2022 10:57:20 AM ******/
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
 CONSTRAINT [PK_PerfLocation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Analysis].[PerfCounterStats] ADD  CONSTRAINT [DF_PerfCounterStats_PartName]  DEFAULT ('') FOR [PartName]
GO
