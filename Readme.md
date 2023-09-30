# Persian Calendar Project in SQL Server

## In this project, there are two tables:

1- DimDate table, which represents the calendar and stores Persian, Gregorian, and even Hijri dates along with various properties such as holidays, weekdays, seasons, week number, and day of the year.

2- DimDateDiff table, which includes two columns for the start date and end date, and other columns show the time difference between these two dates. One column represents the difference in days, and the other represents the difference in time, considering the Persian year and month in the format <b>yyyy/MM/dd</b>. For example, <b>0004/02/16</b> means there is a Persian time difference of 4 years, 2 months, and 16 days between the two dates.

## Procedures:
1- FillDimDate: This procedure generates records for the calendar table based on the specified start and end date parameters. If the start parameter is not specified, it will generate records starting from 5 years ago until the end date. If it's not the first execution, it identifies the maximum date from the calendar table and starts inserting records from that date. The initial execution can be called as follows:
<b>Exec [Dbo].[FillDimDate] @FromDate = NULL, @UntilDate = '2025-01-01'</b>

2- FillDimDateDiff: This procedure fills the time differences between the existing dates in the calendar table. It doesn't have any parameters and works based on the new data in the calendar table.

## Functions:
1- PersianDateAdd: This function is the equivalent of the DateAdd function in SQL Server, but it operates based on the Persian calendar concepts.

2- PersianDateDiff: This function calculates the time difference between two Persian dates and returns the output in the format <b>yyyy/MM/dd</b>

These components together provide a comprehensive Persian calendar implementation in SQL Server, allowing you to work with Persian dates and perform various operations based on the Persian calendar system.



