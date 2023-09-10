
CREATE FUNCTION [dbo].[PersianDateAdd]
(
	@Intervall nvarchar(50),@Increment INT,@Date CHAR(10)
)
RETURNS CHAR(10)
AS 
BEGIN 
	DECLARE @Year INT, @Month INT, @Day INT,@seqPersianYearMonth int
	
	SELECT @Year = FrYear,@Month = FrMonth ,@Day = FrDay ,@seqPersianYearMonth=SeqPersianYearMonth FROM [dbo].DimDate WHERE Frdt = @Date

	DECLARE @IncYear INT, @IncMonth INT, @IncDay INT,@RetDate CHAR(10)

	IF(@Intervall NOT IN ('Year','Month','Day')) OR (@Year IS NULL)
		RETURN 'ERROR'


	IF(@Intervall = 'Year')
	BEGIN 
		SELECT @RetDate = Frdt FROM [dbo].DimDate D 
			WHERE D.FrYear = @Year + @Increment
				  AND FrMonth = @Month 
				  AND FrDay = IIF( @Day > D.MaxFrDayInMonth ,D.MaxFrDayInMonth ,@Day) -- چک میکنیم اگر سی ام اسفند سال کبیسه بوده باید هندل بشه وبشه بیست و نهم سال غیر کبیسه
	END 


	IF(@Intervall = 'Month')
	BEGIN 		
		SELECT @RetDate = Frdt FROM [dbo].DimDate D 
					WHERE d.SeqPersianYearMonth = @seqPersianYearMonth + @Increment
						  AND FrDay = IIF( @Day > D.MaxFrDayInMonth ,D.MaxFrDayInMonth ,@Day)		

	END 

	IF(@Intervall = 'Day')
	BEGIN	
		DECLARE @GregFromDay DATE
		SELECT @GregFromDay = Endt FROM [dbo].DimDate WHERE Frdt = @Date	
		SELECT @RetDate = Frdt FROM [dbo].DimDate WHERE Endt = DATEADD(DAY,@Increment,@GregFromDay)		
	END 


	RETURN @RetDate
END 