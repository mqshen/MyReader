//
//  SQLiteDB.swift
//  SqlliteTest
//
//  Created by GoldRatio on 8/24/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

let SQLITE_DATE = SQLITE_NULL + 1

class SQLColumn {
    var value:AnyObject? = nil
    var type:CInt = -1
    
    init(value: AnyObject, type: CInt) {
        self.value = value
        self.type = type
    }
    
    func asString()->String {
        switch (type) {
        case SQLITE_INTEGER, SQLITE_FLOAT:
            return "\(value!)"
        case SQLITE_TEXT:
            return value as String
        case SQLITE_BLOB:
            let str = NSString(data:value as NSData, encoding:NSUTF8StringEncoding)
            return str!
        case SQLITE_NULL:
            return ""
        case SQLITE_DATE:
            let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return fmt.stringFromDate(value as NSDate)
        default:
            return ""
        }
    }
    
    func asInt()->Int {
        switch (type) {
        case SQLITE_INTEGER, SQLITE_FLOAT:
            return value as Int
        case SQLITE_TEXT:
            let str = value as NSString
            return str.integerValue
        case SQLITE_BLOB:
            let str = NSString(data:value as NSData, encoding:NSUTF8StringEncoding)!
            return str.integerValue
        case SQLITE_NULL:
            return 0
        case SQLITE_DATE:
            return Int((value as NSDate).timeIntervalSince1970)
        default:
            return 0
        }
    }
    
    func asInt64()->Int64 {
        switch (type) {
        case SQLITE_INTEGER, SQLITE_FLOAT:
            return (value as NSNumber).longLongValue
        case SQLITE_TEXT:
            let str = value as NSString
            return str.longLongValue
        case SQLITE_BLOB:
            let str = NSString(data:value as NSData, encoding:NSUTF8StringEncoding)
            return str!.longLongValue
        case SQLITE_NULL:
            return 0
        case SQLITE_DATE:
            return Int64((value as NSDate).timeIntervalSince1970)
        default:
            return 0
        }
    }
    
    func asDouble()->Double {
        switch (type) {
        case SQLITE_INTEGER, SQLITE_FLOAT:
            return value as Double
        case SQLITE_TEXT:
            let str = value as NSString
            return str.doubleValue
        case SQLITE_BLOB:
            let str = NSString(data:value as NSData, encoding:NSUTF8StringEncoding)!
            return str.doubleValue
        case SQLITE_NULL:
            return 0.0
        case SQLITE_DATE:
            return (value as NSDate).timeIntervalSince1970
        default:
            return 0.0
        }
    }
    
    func asData()->NSData? {
        switch (type) {
        case SQLITE_INTEGER, SQLITE_FLOAT:
            let str = "\(value)" as NSString
            return str.dataUsingEncoding(NSUTF8StringEncoding)
        case SQLITE_TEXT:
            let str = value as NSString
            return str.dataUsingEncoding(NSUTF8StringEncoding)
        case SQLITE_BLOB:
            return value as? NSData
        case SQLITE_NULL:
            return nil
        case SQLITE_DATE:
            let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let str = fmt.stringFromDate(value as NSDate)
            return str.dataUsingEncoding(NSUTF8StringEncoding)
        default:
            return nil
        }
    }
    
    func asDate()->NSDate? {
        switch (type) {
        case SQLITE_INTEGER, SQLITE_FLOAT:
            let tm = value as Double
            return NSDate(timeIntervalSince1970:tm)
        case SQLITE_TEXT:
            let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return fmt.dateFromString(value as String)
        case SQLITE_BLOB:
            let str = NSString(data:value as NSData, encoding:NSUTF8StringEncoding)
            let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return fmt.dateFromString(str!)
        case SQLITE_NULL:
            return nil
        case SQLITE_DATE:
            return value as? NSDate
        default:
            return nil
        }
    }
}

class SQLRow {
    var data = Dictionary<String, SQLColumn>()
    
    subscript(key: String) -> SQLColumn? {
        get {
            return data[key]
        }
        
        set(newVal) {
            data[key] = newVal
        }
    }
}

class SQLiteDB
{
    let QUEUE_NAME_PREFIX = "SQLiteDB"
    let name: String
    var opaquePointer = UnsafeMutablePointer<COpaquePointer>.alloc(1)
    let queue:dispatch_queue_t
    
