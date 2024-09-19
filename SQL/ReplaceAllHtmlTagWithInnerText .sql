DECLARE @StartSearchPattern NVARCHAR(MAX);
DECLARE @StartEndSearchPattern NVARCHAR(MAX);
DECLARE @EndSearchPattern NVARCHAR(MAX);

SET @StartSearchPattern = '%<a class="RegularLink"%';
SET @StartEndSearchPattern = '>';
SET @EndSearchPattern = '</a>';


WITH RecursiveCTE AS
(
    -- Base case: Select the initial body
    SELECT 
        Id,  -- Assuming you have an `Id` column as the primary key in the Topic table
        Body AS OriginalBody,
        CASE 
            WHEN PATINDEX(@StartSearchPattern, Body) > 0 
            THEN 
                REPLACE(
                    Body,
                    SUBSTRING(Body, 
                              PATINDEX(@StartSearchPattern, Body), 
                              CHARINDEX(@EndSearchPattern, Body, PATINDEX(@StartSearchPattern, Body)) - PATINDEX(@StartSearchPattern, Body) + 4),
                    SUBSTRING(Body,
                              CHARINDEX(@StartEndSearchPattern, Body, PATINDEX(@StartSearchPattern, Body)) + 1, 
                              CHARINDEX(@EndSearchPattern, Body, PATINDEX(@StartSearchPattern, Body)) - CHARINDEX(@StartEndSearchPattern, Body, PATINDEX(@StartSearchPattern, Body)) - 1)
                )
            ELSE Body 
        END AS ProcessedBody,
        1 AS Level  -- Add a level to track the recursion depth
    FROM Topic
    WHERE IncludeInCustomSection = 1
      AND CustomSectionId <> 0
      AND Body LIKE @StartSearchPattern
    
    UNION ALL
    
    -- Recursive case: Keep replacing while more <a> tags exist
    SELECT 
        Id,
        OriginalBody,
        CASE 
            WHEN PATINDEX(@StartSearchPattern, ProcessedBody) > 0 
            THEN 
                REPLACE(
                    ProcessedBody,
                    SUBSTRING(ProcessedBody, 
                              PATINDEX(@StartSearchPattern, ProcessedBody), 
                              CHARINDEX(@EndSearchPattern, ProcessedBody, PATINDEX(@StartSearchPattern, ProcessedBody)) - PATINDEX(@StartSearchPattern, ProcessedBody) + 4),
                    SUBSTRING(ProcessedBody,
                              CHARINDEX(@StartEndSearchPattern, ProcessedBody, PATINDEX(@StartSearchPattern, ProcessedBody)) + 1, 
                              CHARINDEX(@EndSearchPattern, ProcessedBody, PATINDEX(@StartSearchPattern, ProcessedBody)) - CHARINDEX(@StartEndSearchPattern, ProcessedBody, PATINDEX(@StartSearchPattern, ProcessedBody)) - 1)
                )
            ELSE ProcessedBody
        END,
        Level + 1
    FROM RecursiveCTE
    WHERE PATINDEX(@StartSearchPattern, ProcessedBody) > 0
)


-- Select the row where no more <a> tags exist
SELECT Id, ProcessedBody
INTO #ProcessedTopics -- Temporary table to store results
FROM RecursiveCTE
WHERE PATINDEX(@StartSearchPattern, ProcessedBody) = 0;



-- Update the Topic table with the fully processed body
UPDATE T
SET T.Body = P.ProcessedBody
FROM Topic T
INNER JOIN #ProcessedTopics P ON T.Id = P.Id;


-- Drop the temporary table after updating
DROP TABLE #ProcessedTopics;
