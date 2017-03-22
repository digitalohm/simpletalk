USE [master];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author: Tim M. Hidalgo
-- Create date: 3/8/2015
-- Disclaimer: You use this script at your own risk.  I take no responsibility if you mess things up in your production environment, I would 
-- highly recommend you take the time to read the script and understand what it is doing.  If you lose data, its on you homey.
--
--
-- Description: This stored procedure is part of automating the restore process.  This script was originally written by 
-- Greg Robidoux at http://www.mssqltips.com/sqlservertip/1584/auto-generate-sql-server-restore-script-from-backup-files-in-a-directory/
-- then modified by Jason Carter at http://jason-carter.net/professional/restore-script-from-backup-directory-modified.html to work with Ola Hallengrens scripts.
-- You can find the Ola Hallengren SQL Server Maintenance scripts at https://ola.hallengren.com/
-- I have based this on Jason Carter's script and extended it so that it can perform a point in time restore, and execute the commands
-- Debug level 1 will print variables which was more of a utility for myself while writing it, Debug level 2 will print just the commands
-- Debug level 3 will print both the variables and the commands, and Debug NULL will execute the commands.
-- 
--
-- Example Usage:
-- dbo.sp_automate_restore @DatabaseName = 'AdventureWorks2014',
--                                        @UncPath = '\\BACKUP PATH\Used in Ola's Scripts',
--                                        @DebugLevel = 2,
--                                        @PointInTime = '20150402001601',
--                                        @NewDatabaseName = NULL  
--
-- dbo.sp_automate_restore @DatabaseName = 'AdventureWorks2014',
--                                        @UncPath = ''\\BACKUP PATH\Used in Ola's Scripts',
--                                        @DebugLevel = 2,
--                                        @PointInTime = NULL,
--                                        @NewDatabaseName = NULL
--
-- dbo.sp_automate_restore @DatabaseName = 'AdventureWorks2014',
--                                        @UncPath = ''\\BACKUP PATH\Used in Ola's Scripts',
--                                        @DebugLevel = 2,
--                                        @PointInTime = NULL,
--                                        @NewDatabaseName = 'MySpecialDatabaseName'
--										  @ServerName = 'AServerNameThatIsNotLocalHost'
--
-- 07222015 - Modified by Andy Garrett to allow database to be restored to new database.  To restore, pass in name of the new database using the @NewDatabaseName variable.
--          - Also modified to take into account any spaces in the name of the database, as the scripts by Ola removes spaces.  This was causing the Path to the backups to fail
--
-- 02182016 - @ServerName parameter added by Remi Ferland
--          - Used to overwrite the source server in the backup path
--
-- 03222017 - Cleaning up some of the comments and revisiting this script for further enhancements.  For clarification the @ServerName variable is to be used when you want to restore backups
--          - from a different server.  Currently because this is based on Ola's scripts the sp will insert the localhsot name. If you are confused then set debug level to 1 or 3 and see what is being generated 
-- =============================================

-- Check if the procedure already exists and drop for updating.
IF OBJECT_ID('sp_automate_restore') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_automate_restore];
GO
CREATE PROCEDURE [dbo].[sp_automate_restore]
    @DatabaseName VARCHAR(255) ,
    @UncPath VARCHAR(255) ,
    @DebugLevel INT ,
    @PointInTime CHAR(16) ,
    @NewDatabaseName VARCHAR(255) ,
    @ServerName VARCHAR(255) = NULL
