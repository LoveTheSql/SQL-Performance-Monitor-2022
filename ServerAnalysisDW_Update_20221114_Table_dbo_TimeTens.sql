USE [ServerAnalysisDW]
GO

/****** Object:  Table [dbo].[TimeTens]    Script Date: 11/14/2022 2:03:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TimeTens](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[tHour] [int] NULL,
	[tMin] [int] NULL,
	[Time6] [char](6) NULL,
	[Time6s] [char](8) NULL,
	[Time4] [char](4) NULL,
	[Time4s] [char](5) NULL,
	[dtTime] [datetime] NULL
) ON [PRIMARY]
GO


