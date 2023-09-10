--Exec [Dbo].[FillDimDate] @FromDate = NULL,@UntilDate = '2025-01-01'
CREATE PROCEDURE [Dbo].[FillDimDate]
@FromDate date ,
@UntilDate date
AS
set nocount on
BEGIN
IF NOT EXISTS(SELECT * FROM sys.objects WHERE TYPE = 'U' AND NAME = 'DimDate' AND SCHEMA_NAME(schema_id) = 'dbo')
BEGIN	
	CREATE TABLE [Dbo].[DimDate](
		[ID] int NOT NULL, -- تاریخ میلادی عددی
		[Endt] date NULL, -- تاریخ میلادی
		[EnYear] char(4) NULL, -- سال میلادی 
		[EnMonth] char(2) NULL, -- ماه میلادی 
		[EnDay] char(2) NULL, -- روز از ماه میلادی
		[Frdt] char(10) NULL, -- تاریخ شمسی
		[FrYear] char(4) NULL, -- سال شمسی
		[FrMonth] char(2) NULL, -- ماه شمسی
		[FrYearMonth] char(6), -- سال ماه شمسی
		[FrDay] char(2) NULL, -- روز از ماه شمسی
		[Hjdt] char(10) NULL, -- تاریخ قمری 
		[HjYear] char(4) NULL, -- سال قمری
		[HjMonth] char(2) NULL, -- ماه قمری
		[HjDay] char(2) NULL, -- روز از ماه قمری
		[EnMonthName] nvarchar(50) NULL, -- نام ماه میلادی
		[EnDayOfWeek] nvarchar(50) NULL, -- روز هفته میلادی
		[FrMonthName] nvarchar(50) NULL, -- نام ماه شمسی
		[FrDayOfWeek] nvarchar(50) NULL, -- روز هفته شمسی
		[EnNoDayOfWeek] smallint NULL, -- ترتیب روز هفته میلادی
		[FrNoDayOfWeek] smallint NULL, -- ترتیب روز هفته شمسی		
		[Qrtr] tinyint NULL, -- فصل 
		[QrtrName] nvarchar(50) NULL, -- نام فصل 	
		[SeqID] int,
	 CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END


	declare @date date 
	if @FromDate is null
	begin
		set @date = isnull(dateadd(Day,1,((select max(Endt) from Dbo.DimDate))),dateadd(YEAR,-5,getdate()));
	end 
	else 
	begin
		set @date = @FromDate
	end
	set @FromDate = @date



	declare @frdate nvarchar(10),@HjDate nvarchar(10)
	declare @ID int	
	declare @DateDiff int = (select DATEDIFF(day,@FromDate,@UntilDate))
	
	;with stp1 as 
	(
		select  ROW_NUMBER() over(Order by a.object_id) as rn from sys.objects a cross join sys.objects b
	)
	select *
	,CAST(DATEADD(DAY,rn-1,@FromDate) as DATE) as EnDt INTO #DimDate
	from stp1 where rn <=@DateDiff

	
	INSERT INTO [Dbo].[DimDate]
	(
		ID
		,Endt
		,EnYear
		,EnMonth
		,EnDay
		,Frdt
		,FrYear
		,FrMonth
		,FrYearMonth
		,FrDay
		,Hjdt
		,HjYear
		,HjMonth
		,HjDay
		,EnMonthName
		,EnDayOfWeek
		,FrMonthName
		,FrDayOfWeek
		,EnNoDayOfWeek
		,FrNoDayOfWeek
		,SeqID
	)
	select 
		Cast(Format(EnDt,'yyyyMMdd') as int) as ID
		,FORMAT(EnDt,'yyyy/MM/dd') as Endt
		,DATEPART(year,EnDt) as EnYear
		,FORMAT(EnDt,'MM') as EnMonth
		,FORMAT(EnDt,'dd') as EnDay
		,FORMAT(EnDt,'yyyy/MM/dd','fa-ir') as FrDt
		,FORMAT(EnDt,'yyyy','fa-ir') as FrYear
		,FORMAT(EnDt,'MM','fa-ir') as FrMonth
		,FORMAT(EnDt,'yyyyMM','fa-ir') as FrYearMonth
		,FORMAT(EnDt,'dd','fa-ir') as FrDay
		,FORMAT(EnDt,'yyyy/MM/dd','ar') as HjDt
		,FORMAT(EnDt,'yyyy','ar') as HjYear
		,FORMAT(EnDt,'MM','ar') as HjMonth
		,FORMAT(EnDt,'dd','ar') as HjDay
		,FORMAT(EnDt,'MMMM') as EnMonthName
		,DATENAME(WEEKDAY,EnDt) EnDayOfWeek
		,FORMAT(EnDt,'MMMM','fa-ir') as FrMonthName
		,FORMAT(EnDt,'dddd','fa-ir') FrDayOfWeek
		,DATEPART(WEEKDAY,EnDt) as EnNoDayOfWeek
		,case DatePart(WEEKDAY,@date)
											when 1 then 2
											when 2 then 3
											when 3 then 4
											when 4 then 5
											when 5 then 6
											when 6 then 7
											when 7 then 1
		end FrNoDayOfWeek	
		,convert(int,cast(Endt as datetime)) as SeqID 
	from #DimDate
		
-- فصلهای سال 
	Update dd set Qrtr = 1 , QrtrName = N'بهار'  FROM Dbo.DimDate dd WHERE FrMonth BETWEEN 1 AND 3 AND QrtrName IS NULL 
	Update dd set Qrtr = 2 , QrtrName = N'تابستان'  FROM Dbo.DimDate dd WHERE FrMonth BETWEEN 4 AND 6 AND QrtrName IS NULL 
	Update dd set Qrtr = 3 , QrtrName = N'پاییز'  FROM Dbo.DimDate dd WHERE FrMonth BETWEEN 7 AND 9 AND QrtrName IS NULL 
	Update dd set Qrtr = 4 , QrtrName = N'زمستان'  FROM Dbo.DimDate dd WHERE FrMonth BETWEEN 10 AND 13 AND QrtrName IS NULL 



END