AS
    BEGIN
        SET NOCOUNT ON;

		--Variable declaration.
        DECLARE @dbName sysname;
        DECLARE @backupPath NVARCHAR(500);
        DECLARE @cmd NVARCHAR(500);
        DECLARE @fileList TABLE
            (
              backupFile NVARCHAR(255)
            );
        DECLARE @lastFullBackup NVARCHAR(500);
        DECLARE @lastDiffBackup NVARCHAR(500);
        DECLARE @backupFile NVARCHAR(500);
        DECLARE @SQL VARCHAR(MAX);
        DECLARE @DebugLevelString VARCHAR(MAX);
        DECLARE @backupDBName NVARCHAR(255);
        DECLARE @newDB BIT;

		--Variable initialization
        SET @DebugLevelString = 'Debug Statement: ';
        SET @dbName = @DatabaseName;
        SET @backupDBName = REPLACE(@dbName, ' ', '');
        IF ( @NewDatabaseName IS NOT NULL )
            BEGIN
                SET @dbName = @NewDatabaseName;
                SET @newDB = 1;
            END;
        IF ( ( @DebugLevel = 1
               OR @DebugLevel = 3
             )
             AND ( @DatabaseName != @dbName )
           )
            PRINT 'Database is being Restored to a new database: ' + @dbName;
			
        IF ( @ServerName IS NULL )
            SET @ServerName = CAST(SERVERPROPERTY('ServerName') AS NVARCHAR);
	
        SET @backupPath = @UncPath + '\' + @ServerName + '\' + @backupDBName
            + '\FULL\';
        IF ( @DebugLevel = 1
             OR @DebugLevel = 3
           )
            PRINT @DebugLevelString + '@backupPath = ' + @backupPath;
		--Get the list of backup files
        SET @cmd = 'DIR /b ' + @backupPath;
        INSERT  INTO @fileList
                ( backupFile )
                EXEC master.sys.xp_cmdshell @cmd;
		--Find latest full backup
        SELECT  @lastFullBackup = MAX(backupFile)
        FROM    @fileList
        WHERE   backupFile LIKE '%_FULL_%'
                AND backupFile LIKE '%' + @backupDBName + '%';
        IF ( @DebugLevel = 1
             OR @DebugLevel = 3
           )
            BEGIN
                PRINT @DebugLevelString + '@lastFullBackup = '
                    + @lastFullBackup;
            END;
        IF ( @newDB = 0 )
            BEGIN
                SET @cmd = 'RESTORE DATABASE ' + @dbName + ' FROM DISK = '''
                    + @backupPath + @lastFullBackup
                    + ''' WITH REPLACE, NORECOVERY';
            END;
        ELSE
            BEGIN
                DECLARE @Table TABLE
                    (
                      LogicalName VARCHAR(128) ,
                      [PhysicalName] VARCHAR(128) ,
                      [Type] VARCHAR ,
                      [FileGroupName] VARCHAR(128) ,
                      [Size] VARCHAR(128) ,
                      [MaxSize] VARCHAR(128) ,
                      [FileId] VARCHAR(128) ,
                      [CreateLSN] VARCHAR(128) ,
                      [DropLSN] VARCHAR(128) ,
                      [UniqueId] VARCHAR(128) ,
                      [ReadOnlyLSN] VARCHAR(128) ,
                      [ReadWriteLSN] VARCHAR(128) ,
                      [BackupSizeInBytes] VARCHAR(128) ,
                      [SourceBlockSize] VARCHAR(128) ,
                      [FileGroupId] VARCHAR(128) ,
                      [LogGroupGUID] VARCHAR(128) ,
                      [DifferentialBaseLSN] VARCHAR(128) ,
                      [DifferentialBaseGUID] VARCHAR(128) ,
                      [IsReadOnly] VARCHAR(128) ,
                      [IsPresent] VARCHAR(128) ,
                      [TDEThumbprint] VARCHAR(128)
                    );
                DECLARE @Path VARCHAR(1000)= '' + @backupPath
                    + @lastFullBackup + '';
                DECLARE @LogicalNameData VARCHAR(128) ,
                    @LogicalNameLog VARCHAR(128) ,
                    @StorageFolder VARCHAR(128);
                INSERT  INTO @Table
                        EXEC
                            ( 'RESTORE FILELISTONLY FROM DISK=''' + @Path
                              + ''''
                            );
                SET @LogicalNameData = ( SELECT LogicalName
                                         FROM   @Table
                                         WHERE  Type = 'D'
                                       );
                SET @LogicalNameLog = ( SELECT  LogicalName
                                        FROM    @Table
                                        WHERE   Type = 'L'
                                      );
                SET @StorageFolder = ( SELECT   PhysicalName
                                       FROM     @Table
                                       WHERE    Type = 'D'
                                     );
                SET @StorageFolder = SUBSTRING(@StorageFolder, 0,
                                               LEN(@StorageFolder)
                                               - LEN(REVERSE(SUBSTRING(REVERSE(@StorageFolder),
                                                              0,
                                                              CHARINDEX('\',
                                                              REVERSE(@StorageFolder)))))
                                               + 1) + 'Temp\';

                SET @cmd = 'RESTORE DATABASE ' + @dbName + ' FROM DISK = '''
                    + @backupPath + @lastFullBackup
                    + ''' WITH REPLACE, NORECOVERY,' + 'MOVE '''
                    + @LogicalNameData + ''' TO ''' + @StorageFolder + @dbName
                    + '.mdf'', ' + 'MOVE ''' + @LogicalNameLog + ''' TO '''
                    + @StorageFolder + @dbName + '.ldf''; '; 
            END;
        IF ( @DebugLevel = 2
             OR @DebugLevel = 3
           )
            PRINT @cmd;
		--Execute the full restore command
        IF ( @DebugLevel IS NULL )
            EXEC sp_executesql @cmd;
		--Set the path for the differential backups
        SET @backupPath = @UncPath + '\' + @ServerName + '\' + @backupDBName
            + '\DIFF\';
        IF ( @DebugLevel = 1
             OR @DebugLevel = 3
           )
            PRINT @DebugLevelString + '@backupPath = ' + @backupPath;
		--Find the latest differential backup
        SET @cmd = 'DIR /b ' + @backupPath;
        INSERT  INTO @fileList
                ( backupFile )
                EXEC master.sys.xp_cmdshell @cmd;
        SELECT  @lastDiffBackup = MAX(backupFile)
        FROM    @fileList
        WHERE   backupFile LIKE '%_DIFF_%'
                AND backupFile LIKE '%' + @backupDBName + '%';
        IF ( @DebugLevel = 1
             OR @DebugLevel = 3
           )
            PRINT @DebugLevelString + '@lastDiffBackup = ' + @lastDiffBackup;
		--Check to make sure there is a diff backup
        IF @lastDiffBackup IS NOT NULL
            BEGIN
                SET @cmd = 'RESTORE DATABASE ' + @dbName + ' FROM DISK = '''
                    + @backupPath + @lastDiffBackup
                    + ''' WITH REPLACE, NORECOVERY';
                IF ( @DebugLevel = 2
                     OR @DebugLevel = 3
                   )
                    PRINT @cmd;
				
				--Execute the differential restore command
                IF ( @DebugLevel IS NULL )
                    EXEC sp_executesql @cmd;
                
                IF ( @DebugLevel = 1
                     OR @DebugLevel = 3
                   )
                    PRINT @DebugLevelString + '@lastFullBackup = '
                        + @lastFullBackup;
            END;
		--Set the path for the log backups
        SET @backupPath = @UncPath + '\' + @ServerName + '\' + @backupDBName
            + '\LOG\';
        IF ( @DebugLevel = 1
             OR @DebugLevel = 3
           )
            PRINT @DebugLevelString + '@backupPath = ' + @backupPath;
		--Declaring some variables for comparison and string manipuations
        DECLARE @lfb VARCHAR(255) ,
            @currentLogBackup VARCHAR(255) ,
            @previousLogBackup VARCHAR(255) ,
            @ldb VARCHAR(255) ,
            @DateTimeValue VARCHAR(255);
        SELECT  @lfb = REPLACE(LEFT(RIGHT(@lastFullBackup, 19), 15), '_', '');
        SELECT  @ldb = REPLACE(LEFT(RIGHT(@lastDiffBackup, 19), 15), '_', '');
		--Get the list of log files that are relevant to the backups being used
        SET @cmd = 'DIR /b ' + @backupPath;
        INSERT  INTO @fileList
                ( backupFile )
                EXEC master.sys.xp_cmdshell @cmd;
        DECLARE backupFiles CURSOR
        FOR
            SELECT  backupFile
            FROM    @fileList
            WHERE   backupFile LIKE '%_LOG_%'
                    AND backupFile LIKE '%' + @backupDBName + '%'
                    AND REPLACE(LEFT(RIGHT(backupFile, 19), 15), '_', '') > @ldb
            ORDER BY backupFile;
        OPEN backupFiles;
		-- Loop through all the files for the database
        FETCH NEXT FROM backupFiles INTO @backupFile;
        SET @previousLogBackup = REPLACE(LEFT(RIGHT(@backupFile, 19), 15), '_',
                                         '');
        SET @lastFullBackup = REPLACE(LEFT(RIGHT(@lastFullBackup, 19), 15),
                                      '_', '');
        IF ( @PointInTime < @ldb
             OR @PointInTime < @lastFullBackup
           )
            BEGIN
                PRINT 'Invalid @PointInTime.  Must be a value greater than the last full or diff backup';
                RETURN -1;
            END;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @currentLogBackup = REPLACE(LEFT(RIGHT(@backupFile, 19),
                                                     15), '_', '');
                IF ( @DebugLevel = 1
                     OR @DebugLevel = 3
                   )
                    PRINT @DebugLevelString + 'Last Log Backup: '
                        + @currentLogBackup + ' Last Full Backup: ' + @lfb;
                IF ( @PointInTime IS NULL )
                    BEGIN
                        IF ( @currentLogBackup > @lfb )
                            BEGIN
                                SET @cmd = 'RESTORE LOG ' + @dbName
                                    + ' FROM DISK = ''' + @backupPath
                                    + @backupFile
                                    + ''' WITH REPLACE, NORECOVERY';
                                IF ( @DebugLevel = 2
                                     OR @DebugLevel = 3
                                   )
                                    PRINT @cmd;
								--Execute the log restores commands
                                IF ( @DebugLevel IS NULL )
                                    EXEC sp_executesql @cmd;
                            END;
                    END;
                ELSE
                    IF ( @currentLogBackup < @PointInTime )
                        BEGIN
                            SET @cmd = 'RESTORE LOG ' + @dbName
                                + ' FROM DISK = ''' + @backupPath
                                + @backupFile + ''' WITH NORECOVERY';
                            IF ( @DebugLevel = 2
                                 OR @DebugLevel = 3
                               )
                                PRINT @cmd;
							--Execute the log restores commands
                            IF ( @DebugLevel IS NULL )
                                EXEC sp_executesql @cmd;
                        END;
                    ELSE
                        IF ( ( @PointInTime > @previousLogBackup
                               AND @PointInTime < @currentLogBackup
                             )
                             OR @PointInTime < @previousLogBackup
                           )
                            BEGIN
                                SET @DateTimeValue = CONVERT(VARCHAR, CONVERT(DATETIME, SUBSTRING(@PointInTime,
                                                              1, 8)), 111)
                                    + ' ' + SUBSTRING(@PointInTime, 8, 2)
                                    + ':' + SUBSTRING(@PointInTime, 10, 2)
                                    + ':' + SUBSTRING(@PointInTime, 12, 2);
                                SET @cmd = 'RESTORE LOG ' + @dbName
                                    + ' FROM DISK = ''' + @backupPath
                                    + @backupFile
                                    + ''' WITH NORECOVERY, STOPAT = '''
                                    + @DateTimeValue + '''';
                                IF ( @DebugLevel = 2
                                     OR @DebugLevel = 3
                                   )
                                    PRINT @cmd;
							--Execute the log restores commands
                                IF ( @DebugLevel IS NULL )
                                    EXEC sp_executesql @cmd;
                            END;
                SET @previousLogBackup = @currentLogBackup; 
                FETCH NEXT FROM backupFiles INTO @backupFile;
            END;
        CLOSE backupFiles;
        DEALLOCATE backupFiles;
		--End with recovery so that the database is put back into a working state.
        SET @cmd = 'RESTORE DATABASE ' + @dbName + ' WITH RECOVERY';
        IF ( @DebugLevel = 2
             OR @DebugLevel = 3
           )
            PRINT @cmd;
        IF ( @DebugLevel IS NULL )
            EXEC sp_executesql @cmd;
    END;
