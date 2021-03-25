//
//  Database.swift
//  UpNext
//
//  Created by Sabrina Bea on 7/1/20.
//  Copyright © 2020 Sabrina Bea. All rights reserved.
//

import Foundation
import SQLite

class Database {
    let db: Connection
    let table = Table("entries")
    
    let id = Expression<Int64>("rowid")
    let date = Expression<Date>("date")
    let goal = Expression<Int64>("goal")
    let calories = Expression<Int64>("calories")
    
    var tableWithAllColumns: Table {
        table.select(id, date, goal, calories)
    }
    
    #if os(iOS)
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    #elseif os(macOS)
    let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! + "/" + Bundle.main.bundleIdentifier!
    #endif
    
    init?() {
        do {
            #if os(macOS)
            try FileManager.default.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
            #endif
            db = try Connection("\(path)/db.sqlite3")
            
            try db.run(table.create(ifNotExists: true) { t in
                t.column(date)
                t.column(goal, defaultValue: 100)
                t.column(calories, defaultValue: 0)
            })
        } catch {
            assert(false, "Failed to initialize database")
            return nil
        }
    }
}

// MARK: Load Data
extension Database {
    func load() -> [Entry] {
        var entries: [Entry] = []
        do {
            for row in try db.prepare(tableWithAllColumns) {
                if let entry = parseEntry(from: row) {
                    entries.append(entry)
                }
            }
        } catch {
            assertionFailure("Failed to load data")
            return []
        }
        entries.sort(by: { lhs, rhs in lhs.date < rhs.date })
        return entries
    }
    
    func parseEntry(from row: Row) -> Entry? {
        return try? Entry(date: row.get(date), goal: row.get(goal), calories: row.get(calories))
    }
}

// MARK: Creation
extension Database {
    func createEntry(date: Date, goal: Int64) -> Entry? {
        do {
            let id = try db.run(table.insert(self.date <- date, self.goal <- goal))
            return parseEntry(from: try db.pluck(tableWithAllColumns.filter(self.id == id).limit(1))!)
        } catch {
            print("Error: createEntry")
            return nil
        }
    }
}

// MARK: Updates
extension Database {
    func update(_ entry: Entry) {
        do {
            _ = try db.run(table.filter(self.date == entry.date).update(
                self.goal <- entry.goal,
                self.calories <- entry.calories
            ))
        } catch {
            print("Error: update")
            return
        }
    }
}

// MARK: Delete
extension Database {
    func deleteEverything() {
        _ = try? db.run(table.delete())
    }
    
    // TODO: Allow restoring data by using delete flag?
    func delete(entry: Entry) {
        _ = try? db.run(table.filter(self.date == entry.date).delete())
    }
}

// MARK: Import
extension Database {
    // Returns the id of the entry if successful, nil if unsucessful
    func importEntry(_ entry: Entry) -> Int64? {
        return try? db.run(table.insert(self.date <- entry.date, self.calories <- entry.calories, self.goal <- entry.goal))
    }
}
