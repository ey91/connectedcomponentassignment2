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


INSERT INTO edges2 SELECT * FROM edges;
INSERT INTO edges2  select citedPaperID, paperID from edges;

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



CREATE TABLE ConnectedComponent(
           Connected int,
        PRIMARY KEY (Connected) --TO make sure all id's are unique
   );

CREATE TABLE CurrentWave(
           nodes int,
   );

CREATE TABLE NextWave (
           nodes int,
       );


-- select * from nodes

Truncate TABLE ConnectedComponent
TRUNCATE TABLE CurrentWave
TRUNCATE TABLE NextWave

WHILE (EXISTS (select * from nodes))
BEGIN

   INSERT INTO CurrentWave
        SELECT TOP (1) ND.paperID
       FROM nodes ND

   -- initializing processing

   --Keep trying to find edges for the next nodes until you can't
   WHILE (EXISTS (select * from CurrentWave))

       BEGIN
           --Find all the nodes connected to CurrentWave nodes (put items into 2nd queue)
           INSERT INTO NextWave
           SELECT distinct citedPaperID
           FROM edges2
           WHERE paperID IN (SELECT nodes FROM CurrentWave);

           --moving nodes in 1st queue to  result table
           INSERT INTO ConnectedComponent
           SELECT distinct nodes FROM CurrentWave cw
           WHERE cw.nodes NOT IN (SELECT Connected
                                  FROM ConnectedComponent)

           --Remove them from the nodes table (after processing)
           DELETE FROM nodes
           WHERE paperID IN (SELECT nodes FROM currentWave);

           -- Remove them from 1st queue (after processing)
           TRUNCATE TABLE CurrentWave

           --Replace current wave with the next wave nodes, to be processed
           INSERT INTO CurrentWave
           SELECT * FROM NextWave nw
           WHERE nw.nodes NOT IN (SELECT Connected
                                  FROM ConnectedComponent)

           --reset next wave
           TRUNCATE TABLE NextWave
       END
   IF (SELECT COUNT(*) FROM ConnectedComponent) > 4 AND (SELECT COUNT(*) FROM ConnectedComponent) <= 10 EXEC PrintTable @TableName = 'ConnectedComponent'

   TRUNCATE TABLE ConnectedComponent
   TRUNCATE TABLE CurrentWave
END
