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


DROP TABLE IF EXISTS dbo.TempWords;
CREATE TABLE dbo.TempWords
( 
    word NVARCHAR(10)
);

BULK INSERT dbo.TempWords
FROM 'Lang/english.txt'
WITH (FIRSTROW = 1
    ,ROWTERMINATOR='\n');	


INSERT INTO dbo.Words
SELECT 
     word
    ,'EN' as lang

 FROM TempWords;
