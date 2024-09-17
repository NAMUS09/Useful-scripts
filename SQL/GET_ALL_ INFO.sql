
-- get all info
SELECT a.*,
       CASE WHEN b.TableName IS NOT NULL THEN 'Yes' ELSE 'No' END AS IsUnique
FROM (
    SELECT t.TABLE_NAME AS TableName,
           c.COLUMN_NAME AS ColumnName,
           c.DATA_TYPE AS DataType,
           CASE WHEN pk.COLUMN_NAME IS NOT NULL THEN 'Yes' ELSE 'No' END AS IsPrimaryKey,
           CASE WHEN fk.COLUMN_NAME IS NOT NULL THEN 'Yes' ELSE 'No' END AS IsForeignKey,
           fk.REF_TABLE_NAME AS ReferencedTableName,
           fk.REF_COLUMN_NAME AS ReferencedColumnName,
           c.character_maximum_length AS MaximumLength,
           c.numeric_precision AS Precision,
           c.numeric_scale AS Scale,
           CASE WHEN c.is_nullable = 'yes' THEN 'Yes' ELSE 'No' END AS IsNullable
    FROM INFORMATION_SCHEMA.TABLES t
    INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME
    LEFT JOIN (
        SELECT ku.TABLE_NAME,
               ku.COLUMN_NAME
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku
        INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON ku.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
        WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
    ) pk ON t.TABLE_NAME = pk.TABLE_NAME AND c.COLUMN_NAME = pk.COLUMN_NAME
    LEFT JOIN (
        SELECT ku.TABLE_NAME,
               ku.COLUMN_NAME,
               rcu.TABLE_NAME AS REF_TABLE_NAME,
               rcu.COLUMN_NAME AS REF_COLUMN_NAME
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku
        INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON ku.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
        INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc ON ku.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
        INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE rcu ON rc.UNIQUE_CONSTRAINT_NAME = rcu.CONSTRAINT_NAME
        WHERE tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
    ) fk ON t.TABLE_NAME = fk.TABLE_NAME AND c.COLUMN_NAME = fk.COLUMN_NAME
    WHERE t.TABLE_TYPE = 'BASE TABLE'
) a
LEFT JOIN (
    SELECT t.name AS TableName,
           c.name AS ColumnName
    FROM SYS.INDEXES i
    JOIN SYS.INDEX_COLUMNS ic ON i.index_id = ic.index_id AND i.object_id = ic.object_id
    JOIN SYS.TABLES t ON i.object_id = t.object_id
    JOIN SYS.COLUMNS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    LEFT JOIN SYS.FOREIGN_KEY_COLUMNS fk ON fk.parent_object_id = t.object_id AND fk.parent_column_id = c.column_id
    LEFT JOIN SYS.FOREIGN_KEYS fkeys ON fk.constraint_object_id = fkeys.object_id
    LEFT JOIN SYS.TABLES ref_t ON fk.referenced_object_id = ref_t.object_id
    LEFT JOIN SYS.COLUMNS ref_c ON fk.referenced_object_id = ref_c.object_id AND fk.referenced_column_id = ref_c.column_id
    WHERE i.type = 2 AND i.name LIKE 'U%' AND i.is_primary_key = 0
) b ON a.TableName = b.TableName AND a.ColumnName = b.ColumnName;
