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
FROM '/Users/tomazkastrun/Documents/tomaztk_github/tsqlwordle/languages/english.txt'
WITH (FIRSTROW = 1
    ,ROWTERMINATOR='\n');	


INSERT INTO dbo.Words
SELECT 
     word
    ,'EN' as lang

 FROM TempWords;

-- Insert Slovenian words
DROP TABLE IF EXISTS dbo.TempWords;
CREATE TABLE dbo.TempWords
( 
    word NVARCHAR(10)
);

BULK INSERT dbo.TempWords
FROM '/Users/tomazkastrun/Documents/tomaztk_github/tsqlwordle/languages/slovenian.txt'
WITH (FIRSTROW = 1
    ,ROWTERMINATOR='\n');	


INSERT INTO dbo.Words
SELECT 
     word
    ,'SI' as lang

 FROM TempWords;



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
SELECT 1, 'Q; W; E; R; T; Z; U; I; O; P; Š; Đ', 'SI' UNION ALL
SELECT 2, 'A; S; D; F; G; H; J; K; L; Č; Ć; Ž', 'SI' UNION ALL
SELECT 3, 'Y; X; C; V; B; N; M', 'SI'


SELECT * FROM dbo.Keyboard
SELECT * FROM dbo.Words


