USE gold_db
GO
CREATE OR ALTER PROC CreateSQLServerlessView_gold @ViewName NVARCHAR(MAX)
AS
BEGIN
DECLARE @statement VARCHAR(MAX)

        SET @statement = N'CREATE OR ALTER VIEW ' + QUOTENAME(@ViewName) + ' AS
            SELECT * 
            FROM OPENROWSET(
                BULK ''https://advworkstanya.dfs.core.windows.net/gold/SalesLT/' + @ViewName + '/'',
                FORMAT = ''DELTA''
            ) AS [result]'
    

    EXEC  (@statement)
END
GO
