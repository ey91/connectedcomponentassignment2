
TRUNCATE TABLE nodes
CREATE TABLE nodes (
paperID INTEGER,
paperTitle VARCHAR (100));
SELECT * FROM nodes
CREATE TABLE edges (
paperID INTEGER,
citedPaperID INTEGER);

CREATE TABLE edges2 (
    paperID INTEGER,
    citedPaperID INTEGER);

INSERT INTO edges2
SELECT * FROM edges;

Update edges2 Set paperID=citedPaperID,citedPaperID=paperID

CREATE VIEW undirected AS
(
SELECT *
FROM edges
UNION
SELECT *
FROM edges2
    )

SELECT COUNT(*) FROM edges

SELECT * FROM edges
ORDER BY paperID

SELECT * FROM undirected
ORDER BY paperID

SELECT * FROM nodes

--Set up above -- now, start of algorithm

--Create a procedure to print out the table
DROP PROCEDURE PrintTable
CREATE PROCEDURE PrintTable
    @TableName NVARCHAR(128)
AS
BEGIN
    DECLARE @SqlQuery NVARCHAR(MAX)
    SET @SqlQuery = 'SELECT Connected, ''ADD''  FROM ' + QUOTENAME(@TableName)

    EXEC sp_executesql @SqlQuery
END


--Outer loop picks a random the unvivisted node that haven't been placed into a connected component yet
DROP TABLE ConnectedComponent
DROP TABLE CurrentWave
DROP TABLE NextWave

GO
CREATE TABLE ConnectedComponent(
            Connected int,
         PRIMARY KEY (Connected) --TO make sure all id's are unique
    );
GO
    CREATE TABLE CurrentWave(
            nodes int,
    );
    GO
    CREATE TABLE NextWave (
            nodes int,
        );

-- select * from nodes

WHILE (EXISTS (select * from nodes))
BEGIN
    --ConnectedComponent saves all the nodes in the currently calculating component

    INSERT INTO ConnectedComponent
         SELECT TOP (1) ND.paperID
        FROM nodes ND
    -- SELECT * FROM ConnectedComponent

    --CurrentWave saves the nodes that we are currently finding edges connected to for

    INSERT INTO CurrentWave
         SELECT TOP (1) ND.paperID
        FROM nodes ND
    -- SELECT * FROM CurrentWave
    DELETE FROM nodes
    WHERE paperID = (SELECT TOP 1 paperID FROM nodes);

    --Keep trying to find edges for the next nodes until you can't
    WHILE (EXISTS (select * from CurrentWave))
    BEGIN
        --Find all the nodes connected to CurrentWave nodes
        INSERT INTO NextWave
            SELECT citedPaperID
            FROM edges2
            WHERE paperID IN (SELECT nodes FROM CurrentWave);

        --Insert connected nodes into the connected component table
        INSERT INTO ConnectedComponent
            SELECT * FROM NextWave nw
            WHERE nw.nodes NOT IN (SELECT Connected
                           FROM ConnectedComponent)
         --SELECT * FROM ConnectedComponent
--         SELECT * FROM nodes
        --Remove them from the nodes table
        DELETE FROM nodes
        WHERE paperID IN (SELECT nodes FROM NextWave);
--         SELECT * FROM nodes

        --Replace current wave with the next wave nodes
        TRUNCATE TABLE CurrentWave
        INSERT INTO CurrentWave
             SELECT * FROM NextWave nw
                WHERE nw.nodes NOT IN (SELECT Connected
                           FROM ConnectedComponent)
        --reset next wave
        TRUNCATE TABLE NextWave
    END
    IF (SELECT COUNT(*) FROM ConnectedComponent) > 4 AND (SELECT COUNT(*) FROM ConnectedComponent) <= 10 EXEC PrintTable @TableName = 'ConnectedComponent'
--     EXEC PrintTable @TableName = 'ConnectedComponent'
    -- SELECT * FROM ConnectedComponent
        --SELECT * FROM CurrentWave
--      SELECT * FROM nodes
    TRUNCATE TABLE ConnectedComponent
    TRUNCATE TABLE CurrentWave
END

SELECT * FROM nodes








