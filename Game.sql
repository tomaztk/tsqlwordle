--  https://powerlanguage.co.uk/wordle/ 
-- Guess a word in 6 tries

-- 1. insert word 
    -- returns --> result 
    -- returns --> keyboard (coloured)

-- 2. Run game (with parameter: lang=EN)


USE [TSQLWordle];
GO


CREATE OR ALTER PROCEDURE dbo.WordGuess
/*

DESC: Popular word game called Wordle for T-SQL 
      Guess a word of five letters in 6 tries

AUTH: Tomaz Kastrun
DaTE: 10 January 2022

USAGE:
	EXEC dbo.WordGuess 
		 @lang='en'
		--,@guess='aabbb' --WRONG GUESS
		,@guess = 'table'

*/


     @lang char(3)
    ,@guess NVARCHAR(10)
AS 
BEGIN

	-- check if the word exists / is legitt :)
	IF (SELECT COUNT(*) FROM  [dbo].[Words] where word = @guess AND lang = @lang) = 0
	BEGIN 
		SELECT 'Wrong word!' AS [Message from the Game]
		RETURN

	END
	
	-- create table and generate secret
	IF (OBJECT_ID(N'dbo.tempTable'))  IS  NULL
	BEGIN 
	     CREATE TABLE dbo.tempTable (id int identity(0,1), secrets NVARCHAR(10), nof_guess INT, guess_word NVARCHAR(10), valid INT NULL)
		 DECLARE @secret NVARCHAR(10) = (SELECT top 1 word from dbo.words ORDER By newid())

            INSERT INTO dbo.tempTable (secrets, nof_guess,guess_word, valid)
            SELECT 
			 @secret AS secrets
            ,0 AS nof_guess
            ,null AS guess_word
            ,1 AS valid -- as valid word
	END

    
	-- guessing part
    DECLARE @nof_guess INT = (SELECT MAX(nof_guess) FROM tempTable)
    IF @nof_guess < 6
    BEGIN
        INSERT INTO dbo.TempTable
        SELECT 
            (SELECT TOP 1 secrets  FROM dbo.tempTable) as Secrets 
            ,@nof_guess + 1 aS nof_guess
            ,@guess
			,1 as Valid;

        SELECT * FROM TempTable;
    END
	DECLARE @nof_guess2 INT = (SELECT MAX(nof_guess) FROM tempTable)
	IF @nof_guess2 = 6
	BEGIN
		SELECT 'End'
		DROP TABLE IF EXISTS dbo.TempTable
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

select * from keyboard
where lang ='EN'


