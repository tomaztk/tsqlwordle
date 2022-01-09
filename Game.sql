USE [TSQLWordle];
GO


CREATE OR ALTER PROCEDURE dbo.WordGuess
/*
Script       :  Game.sql
Procedure	 : dbo.WordGuess
Purpose      : T-SQL stored procedure for playing Wordle in T-SQL

Date Created : 10 January 2022
Description  : Popular word game called Wordle in T-SQL 
			   for Microsoft SQL Server 2017+
			   Based on https://powerlanguage.co.uk/wordle/ 
Author		 : Tomaz Kastrun (Twitter: @tomaz_tsql)
				  			 (Github: github.com\tomaztk)
Parameters   : Two input parameters
					 @lang -- defines language, thesaurus and keyboard
					 @guess -- 5-letter word for guessing
Output        :
				Result of the game:
					Table: dbo.TempTable - game play and tries		
					Table: dbo.TempKeyboard - coloured used keys 
Usage:
	EXEC dbo.WordGuess 
		 @lang='EN'
		--,@guess='aabbb' --WRONG GUESS
		,@guess = 'right' 
		--,@guess = 'hotel'
		--,@guess = 'agent' -- 'hotel'
		--,@guess = 'smile'


Colour denoting in first output (gameplay):
		 ' A ' is gray 
		{{ A }} is Yellow
		[[ A ]] is Green

Keyboard denoting in second output (keyboard):
		  # is grayed-out
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
		CREATE TABLE dbo.tempKeyboard (Krow INT, Kkey NVARCHAR(100))
		INSERT INTO dbo.tempKeyboard (Krow, Kkey)
		SELECT
			--id
			 Krow
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
	DROP TABLE IF EXISTS #tt
	DECLARE @guess_sol NVARCHAR(100) = ''
	declare @guess_sol2 nvarchar(100) = ''
	SET @secret = (SELECT secrets FROM dbo.TempTable WHERE nof_guess = 0)
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
				AND g.rn <> sec.rn
				AND NOT EXISTS (Select * from green  as gg 
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
		SELECT * 
		INTO #tt
		From final


		SELECT @guess_sol = COALESCE(@guess_sol + ' ', '') + reco
		FROM #tt
		ORDER BY pos ASC


		SELECT @guess_sol2 = COALESCE(@guess_sol2 + ' ,', '') + reco
		FROM #tt
		ORDER BY pos ASC


	-- store results
        INSERT INTO dbo.TempTable
        SELECT 
            (SELECT TOP 1 secrets  FROM dbo.tempTable) as Secrets 
            ,@nof_guess + 1 aS nof_guess
            ,@guess_sol 
			,1 as Valid;

        SELECT 
			 nof_guess AS [Try Number:]
			,guess_word AS [Guessed Word:]
		FROM TempTable
		WHERE
			ID > 0;
 

 	/*
	ADD part for keyboard denotation
	*/
		DROP TABLE IF EXISTS #tt2
		SELECT 
			 kkey
			,krow
			,ROW_NUMBER() OVER (ORDER BY krow) AS rn
			,TRIM([value]) AS [value]
		into #tt2	
		from dbo.tempkeyboard
		CROSS APPLY string_split(kkey, ';')


		DROP TABLE IF EXISTS #aa
		SELECT 
			[value] 
			,TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([value], ' [[ ',''), ' ]] ',''),' {{ ',''),' }} ',''), ' '' ','')) AS kak
		INTO #aa
		FROM STRING_SPLIT(@guess_sol2, ',')
		WHERE
			[value] <> ''

		-- updating values
		UPDATE t
		SET 
			t.[value] = a.[value]
		FROM #tt2 AS t
		JOIN #aa AS a
		ON a.kak = t.[value]

		UPDATE #tt2
		SET 
			[value] = '#'
		WHERE
			[value] LIKE ' ''% '

		-- Creating update keyboard outlook
		DROP TABLE IF EXISTS dbo.tempKeyboard
		SELECT 
		  krow
		 ,STRING_AGG([value], '; ') AS kkey
		INTO dbo.tempKeyboard
		FROM #tt2
		GROUP BY krow
		ORDER BY krow asc

		-- Output the keyboard
		SELECT * FROM  dbo.tempKeyboard

    END

	DECLARE @nof_guess2 INT = (SELECT MAX(nof_guess) FROM dbo.tempTable)
	IF @nof_guess2 = 6
	BEGIN
		SELECT 'End' AS [Message from the Game]
		DROP TABLE IF EXISTS dbo.TempTable;
		DROP TABLE IF EXISTS dbo.tempKeyboard;
	END


	IF (UPPER(@secret) = (@guess))
	BEGIN
		SELECT 'Yees, Won!' AS [Message from the Game]
		DROP TABLE IF EXISTS dbo.TempTable;
		DROP TABLE IF EXISTS dbo.tempKeyboard;
	END

END;
GO