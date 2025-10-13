//
//  AppStorage.swift
//  Music-app
//
//  Created by Shirin on 21.09.2023.
//

import Foundation
import GRDB
import os.log
import Resolver

struct AppDatabase {

    let dbWriter: any DatabaseWriter
    var reader: DatabaseReader { dbWriter }

    init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        let migrator = createMigrator()
        try migrator.migrate(dbWriter)
    }

    public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
        let sqlLogger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")

        var config = base
        if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
            config.prepareDatabase { db in
                db.trace {
                    os_log("%{public}@", log: sqlLogger, type: .debug, String(describing: $0))
                }
            }
        }

#if DEBUG
        config.publicStatementArguments = true
#endif
        
        return config
    }
    
    func createMigrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        migrator.registerMigration("createTables") { db in
            try db.create(table: "playListModel") { t in
                t.autoIncrementedPrimaryKey("local_id")
                t.column("id", .integer).notNull()
                t.column("name", .text).notNull()
                t.column("cover", .text)
                t.column("type", .text).notNull()
                t.column("year", .text)
                t.column("album_artist", .text)
                t.column("is_download_on", .boolean).defaults(to: false)
            }
            
            try db.create(table: "songModel") { t in
                t.autoIncrementedPrimaryKey("local_id")
                t.column("local_path", .text)
                t.column("id", .integer).notNull().unique(onConflict: .ignore)
                t.column("name", .text).notNull()
                t.column("image", .text).notNull()
                t.column("artists", .text).notNull()
                t.column("album_id", .integer)
                t.column("year", .integer).notNull()
                t.column("audio", .text).notNull()
            }
            
            try db.create(table: "playlistSong") { t in
                t.primaryKey(["playlistId", "songId"])
                t.column("playlistId", .integer)
                    .notNull()
                    .references("playListModel", column: "local_id", onDelete: .cascade)
                    .indexed()
                t.column("songId", .integer)
                    .notNull()
                    .references("songModel", column: "local_id", onDelete: .cascade)
            }
            
            try db.create(table: "downloadQueue") { t in
                t.primaryKey(["id"])
                t.column("id", .integer).notNull().references("songModel", column: "id", onDelete: .cascade)
                t.column("song", .text).notNull()
            }
        }
        
        migrator.registerMigration("addIsLikedColumn") { db in
            try db.alter(table: "songModel") { t in
                t.add(column: "is_liked", .boolean)
            }
        }
        
        return migrator
    }
}
