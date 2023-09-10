CREATE FUNCTION [dbo].[PersianDateDiff]
(
	@FromDate CHAR(10),@ToDate CHAR(10)
)
RETURNS NVARCHAR(10)
AS
BEGIN 
--declare @FromDate CHAR(10) = '1400/02/08' ,@ToDate CHAR(10) = '1400/11/01'
	
	IF(@FromDate > @ToDate)
		RETURN 'ERROR'

	DECLARE @YearFrom INT,@MonthFrom INT,@DayFrom INT
	DECLARE @YearTo INT,@MonthTo INT,@DayTo INT
	DECLARE @SeqID INT , @SeqIdTo INT 

	SELECT @YearFrom = FrYear ,@MonthFrom = FrMonth,@DayFrom = FrDay FROM dbo.DimDate WHERE Frdt = @FromDate

	SELECT @YearTo = FrYear ,@MonthTo = FrMonth,@DayTo = FrDay , @SeqIdTo = SeqID FROM dbo.DimDate WHERE Frdt = @ToDate

	DECLARE @DifYear INT , @DifMonth INT, @DifDay INT

	SET @DifYear = @YearTo - @YearFrom

	IF(@DifYear > 0 AND @MonthTo < @MonthFrom) 
		SET @DifYear -= 1
	
	IF(@DifYear > 0 AND @MonthTo = @MonthFrom AND @DayTo < @DayFrom) 
	BEGIN
		SET @DifYear -= 1
		SET @DifMonth = 11
	END 

	IF(@YearFrom = @YearTo AND @MonthTo > @MonthFrom) 
		SET @DifMonth = @MonthTo - @MonthFrom

	IF(@MonthTo < @MonthFrom) 
		SET @DifMonth = 12 - @MonthFrom + @MonthTo  

	ELSE IF(@MonthTo = @MonthFrom)
		SET @DifMonth = 0 
	
	ELSE IF(@MonthTo > @MonthFrom)
		SET @DifMonth = @MonthTo - @MonthFrom

	IF(@DayFrom = @DayTo)
		SET @DifDay = 0 
	
	--select @DifMonth,@DayTo,@DayFrom
	ELSE IF(@DifMonth >= 0 AND @DayTo < @DayFrom)
	BEGIN
		DECLARE @YR INT = IIF(@MonthTo = 1 , @YearTo - 1 , @YearTo)
		DECLARE @MNT INT = IIF(@MonthTo = 1 , 12 , @MonthTo - 1)
		SELECT @SeqID = SeqID FROM dbo.DimDate WHERE FrYear = @YR AND FrMonth = @MNT
		AND FrDay = (SELECT IIF(@DayFrom > MaxFrDayInMonth,MaxFrDayInMonth,@DayFrom ) 
		FROM dbo.DimDate WHERE FrYear=@YR AND FrMonth = @MNT AND FrDay = 1)
		SET @DifDay = @SeqIdTo - @SeqID 
		SET @DifMonth = IIF(@DifMonth = 0 ,@DifMonth,@DifMonth - 1)
	END 

	ELSE IF (@DayTo > @DayFrom)
		SET @DifDay = @DayTo - @DayFrom 

	DECLARE @DifYearChar VARCHAR(4) = CAST(@DifYear AS VARCHAR(4))
	DECLARE @DifMonthChar VARCHAR(2) = CAST(@DifMonth AS VARCHAR(4))
	DECLARE @DifDayChar VARCHAR(2) = CAST(@DifDay AS VARCHAR(4))
	RETURN	REPLICATE('0',4-LEN(@DifYearChar))+@DifYearChar+'/'+REPLICATE('0',2-LEN(@DifMonthChar))+@DifMonthChar+'/'+REPLICATE('0',2-LEN(@DifDayChar))+@DifDayChar
END 