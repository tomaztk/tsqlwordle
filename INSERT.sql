--  https://powerlanguage.co.uk/wordle/ 
-- Guess a word in 6 tries

-- 1. insert word 
    -- returns --> result 
    -- returns --> keyboard (coloured)

-- 2. Run game (with parameter: lang=EN)


CREATE OR ALTER PROCEDURE dbo.WordGuess
    @lang char(3)
    ,@guess NVARCHAR(10)
AS 
BEGIN
 
    IF (OBJECT_ID(N'dbo.tempTable'))  IS NOT NULL
    BEGIN  
        DECLARE @nof_guess INT = (SELECT MAX(nof_guess) FROM tempTable)
        IF @nof_guess < 6
        BEGIN
            INSERT INTO dbo.TempTable
            SELECT 
                (SELECT TOP 1 secrets  FROM dbo.tempTable) as Secrets 
                ,@nof_guess + 1 aS nof_guess
                ,@guess;

            SELECT * FROM TempTable;
       END
        DECLARE @nof_guess2 INT = (SELECT MAX(nof_guess) FROM tempTable)
        IF @nof_guess2 = 6
        BEGIN
            SELECT 'End'
             DROP TABLE IF EXISTS dbo.TempTable
        END

    END 
    ELSE
    BEGIN
            
            CREATE TABLE dbo.tempTable (id int identity(1,1), secrets NVARCHAR(10), nof_guess INT, guess_word NVARCHAR(10), valid INT NULL)
    
            DECLARE @secret NVARCHAR(10) 
            SET @secret = (SELECT top 1 word from dbo.words ORDER By newid())

            INSERT INTO dbo.tempTable (secrets, nof_guess,guess_word, valid)
            SELECT @secret
            ,1
            ,@guess;
            ,1 -- as valid word
            
            SELECT * FROM tempTAble;
            --SELECT secrets 'secret Stored' FROM dbo.tempTable
    END

END;
GO


exec dbo.WordGuess 'en', 'otter'
exec dbo.WordGuess 'en','other'
exec dbo.WordGuess 'en','alter'
exec dbo.WordGuess 'en','acter'
exec dbo.WordGuess 'en','bladr'
exec dbo.WordGuess 'en','actor'


 -- select * from dbo.tempTable
 -- SELECT * FROM dbo.Keyboard
-- drop table dbo.tempTable


--- Check words
IF (SELECT COUNT(*) FROM words AS w JOIN tempTable  as tt ON w.word = tt.word WHERE id = (SELECT MAX(ID) from temptable) > 0 -- beseda je prava
    
declare @secret nchar(5) = 'otomz'
declare @guess nchar(5)  = 'tooez'

-- select [value] from string_split(@secret, '')

;with sec AS (
select 
     substring(a.b, val.number+1, 1) AS letter 
    ,row_number() over (order by (select 1)) as RN
from (select @secret AS b) AS a
join master..spt_values AS val 
ON val.number < len(a.b)
where 
    type = 'P'
),
gu AS (
select 
     substring(a.b, val.number+1, 1) AS letter 
    ,row_number() over (order by (select 1)) as RN
from (select @guess AS b) AS a
join master..spt_values AS val 
ON val.number < len(a.b)
where 
    type = 'P'
)
,green AS
(
    select 
     gu.letter as gul
     ,sec.letter as secl
     ,gu.rn as gurn
     from gu 
     join sec
     on gu.rn = sec.rn
     and gu.letter = sec.letter
)
-- select * FROM green
, yellof AS
(
    select distinct
    g.letter as gul
    ,g.rn as gurn
    from gu as g
    cross join sec
    where   
        g.letter = sec.letter
    and g.rn <> sec.rn
    and not exists (Select * from green  as gg 
                    where gg.gul = g.letter 
                      and gg.gurn = g.rn)

)
--select * from yellof
, gray as
(
select 
 letter as gul
,rn as gurn
 from gu
    where  
        not exists (Select * from green where gul = gu.letter)
        AND not exists (Select * from yellof where gul = gu.letter)
)
,Aaa as (
select gul as letter, gurn as pos  , 'green' as col
from green
union all
select gul as letter, gurn as pos , 'yellow' as col
from yellof
union 
select gul as letter, gurn as pos , 'Gray' as col
From gray
)
select letter, col,pos from aaa
order by pos asc