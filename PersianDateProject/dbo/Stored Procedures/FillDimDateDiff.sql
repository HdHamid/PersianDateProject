CREATE Procedure Dbo.[FillDimDateDiff]
as
drop table if exists #Stp1
select FrdtFrom,MAX(FrdtTo) as FrdtTo 
	into #Stp1 
from dbo.DimDateDiff
GROUP BY FrdtFrom

insert into dbo.DimDateDiff
(
	FrdtFrom
	,EndtFrom
	,FrdtTo 
	,EndtTo
	,[FrDateDiff]
	,DayDiff
)
select 
	--row_number() over(order by d1.frdt,d2.Frdt) as Rn
	d1.frdt as  FrdtFrom
	,d1.Endt as EndtFrom
	,d2.Frdt as FrdtTo 
	,d2.Endt as EndtTo
	,dbo.PersianDateDiff(d1.frdt,d2.Frdt) as [FrDateDiff]
	,d2.seqId - d1.SeqId as DayDiff
from dbo.Dimdate d1 
	inner join dbo.Dimdate d2 on d1.Endt < d2.Endt
	inner join #Stp1 s1 on s1.FrdtFrom = d1.Frdt and s1.FrdtTo < d2.Frdt 
	-- تواریخ بزرگتر از تاریخ اول که برایشان محاسبه رخ نداده بیار
union all
select 
	--row_number() over(order by d1.frdt,d2.Frdt) as Rn
	d1.frdt as FrdtFrom
	,d1.Endt as EndtFrom
	,d2.Frdt as FrdtTo 
	,d2.Endt as EndtTo
	,dbo.PersianDateDiff(d1.frdt,d2.Frdt) as [FrDateDiff]
	,d2.seqId - d1.SeqId as DayDiff
from dbo.Dimdate d1 
	inner join dbo.Dimdate d2 on d1.Endt < d2.Endt
	where not exists (select 1 from #Stp1 s1 where s1.FrdtFrom = d1.Frdt)
	-- تواریخی که اصلا برای آنها محاسبه رخ نداده و تازه جنریت شدن در جدول بعد زمان بیار

