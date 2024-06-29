BEGIN;
PRAGMA foreign_keys=off;

-- Change REAL timestamps to INT. SQLITE only supports INT64, but ULog
-- timestamps are UINT64. We accept losing 1 bit at the top end, since 2^63
-- microseconds = 400,000 years. which should be enough.

CREATE TABLE IF NOT EXISTS ULog_tmp (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        SHA256Sum TEXT UNIQUE,
        FileVersion INT,
        StartTimestamp INT, -- changed from REAL
        LastTimestamp INT, -- changed from REAL
        CompatFlags TEXT,
        IncompatFlags TEXT,
        SyncCount INT,
        HasSync BOOLEAN
);
INSERT OR IGNORE INTO ULog_tmp (Id, SHA256Sum, FileVersion, StartTimestamp, LastTimestamp, CompatFlags, IncompatFlags, SyncCount, HasSync) SELECT Id, SHA256Sum, FileVersion, StartTimestamp, LastTimestamp, CompatFlags, IncompatFlags, SyncCount, HasSync FROM ULog;

CREATE TABLE IF NOT EXISTS ULogMessageDropout_tmp (
        Timestamp INT, -- changed from REAL
        Duration INT, -- changed from FLOAT
        ULogId INT REFERENCES ULog (Id) ON DELETE CASCADE
);
INSERT OR IGNORE INTO ULogMessageDropout_tmp SELECT * FROM ULogMessageDropout;

CREATE TABLE IF NOT EXISTS ULogMessageLogging_tmp (
        LogLevel INT,
        Timestamp INT,
        Message TEXT,
        ULogId INT REFERENCES ULog (Id) ON DELETE CASCADE
);
INSERT OR IGNORE INTO ULogMessageLogging_tmp SELECT * FROM ULogMessageLogging;

CREATE TABLE IF NOT EXISTS ULogMessageLoggingTagged_tmp (
        LogLevel INT,
        Timestamp INT, -- changed from REAL
        Tag INT,
        Message TEXT,
        ULogId INT REFERENCES ULog (Id) ON DELETE CASCADE
);
INSERT OR IGNORE INTO ULogMessageLoggingTagged_tmp SELECT * FROM ULogMessageLoggingTagged;

CREATE TABLE IF NOT EXISTS ULogChangedParameter_tmp (
        Timestamp INT, -- changed from REAL
        Key TEXT,
        Value BLOB,
        ULogId INT REFERENCES ULog (Id) ON DELETE CASCADE
);
INSERT OR IGNORE INTO ULogChangedParameter_tmp SELECT * FROM ULogChangedParameter;


DROP TABLE ULog;
DROP TABLE ULogMessageDropout;
DROP TABLE ULogMessageLogging;
DROP TABLE ULogMessageLoggingTagged;
DROP TABLE ULogChangedParameter;

ALTER TABLE ULog_tmp RENAME TO ULog;
ALTER TABLE ULogMessageDropout_tmp RENAME TO ULogMessageDropout;
ALTER TABLE ULogMessageLogging_tmp RENAME TO ULogMessageLogging;
ALTER TABLE ULogMessageLoggingTagged_tmp RENAME TO ULogMessageLoggingTagged;
ALTER TABLE ULogChangedParameter_tmp RENAME TO ULogChangedParameter;

PRAGMA foreign_keys=on;
COMMIT;
