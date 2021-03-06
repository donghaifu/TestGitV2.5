USE [Harvest2]
GO
/****** Object:  StoredProcedure [dbo].[GenerateTemp]    Script Date: 04/18/2017 14:25:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 这个存储过程可以作为计划任务使用
ALTER PROC [dbo].[GenerateTemp]
AS

BEGIN
	DECLARE @SalesNo nvarchar(20);
	--IF OBJECT_ID('Tempdb..TempTable') IS NOT NULL  --似乎不好使
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TempTable]') AND type in (N'U'))
		DROP TABLE TempTable

	--建表
	CREATE TABLE TempTable
	(
		NaturalNo          int            IDENTITY  NOT NULL,--自增序列
		No                 int            NOT NULL,--层级
		AssembleNo         nvarchar(20)   NOT NULL,--父
		NextLevel          nvarchar(20)   NOT NULL,--子
		NextLevelName      nvarchar(50)   NOT NULL,--子名称
		SheetName          nvarchar(6)    NOT NULL,--图幅名称
		Number             numeric(11,2)  NOT NULL,--数量，支持小数
		TypeName           nvarchar(6)    NOT NULL,--类型名称
		Level              int            NOT NULL,--分组
		ImportantName      nvarchar(6)    NOT NULL,--重要度
		OwnerName          nvarchar(20)   NOT NULL,--作者
		ValidDate          datetime       NOT NULL,--生效日期
		Remark             nvarchar(50)   NULL,--备注
		TopLevel           nvarchar(20)   NULL,--顶级件号
		PartCount          numeric(11,2)  NULL,--部分数量
		SumCount           numeric(11,2)  NULL,--总数量
		SalesNo            nvarchar(20)   NOT NULL--销售号
	)

	DECLARE cSales CURSOR LOCAL FOR
		SELECT PartNo FROM ViewSalesNo;

	OPEN cSales
	FETCH NEXT FROM cSales INTO @SalesNo
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE ViewSalesNo
		SET Calc = 'TRUE'
		WHERE PartNo=@SalesNo;

		EXEC GenerateSalesTable @SalesNo

		UPDATE ViewSalesNo
		SET Calc = 'FALSE'
		WHERE PartNo=@SalesNo;


		FETCH NEXT FROM cSales INTO @SalesNo
	END

	CLOSE cSales
	DEALLOCATE cSales

END
