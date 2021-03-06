USE [Harvest2]
GO
/****** Object:  StoredProcedure [dbo].[SearchStart]    Script Date: 04/18/2017 14:22:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[SearchStart]
	@No nvarchar(20),--装配件号
	@StartNaturalNo int OUTPUT,
	@TempNaturalNo int OUTPUT	
AS

BEGIN
	DECLARE @StartLevel int;
	DECLARE @TempLevel int;

	SELECT @StartNaturalNo = NaturalNo,@StartLevel = No FROM TempTable WHERE NextLevel = @No;
	SELECT @TempNaturalNo = @StartNaturalNo + 1;
	SELECT @TempLevel = No FROM TempTable WHERE NaturalNo = @TempNaturalNo;

		    
	WHILE @TempLevel > @StartLevel
	BEGIN
		SELECT @TempNaturalNo = @TempNaturalNo + 1;
		SELECT @TempLevel = No FROM TempTable WHERE NaturalNo = @TempNaturalNo;				
	END
	
	SELECT @TempNaturalNo = @TempNaturalNo-1;
END
