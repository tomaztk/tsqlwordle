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

AUTH: Tomaz Kastrun
DaTE: 10 January 2022

USAGE:
	EXEC dbo.WordGuess 
		 @lang='EN'
		--,@guess='aabbb' --WRONG GUESS
		--,@guess = 'right' --'hotel'
		,@guess = 'hotel'

	Keyboard denoting:
		 ' A ' is gray 
		{{ A }} is Yellow
		[[ A ]] is Green

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
		 -- DROP TABLE IF EXISTS dbo.tempTable
	     CREATE TABLE dbo.tempTable (id int identity(0,1), secrets NVARCHAR(10), nof_guess INT, guess_word NVARCHAR(100), valid INT NULL)
		 DECLARE @secret NVARCHAR(10) = (SELECT top 1 word from dbo.words WHERE lang= @lang ORDER By newid())

            INSERT INTO dbo.tempTable (secrets, nof_guess,guess_word, valid)
            SELECT 
			 @secret AS secrets
            ,0 AS nof_guess
            ,null AS guess_word
            ,1 AS valid -- as valid word
	END

	-- create table for temp keyboard
	IF (OBJECT_ID(N'dbo.tempKeyboard')) IS NULL
	BEGIN
		CREATE TABLE dbo.tempKeyboard (id INT, Krow INT, Kkey NVARCHAR(100))
		INSERT INTO dbo.tempKeyboard (id,Krow, Kkey)
		SELECT
			id
			,Krow
			,Kkey
		FROM dbo.Keyboard
		WHERE
			lang = @lang

	END
    
	-- guessing part
    DECLARE @nof_guess INT = (SELECT MAX(nof_guess) FROM tempTable)
    IF @nof_guess < 6
    BEGIN
	/*
	ADD part for determing colours
	*/
	DECLARE @guess_sol NVARCHAR(100) = ''
	
			;WITH sec AS (

				SELECT
					 SUBSTRING(a.b, val.number+1, 1) AS letter 
					,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RN
				FROM 
					(SELECT @secret AS b) AS a
				JOIN [master]..spt_values AS val 
				ON val.number < LEN(a.b)
				WHERE 
					[type] = 'P'
			
			), gu AS (

				SELECT 
					 substring(a.b, val.number+1, 1) AS letter 
					,row_number() over (order by (select 1)) as RN
				FROM 
					(SELECT @guess AS b) AS a
				JOIN [master]..spt_values AS val 
				ON val.number < len(a.b)
				WHERE  [type] = 'P'

			) ,green AS (
				SELECT
					 gu.letter as gul
					,sec.letter as secl
				    ,gu.rn as gurn
				 FROM gu 
				 JOIN sec
				 ON gu.rn = sec.rn
				 AND gu.letter = sec.letter
			
			), yellof AS (

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

			), gray AS (

				SELECT
					 letter as gul
					,rn as gurn
				FROM gu
				WHERE
						NOT EXISTS (SELECT * FROM green  WHERE gul = gu.letter)
					AND NOT EXISTS (SELECT * FROM yellof WHERE gul = gu.letter)
			
			) ,Aaa AS (

				SELECT gul AS letter, gurn AS pos  , 'green' as col FROM green  UNION ALL
				SELECT gul AS letter, gurn AS pos , 'yellow' as col FROM yellof UNION 
				SELECT gul AS letter, gurn AS pos , 'Gray'   as col FROM gray
			
			) , final AS (
			SELECT 
				 a.letter
				,a.col
				,CASE 
					WHEN a.col = 'Gray'  THEN ' '' ' +UPPER(a.letter)+ ' '' '
					WHEN a.col ='yellow' THEN ' {{ ' +UPPER(a.letter)+ ' }} '
					WHEN a.col ='green'  THEN ' [[ ' +UPPER(a.letter)+ ' ]] ' END as reco
				,a.pos
				,g.letter as guess_letter
			
				
			FROM aaa as a
			LEFT JOIN gu as g
			ON g.rn = a.pos
			)

		SELECT @guess_sol = COALESCE(@guess_sol + ' ', '') + reco
		FROM final
		ORDER BY pos ASC


	
	-- store results
        INSERT INTO dbo.TempTable
        SELECT 
            (SELECT TOP 1 secrets  FROM dbo.tempTable) as Secrets 
            ,@nof_guess + 1 aS nof_guess
            ,@guess_sol 
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



    