    init(name: String, initHandler: (COpaquePointer) -> Void) {
        self.name = name
        let queueName = "\(QUEUE_NAME_PREFIX)_\(name)"
        queue = dispatch_queue_create(queueName, nil)
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let databasePath = paths[0].stringByAppendingPathComponent("DB")
        
        let fileManager = NSFileManager()
        if !fileManager.fileExistsAtPath(databasePath) {
            fileManager.createDirectoryAtPath(databasePath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        let databaseFile = databasePath.stringByAppendingPathComponent(self.name)
        println(databaseFile)
        if !fileManager.fileExistsAtPath(databaseFile) {
            //let cpath = databaseFile.cStringUsingEncoding(NSUTF8StringEncoding)
            if sqlite3_open(databaseFile, self.opaquePointer) == SQLITE_OK {
                initHandler(self.opaquePointer.memory)
                //                let sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)"
                //                if sqlite3_exec(self.opaquePointer[0], sql_stmt, nil, nil, nil) != SQLITE_OK {
                //                    println("create table success")
                //                }
            }
            else {
                sqlite3_close(self.opaquePointer[0])
            }
        }
        else {
            if sqlite3_open(databaseFile, self.opaquePointer) == SQLITE_OK {
            }
            else {
                sqlite3_close(self.opaquePointer[0])
            }
        }
    }
    
    func execute(sql: String)->CInt {
        var result:CInt = 0
        dispatch_sync(queue) {
            var cSql = sql.cStringUsingEncoding(NSUTF8StringEncoding)
            var stmt:COpaquePointer = nil
            // Prepare
            result = sqlite3_prepare_v2(self.opaquePointer[0], cSql!, -1, &stmt, nil)
            if result != SQLITE_OK {
                sqlite3_finalize(stmt)
                let msg = "SQLiteDB - failed to prepare SQL: \(sql), Error: "
                println(msg)
                return
            }
            // Step
            result = sqlite3_step(stmt)
            if result != SQLITE_OK && result != SQLITE_DONE {
                sqlite3_finalize(stmt)
                let msg = "SQLiteDB - failed to execute SQL: \(sql), Error: "
                println(msg)
                return
            }
            // Is this an insert
            if sql.uppercaseString.hasPrefix("INSERT ") {
                // Known limitations: http://www.sqlite.org/c3ref/last_insert_rowid.html
                let rid = sqlite3_last_insert_rowid(self.opaquePointer[0])
                result = CInt(rid)
            } else {
                result = 1
            }
            // Finalize
            sqlite3_finalize(stmt)
        }
        return result
    }
    
    func query(sql: String) -> [SQLRow] {
        var rows = [SQLRow]()
        dispatch_sync(queue) {
            var statme = UnsafeMutablePointer<COpaquePointer>.alloc(1)
            var result = sqlite3_prepare_v2(self.opaquePointer[0], sql, -1, statme, nil)
            if result != SQLITE_OK {
                sqlite3_finalize(statme.memory)
                let msg = "SQLiteDB - failed to prepare SQL: \(sql), Error: "
                println(msg)
                return
            }
            result = sqlite3_step(statme.memory)
            var fetchColumnInfo = true
            var columnCount:CInt = 0
            var columnNames = [String]()
            var columnTypes = [CInt]()
            while result == SQLITE_ROW {
                if fetchColumnInfo {
                    columnCount = sqlite3_column_count(statme.memory)
                    for index in 0..<columnCount {
                        // Get column name
                        let name = sqlite3_column_name(statme.memory, index)
                        columnNames.append(String.fromCString(name)!)
                        // Get column type
                        columnTypes.append(self.getColumnType(index, stmt: statme.memory))
                    }
                    fetchColumnInfo = false
                }
                var row = SQLRow()
                for index in 0..<columnCount {
                    let key = columnNames[Int(index)]
                    let type = columnTypes[Int(index)]
                    if let val:AnyObject = self.getColumnValue(index, type: type, stmt: statme.memory) {
                        let col = SQLColumn(value: val, type: type)
                        row[key] = col
                    }
                }
                rows.append(row)
                // Next row
                result = sqlite3_step(statme.memory)
            }
            sqlite3_finalize(statme.memory)
        }
        return rows
    }
    
    func getColumnType(index:CInt, stmt:COpaquePointer)->CInt {
        var type:CInt = 0
        // Column types - http://www.sqlite.org/datatype3.html (section 2.2 table column 1)
        let blobTypes = ["BINARY", "BLOB", "VARBINARY"]
        let charTypes = ["CHAR", "CHARACTER", "CLOB", "NATIONAL VARYING CHARACTER", "NATIVE CHARACTER", "NCHAR", "NVARCHAR", "TEXT", "VARCHAR", "VARIANT", "VARYING CHARACTER"]
        let dateTypes = ["DATE", "DATETIME", "TIME", "TIMESTAMP"]
        let intTypes  = ["BIGINT", "BIT", "BOOL", "BOOLEAN", "INT", "INT2", "INT8", "INTEGER", "MEDIUMINT", "SMALLINT", "TINYINT"]
        let nullTypes = ["NULL"]
        let realTypes = ["DECIMAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "REAL"]
        // Determine type of column - http://www.sqlite.org/c3ref/c_blob.html
        let buf = sqlite3_column_decltype(stmt, index)
        //		println("SQLiteDB - Got column type: \(buf)")
        if buf != nil {
            var tmp = String.fromCString(buf)!.uppercaseString
            // Remove brackets
            let pos = tmp.positionOf("(")
            if pos > 0 {
                tmp = tmp.subStringTo(pos)
            }
            // Remove unsigned?
            // Remove spaces
            // Is the data type in any of the pre-set values?
            //			println("SQLiteDB - Cleaned up column type: \(tmp)")
            if contains(intTypes, tmp) {
                return SQLITE_INTEGER
            }
            if contains(realTypes, tmp) {
                return SQLITE_FLOAT
            }
            if contains(charTypes, tmp) {
                return SQLITE_TEXT
            }
            if contains(blobTypes, tmp) {
                return SQLITE_BLOB
            }
            if contains(nullTypes, tmp) {
                return SQLITE_NULL
            }
            if contains(dateTypes, tmp) {
                return SQLITE_DATE
            }
            return SQLITE_TEXT
        } else {
            // For expressions and sub-queries
            type = sqlite3_column_type(stmt, index)
        }
        return type
    }
    
    
    func getColumnValue(index:CInt, type:CInt, stmt:COpaquePointer)->AnyObject? {
        // Integer
        if type == SQLITE_INTEGER {
            let val = sqlite3_column_int64(stmt, index)
            return NSNumber(longLong: val)
        }
        // Float
        if type == SQLITE_FLOAT {
            let val = sqlite3_column_double(stmt, index)
            return Double(val)
        }
        // Text - handled by default handler at end
        // Blob
        if type == SQLITE_BLOB {
            let data = sqlite3_column_blob(stmt, index)
            let size = sqlite3_column_bytes(stmt, index)
            let val = NSData(bytes:data, length: Int(size))
            return val
        }
        // Null
        if type == SQLITE_NULL {
            return nil
        }
        // Date
        if type == SQLITE_DATE {
            // Is this a text date
            let txt = UnsafePointer<Int8>(sqlite3_column_text(stmt, index))
            if txt != nil {
                let buf = NSString(CString:txt, encoding:NSUTF8StringEncoding)!
                let set = NSCharacterSet(charactersInString: "-:")
                let range = buf.rangeOfCharacterFromSet(set)
                if range.location != NSNotFound {
                    // Convert to time
                    var time:tm = tm(tm_sec: 0, tm_min: 0, tm_hour: 0, tm_mday: 0, tm_mon: 0, tm_year: 0, tm_wday: 0, tm_yday: 0, tm_isdst: 0, tm_gmtoff: 0, tm_zone:nil)
                    strptime(txt, "%Y-%m-%d %H:%M:%S", &time)
                    time.tm_isdst = -1
                    let diff = NSTimeZone.localTimeZone().secondsFromGMT
                    let t = mktime(&time) + diff
                    let ti = NSTimeInterval(t)
                    let val = NSDate(timeIntervalSince1970:ti)
                    return val
                }
            }
            // If not a text date, then it's a time interval
            let val = sqlite3_column_double(stmt, index)
            let dt = NSDate(timeIntervalSince1970: val)
            return dt
        }
        // If nothing works, return a string representation
        let buf = UnsafePointer<Int8>(sqlite3_column_text(stmt, index))
        let val = String.fromCString(buf)
        //		println("SQLiteDB - Got value: \(val)")
        return val
    }
}
