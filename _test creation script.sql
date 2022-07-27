IF DB_ID('TestLSI') IS NULL 
  CREATE DATABASE  TestLSI COLLATE SQL_Latin1_General_CP1_CI_AS -- in case of DB Administrator took too a lot of beer inside
GO
USE TestLSI
GO

-- create and fill users
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = N'LSIUsers') 
  CREATE TABLE dbo.LSIUsers
  (
	  PersonID INT IDENTITY(1,1) NOT NULL,
	  PersonName NVARCHAR(250) NOT NULL,
  CONSTRAINT PK_PersonID PRIMARY KEY CLUSTERED (PersonID)
  )
GO
INSERT INTO dbo.LSIUsers (PersonName)
VALUES ('A.A. Alef'), ('B.B. Betta'), ('J.J. Delta'), ('E. E. Ernst');
GO

-- create and fill lokals
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = N'LSILokals') 
  CREATE TABLE dbo.LSILokals
  (
	  LokalID INT IDENTITY(1,1) NOT NULL,
	  LokalName NVARCHAR(250) NOT NULL,
  CONSTRAINT PK_LokalID PRIMARY KEY CLUSTERED (LokalID)
  )
GO
INSERT INTO dbo.LSILokals (LokalName)
VALUES ('Lokal 1'), ('Lokal 2'), ('Lokal 10');
GO

-- create and fill exports
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = N'LSIExports') 
  CREATE TABLE dbo.LSIExports
  (
	  ExportID INT IDENTITY(1,1) NOT NULL,
	  ExportName NVARCHAR(250) NOT NULL,
  CONSTRAINT PK_ExportID PRIMARY KEY CLUSTERED (ExportID)
  )
GO
INSERT INTO dbo.LSIExports (ExportName)
VALUES ('Export 1'), ('Export 2'), ('Export 3');
GO

-- main data table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE [name] = N'LSIReports') 
  CREATE TABLE dbo.LSIReports
  (
	  ReportID INT IDENTITY(1,1) NOT NULL,
	  ExportID INT NOT NULL,
      ExportDate SMALLDATETIME NOT NULL DEFAULT GETDATE(),
      LokalID INT NOT NULL,
      PersonID INT NOT NULL
  CONSTRAINT PK_ReportID PRIMARY KEY CLUSTERED (ReportID)
  )
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_LSIReports_ExportDate')
  CREATE NONCLUSTERED INDEX IX_LSIReports_ExportDate ON dbo.LSIReports
  (
	ExportDate ASC
  ) INCLUDE (ReportID)
GO

-- =============================================
-- Author:		<Aleksandr Parn>
-- Create date: <27/07/2022>
-- Description:	<Procedure adds new reports>
-- =============================================
CREATE OR ALTER PROCEDURE dbo.p_LSIReports_Add
  @ExportID INT,
  @LokalID INT,
  @PersonID INT,
  @ReportID INT OUT
WITH EXECUTE AS OWNER AS 
BEGIN
	SET NOCOUNT ON;

    INSERT INTO dbo.LSIReports
      (ExportID,
       LokalID,
       PersonID
      )
    VALUES
      (@ExportID,
       @LokalID,
       @PersonID
      );
    
    SELECT @ReportID=SCOPE_IDENTITY()
END
GO

-- =============================================
-- Author:		<Aleksandr Parn>
-- Create date: <27/07/2022>
-- Description:	<Procedure return reports>
-- =============================================
CREATE OR ALTER PROCEDURE dbo.p_LSIReports_Get
  @LokalID INT,
  @FromDate DATETIME,
  @ToDate DATETIME
WITH EXECUTE AS OWNER AS 
BEGIN
	SET NOCOUNT ON;

    DECLARE @FD DATE=CONVERT(DATE, @FromDate),
            @TD DATE=CONVERT(DATE, @ToDate);

    SELECT 
      R.ExportID,
      E.ExportName,
      R.ExportDate,
      R.LokalID,
      L.LokalName,
      R.PersonID,
      P.PersonName,
      R.EDate,
      @FD,
      @TD
    FROM 
    (SELECT R.ExportID,
            R.LokalID,
            R.PersonID,
            R.ExportDate,
            CONVERT(DATE, R.ExportDate) AS EDate
     FROM dbo.LSIReports AS R WITH(NOLOCK)
    ) AS R
    INNER JOIN dbo.LSIExports AS E WITH(NOLOCK) ON E.ExportID=R.ExportID
    LEFT JOIN dbo.LSILokals AS L WITH(NOLOCK) ON L.LokalID=R.LokalID
    INNER JOIN dbo.LSIUsers AS P WITH(NOLOCK) ON P.PersonID=R.PersonID
    WHERE (@LokalID IS NULL OR R.LokalID=@LokalID)
      AND 
        (R.EDate BETWEEN ISNULL(@FD, R.EDate) AND ISNULL(@TD, R.EDate))
    ORDER BY R.ExportDate DESC
END
GO
-- =============================================
-- Author:		<Aleksandr Parn>
-- Create date: <27/07/2022>
-- Description:	<Procedure gets lokals>
-- =============================================
CREATE OR ALTER PROCEDURE dbo.p_LSILokals_Get
WITH EXECUTE AS OWNER AS 
BEGIN
	SET NOCOUNT ON;

	SELECT LokalID,
           LokalName
    FROM dbo.LSILokals WITH(NOLOCK)
    ORDER BY LokalName
END
GO

-- code to fill reports by random records
DECLARE @I INT, @EID INT, @LID INT, @PID INT, @eCnt INT, @lCnt INT, @pCnt INT, @D SMALLDATETIME, @DID INT, @rID INT;

SELECT TOP (1) @eCnt=ExportID FROM dbo.LSIExports WITH(NOLOCK) ORDER BY ExportID DESC;
SELECT TOP (1) @lCnt=LokalID FROM dbo.LSILokals WITH(NOLOCK) ORDER BY LokalID DESC;
SELECT TOP (1) @pCnt=PersonID FROM dbo.LSIUsers WITH(NOLOCK) ORDER BY PersonID DESC;
SELECT @eCnt=ISNULL(@eCnt,0), @lCnt=ISNULL(@lCnt,0), @pCnt=ISNULL(@pCnt,0);

WHILE (SELECT COUNT(*) FROM dbo.LSIReports)<30 BEGIN
  SELECT @rID=NULL;
   SELECT @EID=FLOOR(RAND()*(@eCnt)+1),
          @LID=FLOOR(RAND()*(@lCnt)+1),
          @PID=FLOOR(RAND()*(@pCnt)+1),
          @DID=FLOOR(RAND()*(100));
     EXEC dbo.p_LSIReports_Add @ExportID=@EID, @LokalID=@LID, @PersonID=@PID, @ReportID=@rID OUT;
     UPDATE dbo.LSIReports
       SET ExportDate=DATEADD(DAY, -@DID, ExportDate)
     WHERE ReportID=@rID
END;
