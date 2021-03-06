/* ****************************************************
Script       :  Setup.sql
Purpose      : Installation script for setting up words
Date Created : 10 January 2022
Description  : Popular word game called Wordle in T-SQL 
			   for Microsoft SQL Server 2017+
			   Based on https://powerlanguage.co.uk/wordle/ 
Author		 : Tomaz Kastrun (Twitter: @tomaz_tsql)
				  			 (Github: github.com\tomaztk)

******************************************************** */


USE Master;
GO

CREATE DATABASE TSQLWordle;
GO


USE TSQLWordle;
GO


DROP TABLE IF EXISTS dbo.Words;
GO

CREATE TABLE dbo.Words
( ID INT IDENTITY(1,1)
, word NVARCHAR(10) NOT NULL
, lang CHAR(3) NOT NULL
);

-- Insert english words
DROP TABLE IF EXISTS dbo.TempWords;
CREATE TABLE dbo.TempWords
( 
    word NVARCHAR(10)
);

BULK INSERT dbo.TempWords
--FROM '/Users/tomazkastrun/Documents/tomaztk_github/tsqlwordle/languages/english.txt' -- Linux
FROM 'C:\DataTK\git\tsqlwordle\languages\english.txt' -- Windows
WITH (FIRSTROW = 1
    ,ROWTERMINATOR='\n');	
-- (1384 rows affected)

INSERT INTO dbo.Words
SELECT 
     word
    ,'EN' as lang

 FROM TempWords;
 -- (1384 rows affected)



-- Insert Slovenian words
DROP TABLE IF EXISTS dbo.TempWords;
CREATE TABLE dbo.TempWords
( 
    word NVARCHAR(10)
);

BULK INSERT dbo.TempWords
-- FROM '/Users/tomazkastrun/Documents/tomaztk_github/tsqlwordle/languages/slovenian.txt' -- linux
FROM 'C:\DataTK\git\tsqlwordle\languages\slovenian.txt' -- windows
WITH (FIRSTROW = 1
    ,ROWTERMINATOR='\n');	
-- (12861 rows affected)

INSERT INTO dbo.Words
SELECT 
     word
    ,'SI' as lang

 FROM TempWords;
 -- (12861 rows affected)


 -- Insert Italian words
DROP TABLE IF EXISTS dbo.TempWords;
CREATE TABLE dbo.TempWords
( 
    word NVARCHAR(10)
);

BULK INSERT dbo.TempWords
-- FROM '/Users/tomazkastrun/Documents/tomaztk_github/tsqlwordle/languages/italian.txt' -- linux
FROM 'C:\DataTK\git\tsqlwordle\languages\italian.txt' -- windows
WITH (FIRSTROW = 1
    ,ROWTERMINATOR='\n');	
-- (12861 rows affected)

INSERT INTO dbo.Words
SELECT 
     word
    ,'IT' as lang

 FROM TempWords;
  -- (0 row(s) affected) 

  -- Insert German words
DROP TABLE IF EXISTS dbo.TempWords;
CREATE TABLE dbo.TempWords
( 
    word NVARCHAR(10)
);

BULK INSERT dbo.TempWords
-- FROM '/Users/tomazkastrun/Documents/tomaztk_github/tsqlwordle/languages/german.txt' -- linux
FROM 'C:\DataTK\git\tsqlwordle\languages\german.txt' -- windows
WITH (FIRSTROW = 1
    ,ROWTERMINATOR='\n');	
-- (12861 rows affected)

INSERT INTO dbo.Words
SELECT 
     word
    ,'DE' as lang

 FROM TempWords;
 -- (0 row(s) affected) 

DROP TABLE IF EXISTS dbo.Keyboard;
GO
CREATE TABLE dbo.Keyboard
(
    ID INT IDENTITY(1,1)
    ,Krow INT NOT NULL
    ,Kkey NVARCHAR(100) NOT NULL
    ,lang CHAR(3) NOT NULL
)

INSERT INTO dbo.Keyboard
SELECT 1, 'Q; W; E; R; T; Y; U; I; O; P', 'EN' UNION ALL
SELECT 2, 'A; S; D; F; G; H; J; K; L', 'EN' UNION ALL
SELECT 3, 'Z; X; C; V; B; N; M', 'EN' UNION ALL
SELECT 1, 'Q; W; E; R; T; Z; U; I; O; P; ??; ??', 'SI' UNION ALL
SELECT 2, 'A; S; D; F; G; H; J; K; L; ??; ??; ??', 'SI' UNION ALL
SELECT 3, 'Y; X; C; V; B; N; M', 'SI'  UNION ALL
SELECT 1, 'Q; W; E; R; T; Z; U; I; O; P; ??', 'DE' UNION ALL
SELECT 2, 'A; S; D; F; G; H; J; K; L; ??; ??', 'DE' UNION ALL
SELECT 3, 'Y; X; C; V; B; N; M', 'DE'   
SELECT 1, 'Q; W; E; R; T; Z; U; I; O; P', 'IT' UNION ALL
SELECT 2, 'A; S; D; F; G; H; J; K; L', 'IT' UNION ALL
SELECT 3, 'Y; X; C; V; B; N; M', 'IT'   




