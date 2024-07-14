SELECT 
  C.COLUMN_NAME,
        C.DATA_TYPE,
        COLS.is_identity AS IsIdentity,
        (SELECT COUNT(*) 
         FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
         JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CCU
         ON TC.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
         WHERE CCU.COLUMN_NAME = C.COLUMN_NAME 
         AND TC.CONSTRAINT_TYPE = 'UNIQUE' 
         AND CCU.TABLE_NAME = '{table}') AS IsUnique,
        (SELECT COUNT(*)
         FROM sys.index_columns ic
         JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
         JOIN sys.columns sc ON ic.object_id = sc.object_id AND ic.column_id = sc.column_id
         WHERE sc.name = C.COLUMN_NAME AND OBJECT_NAME(ic.object_id) = '{table}') AS IsIndexed
    FROM INFORMATION_SCHEMA.COLUMNS C
    JOIN sys.columns COLS ON C.COLUMN_NAME = COLS.name
    WHERE C.TABLE_NAME = '{table}'