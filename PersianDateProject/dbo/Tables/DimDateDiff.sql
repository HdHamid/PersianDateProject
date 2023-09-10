CREATE TABLE [dbo].[DimDateDiff]
(
    [FrdtFrom] CHAR(10) NULL, 
    [EndtFrom] DATE NULL, 
    [FrdtTo] CHAR(10) NULL, 
    [EndtTo] DATE NULL, 
    [FrDateDiff] CHAR(10) NULL, 
    [DayDiff] INT NULL
)

GO

CREATE UNIQUE CLUSTERED INDEX [IX_DimDateDiff_Column] ON [dbo].[DimDateDiff] (FrdtFrom,FrdtTo)




