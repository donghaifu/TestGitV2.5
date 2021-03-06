USE [Harvest2]
GO
/****** Object:  StoredProcedure [dbo].[GetNextLevelShell]    Script Date: 04/18/2017 14:23:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[GetNextLevelShell]
	@No nvarchar(20),--装配件号
	@SalesNo nvarchar(10),--目前无用
	@Type int --类型
AS
BEGIN
	DECLARE @StartNaturalNo int;
	DECLARE @StopNaturalNo int;

	--查找去向的类型为4
	IF @Type = 4
	BEGIN
		SELECT AssembleNo,NextLevel,NextLevelName AS 名称,TypeName AS 件型,Level,TopLevel,PartCount AS 数量,SumCount,SalesNo
		FROM TempTable
		WHERE NextLevel=@No
	END

	--从装配属性表中得到本装配号的最高级属性“是”还是“否”
	--SELECT @LevelHigh=LevelHigh FROM AssembleList WHERE AssembleNo = @No;
	--如果类似为10001则执行下面这些语句
	IF @No LIKE '__0__'
	BEGIN
		--如果类型1，生成装配表
		IF @Type = 1
		BEGIN
			SELECT No AS 层级,NextLevel AS 件号,NextLevelName AS 名称,SheetName AS 图幅,Number AS 数量,TypeName AS 件型,
			Level AS 分组,ImportantName AS 重要度,OwnerName AS 设计,ValidDate AS 生效日期,Remark AS 备注
			FROM TempTable
			WHERE SalesNo = @No ORDER BY NaturalNo;
		END

		--如果类型2，生成生产用表
		IF @Type = 2
		BEGIN
			SELECT DISTINCT NextLevel AS 件号,NextLevelName AS 名称,SheetName AS 图幅,
			TypeName AS 件型,
			--Level AS 分组,
			ImportantName AS 重要度,OwnerName AS 设计,ValidDate AS 生效日期,
			--Remark AS 备注,
			SumCount AS 总数 FROM TempTable
			WHERE (TypeName = 'A件型' OR TypeName = 'P件型' OR TypeName = 'N件型') AND SalesNo = @No;
		END

		--如果类型3，生成采购用表
		IF @Type = 3
		BEGIN
			SELECT DISTINCT NextLevel AS 件号,NextLevelName AS 名称,SheetName AS 图幅,
			--Number AS 数量,
			TypeName AS 件型,
			--  Level AS 分组,
			ImportantName AS 重要度,OwnerName AS 设计,ValidDate AS 生效日期,
			--Remark AS 备注,
			SumCount AS 总数 FROM TempTable
			WHERE (TypeName = 'F件型' OR TypeName = 'N件型' ) AND SalesNo = @No;
		END

		--如果类型5，生成图纸管理表
		IF @Type = 5
		BEGIN
			SELECT DISTINCT NextLevel AS 文件编号,NextLevelName AS 文件名称,SheetName AS 图幅,OwnerName AS 设计
			FROM TempTable
			WHERE SalesNo = @No AND SheetName != 'Z'
		END


	END
	ELSE
	--如果类似为AYT10001则执行下面这些语句
	BEGIN

		--如果类型1，生成装配表

		IF @Type = 1
		BEGIN
		
			EXEC SearchStart @No,@StartNaturalNo OUTPUT,@StopNaturalNo OUTPUT
		    
			SELECT No AS 层级,NextLevel AS 件号,NextLevelName AS 名称,SheetName AS 图幅,Number AS 数量,TypeName AS 件型,
			Level AS 分组,ImportantName AS 重要度,OwnerName AS 设计,ValidDate AS 生效日期,Remark AS 备注
			FROM TempTable
			WHERE NaturalNo BETWEEN @StartNaturalNo AND @StopNaturalNo ORDER BY NaturalNo;
		END



		--如果类型2，生成生产用表
		IF @Type = 2
		BEGIN

			EXEC SearchStart @No,@StartNaturalNo OUTPUT,@StopNaturalNo OUTPUT	

			SELECT NextLevel AS 件号,NextLevelName AS 名称,SheetName AS 图幅,
			TypeName AS 件型,
			--Level AS 分组,
			ImportantName AS 重要度,OwnerName AS 设计,ValidDate AS 生效日期,
			--Remark AS 备注,
			Sum(PartCount) AS 总数 FROM TempTable
			WHERE (TypeName = 'A件型' OR TypeName = 'P件型' OR TypeName = 'N件型') 
			AND NaturalNo BETWEEN @StartNaturalNo AND @StopNaturalNo 
			GROUP BY NextLevel,NextLevelName,SheetName,TypeName,ImportantName,OwnerName,ValidDate;
		END
		

		--如果类型3，生成采购用表
		IF @Type = 3
		BEGIN

			EXEC SearchStart @No,@StartNaturalNo OUTPUT,@StopNaturalNo OUTPUT		

			SELECT NextLevel AS 件号,NextLevelName AS 名称,SheetName AS 图幅,
			--Number AS 数量,
			TypeName AS 件型,
			--  Level AS 分组,
			ImportantName AS 重要度,OwnerName AS 设计,ValidDate AS 生效日期,
			--Remark AS 备注,
			Sum(PartCount) AS 总数 FROM TempTable
			WHERE (TypeName = 'F件型' OR TypeName = 'N件型' ) 
			AND NaturalNo BETWEEN @StartNaturalNo AND @StopNaturalNo
			GROUP BY NextLevel,NextLevelName,SheetName,TypeName,ImportantName,OwnerName,ValidDate;;
		END


		--如果类型5，生成图纸管理表
		IF @Type = 5
		BEGIN

			EXEC SearchStart @No,@StartNaturalNo OUTPUT,@StopNaturalNo OUTPUT

			SELECT DISTINCT NextLevel AS 文件编号,NextLevelName AS 文件名称,SheetName AS 图幅,OwnerName AS 设计
			FROM TempTable
			WHERE SheetName != 'Z'
			AND NaturalNo BETWEEN @StartNaturalNo AND @StopNaturalNo;
		END		

	END

	--测试用,
	IF @Type = 10
	BEGIN
		--SELECT NaturalNo,No AS 层级,NextLevel AS 件号,NextLevelName AS 名称,AssembleNo AS 上级件号,SheetName AS 图幅,Number AS 数量,TypeName AS 件型,
		--Level AS 分组,ImportantName AS 重要度,OwnerName AS 设计,ValidDate AS 生效日期,Remark AS 备注,TopLevel AS 顶级件号,PartCount AS 部分数,SumCount AS 总数 FROM ##VirtualDown
		SELECT * FROM TempTable
	END

END
