USE [PRODUCTION_DATA]
GO

/****** Object:  Table [dbo].[Account]    Script Date: 5/12/2015 1:28:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Account](
	[pkAccountId] [INT] IDENTITY(1,1) NOT NULL,
	[userId] [INT] NOT NULL,
	[currentBalance] [MONEY] NULL,
	[previousBalance] [MONEY] NULL,
	[interestRate] [FLOAT] NULL,
	[isActive] [BIT] NULL,
	[lastModified] [DATETIME2](7) NULL,
 CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED 
(
	[pkAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[Account_Updates]    Script Date: 5/12/2015 1:28:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Table [dbo].[User]    Script Date: 5/12/2015 1:28:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[User](
	[pkId] [INT] NOT NULL,
	[userName] [NCHAR](255) NULL,
	[firstName] [NCHAR](255) NULL,
	[lastName] [NCHAR](255) NULL,
	[passWord] [NCHAR](255) NULL,
	[emailAddress] [NCHAR](255) NULL,
	[lastModified] [DATETIME2](7) NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[pkId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[User_Updates]    Script Date: 5/12/2015 1:28:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


USE [STAGING_DATA]
GO

/****** Object:  Table [dbo].[Account]    Script Date: 5/12/2015 1:28:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Account](
	[pkAccountId] [INT] IDENTITY(1,1) NOT NULL,
	[userId] [INT] NOT NULL,
	[currentBalance] [MONEY] NULL,
	[previousBalance] [MONEY] NULL,
	[interestRate] [FLOAT] NULL,
	[isActive] [BIT] NULL,
	[lastModified] [DATETIME2](7) NULL,
 CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED 
(
	[pkAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[Account_Updates]    Script Date: 5/12/2015 1:28:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Account_Updates](
	[pkAccountId] [INT] IDENTITY(1,1) NOT NULL,
	[userId] [INT] NOT NULL,
	[currentBalance] [MONEY] NULL,
	[previousBalance] [MONEY] NULL,
	[interestRate] [FLOAT] NULL,
	[isActive] [BIT] NULL,
	[lastModified] [DATETIME2](7) NULL,
 CONSTRAINT [PK_Account_Updates] PRIMARY KEY CLUSTERED 
(
	[pkAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[User]    Script Date: 5/12/2015 1:28:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[User](
	[pkId] [INT] NOT NULL,
	[userName] [NCHAR](255) NULL,
	[firstName] [NCHAR](255) NULL,
	[lastName] [NCHAR](255) NULL,
	[passWord] [NCHAR](255) NULL,
	[emailAddress] [NCHAR](255) NULL,
	[lastModified] [DATETIME2](7) NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[pkId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[User_Updates]    Script Date: 5/12/2015 1:28:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[User_Updates](
	[pkId] [INT] NOT NULL,
	[userName] [NCHAR](255) NULL,
	[firstName] [NCHAR](255) NULL,
	[lastName] [NCHAR](255) NULL,
	[passWord] [NCHAR](255) NULL,
	[emailAddress] [NCHAR](255) NULL,
	[lastModified] [DATETIME2](7) NULL,
 CONSTRAINT [PK_User_Updates] PRIMARY KEY CLUSTERED 
(
	[pkId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


