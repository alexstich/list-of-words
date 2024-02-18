//
//  DatabaseManager.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 12.02.24.

//  With ChatGPT assistance ))
//

import Foundation
import SQLite3

class DBManager 
{
    static let shared = DBManager()
    
    private var db: OpaquePointer?
    
    private let queue = DispatchQueue(label: "DatabaseQueue")
    
    private init() 
    {
        openDatabase()
        createTables()
    }
    
    private func openDatabase() 
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("db.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error base openning")
        }
    }
    
    func refreshDbTables(completion: @escaping ()->Void)
    {
        dropTables()
        createFavoriteWordTable()
        createWordTable() {
            completion()
        }
    }
    
    private func createTables() 
    {
        createWordTable()
        createFavoriteWordTable()
    }
    
    func isWordTableFilled() -> Bool
    {
        return self.isWordTableNotEmpty()
    }
    
    func fillWordTableFrom(array: [String], completion: (()->Void)?)
    {
        queue.async {
            
            let batchSize = 1000
            
            for start in stride(from: 0, to: array.count, by: batchSize) {
                let end = min(start + batchSize, array.count)
                let batch = Array(array[start..<end])
                self.insertWords(words: batch)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion?()
            }
        }
    }
    
    private func isWordTableNotEmpty() -> Bool 
    {
        let query = "SELECT EXISTS(SELECT 1 FROM word LIMIT 1);"
        var statement: OpaquePointer?
        var isNotEmpty = false

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                isNotEmpty = sqlite3_column_int(statement, 0) > 0
            }
            sqlite3_finalize(statement)
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error SELECT request: \(errorMessage)")
        }
        
        return isNotEmpty
    }
    
    func allWordCount(completion: @escaping (Int)->Void)
    {
        queue.async {
            
            let queryStatementString = "SELECT COUNT(*) FROM word;"
            var queryStatement: OpaquePointer?
            var count = 0
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    count = Int(sqlite3_column_int(queryStatement, 0))
                }
            } else {
                print("SELECT COUNT statement could not be prepared.")
            }
            sqlite3_finalize(queryStatement)
            
            DispatchQueue.main.async {
                completion(count)
            }
        }
    }
    
    func insertWord(word: String, completion: @escaping (Int)->Void)
    {
        queue.async {
            let insertStatementString = "INSERT INTO word (word) VALUES (?);"
            
            var insertStatement: OpaquePointer?
            if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, (word as NSString).utf8String, -1, nil)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Word has added successful.")
                } else {
                    print("Word hasn't added.")
                }
            } else {
                print("INSERT statement could not be prepared.")
            }
            sqlite3_finalize(insertStatement)
            
            let queryStatementString = "SELECT COUNT(*) FROM word;"
            var queryStatement: OpaquePointer?
            var count = 0
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    count = Int(sqlite3_column_int(queryStatement, 0))
                }
            } else {
                print("SELECT COUNT statement could not be prepared.")
            }
            sqlite3_finalize(queryStatement)
            
            DispatchQueue.main.async {
                completion(count)
            }
        }
    }
    
    func insertWords(words: [String])
    {
        guard words.count > 0 else { return }
        
        queue.async {
            
            let wordsPlaceholder = words.map{ _ in "(?)" }.joined(separator: ",")
            
            let insertStatementString = "INSERT INTO word (word) VALUES \(wordsPlaceholder);"
            
            var insertStatement: OpaquePointer?
            if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {

                for (index, word) in words.enumerated() {
                    sqlite3_bind_text(insertStatement, Int32(index + 1), (word as NSString).utf8String, -1, nil)
                }
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Words has added successful.")
                } else {
                    print("Words hasn't added.")
                }
            } else {
                print("INSERT statement could not be prepared.")
            }
            sqlite3_finalize(insertStatement)
        }
    }
    
    func fetchRawNumberOfDeletingWord(word: String, completion: ((Int32?)->Void)?)
    {
        queue.async {
            
            let queryStatementString = "SELECT id FROM word WHERE word = ? ORDER BY id DESC LIMIT 1;"
            var queryStatement: OpaquePointer?
            var wordId: Int32 = -1
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(queryStatement, 1, (word as NSString).utf8String, -1, nil)
                
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    wordId = sqlite3_column_int(queryStatement, 0)
                }
            } else {
                print("Error SELECT request")
            }
            
            sqlite3_finalize(queryStatement)
            
            let queryNumberStatementString = "SELECT COUNT(id) as raw_number FROM word WHERE id <= ? ORDER BY id ASC;"
            var queryNumberStatement: OpaquePointer?
            var rawNumber: Int32? = nil
            
            if sqlite3_prepare_v2(self.db, queryNumberStatementString, -1, &queryNumberStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(queryNumberStatement, 1, wordId)
                
                if sqlite3_step(queryNumberStatement) == SQLITE_ROW {
                    rawNumber = sqlite3_column_int(queryNumberStatement, 0)
                }
            } else {
                print("Error SELECT request")
            }
            
            sqlite3_finalize(queryStatement)
            
            DispatchQueue.main.async {
                completion?(rawNumber)
            }
        }
    }
    
    func deleteWord(word: String)
    {
        queue.async {
            
            let queryStatementString = "SELECT id FROM word WHERE word = ? ORDER BY id DESC LIMIT 1;"
            var queryStatement: OpaquePointer?
            var wordIdToDelete: Int32 = -1
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(queryStatement, 1, (word as NSString).utf8String, -1, nil)
                
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    wordIdToDelete = sqlite3_column_int(queryStatement, 0)
                }
            } else {
                print("Error SELECT request")
            }
            
            sqlite3_finalize(queryStatement)
            
            if wordIdToDelete != -1 {
                let deleteStatementString = "DELETE FROM word WHERE id = ?;"
                var deleteStatement: OpaquePointer?
                
                if sqlite3_prepare_v2(self.db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                    sqlite3_bind_int(deleteStatement, 1, wordIdToDelete)
                    
                    if sqlite3_step(deleteStatement) == SQLITE_DONE {
                        print("Word has deleted successful '\(word)' и Id: \(wordIdToDelete)")
                    } else {
                        print("Word hasn't deleted")
                    }
                } else {
                    print("Error DELETE request")
                }
                sqlite3_finalize(deleteStatement)
            } else {
                print("Word not found '\(word)'")
            }
        }
    }
    
    func fetchWords(excludingWords excludedWords: [String], distinct: Bool = true, limit: Int = 100, offset: Int = 0, completion: @escaping ([String])->Void)
    {
        queue.async {
            
            let excludedWordsPlaceholder = excludedWords.map{ _ in "?" }.joined(separator: ",")
            
            var queryStatementString = ""
            
            if distinct {
                queryStatementString = """
        SELECT DISTINCT(word) FROM word WHERE word NOT IN (\(excludedWordsPlaceholder)) ORDER BY id ASC LIMIT ? OFFSET ?;
        """
            } else {
                queryStatementString = """
        SELECT word FROM word WHERE word NOT IN (\(excludedWordsPlaceholder)) ORDER BY id ASC LIMIT ? OFFSET ?;
        """
            }
            var queryStatement: OpaquePointer?
            
            var words = [String]()
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                for (index, name) in excludedWords.enumerated() {
                    sqlite3_bind_text(queryStatement, Int32(index + 1), (name as NSString).utf8String, -1, nil)
                }
                
                sqlite3_bind_int(queryStatement, Int32(excludedWords.count + 1), Int32(limit))
                sqlite3_bind_int(queryStatement, Int32(excludedWords.count + 2), Int32(offset))
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    guard let queryResultCol1 = sqlite3_column_text(queryStatement, 0) else {
                        print("Error raw reading")
                        continue
                    }
                    let word = String(cString: queryResultCol1)
                    words.append(word)
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(self.db))
                print("Error SELECT request: \(errorMessage)")
            }
            
            sqlite3_finalize(queryStatement)
            
            DispatchQueue.main.async {
                completion(words)
            }
        }
    }
    
    func wordCount(word: String, completion: @escaping (Int)->Void)
    {
        queue.async {
            
            let queryStatementString = "SELECT COUNT(*) FROM word WHERE word = ?;"
            var queryStatement: OpaquePointer?
            var count = 0
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(queryStatement, 1, (word as NSString).utf8String, -1, nil)
                
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    count = Int(sqlite3_column_int(queryStatement, 0))
                }
            } else {
                print("SELECT COUNT statement could not be prepared.")
            }
            sqlite3_finalize(queryStatement)
            
            DispatchQueue.main.async {
                completion(count)
            }
        }
    }

    func insertFavoriteWord(word: String) 
    {
        queue.async {
            
            let insertStatementString = "INSERT INTO favorite_word (word) VALUES (?);"
            
            var insertStatement: OpaquePointer?
            if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, (word as NSString).utf8String, -1, nil)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Favorite word has added successful.")
                } else {
                    print("Favorite word hasn't added.")
                }
            } else {
                print("INSERT statement could not be prepared.")
            }
            sqlite3_finalize(insertStatement)
        }
    }
    
    func deleteFavoriteWord(word: String) 
    {
        queue.async {
            
            let deleteStatementString = "DELETE FROM favorite_word WHERE word = ?;"
            var deleteStatement: OpaquePointer?
            
            if sqlite3_prepare_v2(self.db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(deleteStatement, 1, (word as NSString).utf8String, -1, nil)
                
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("Favorite word has deleted successful: \(word).")
                } else {
                    print("Favorite word hasn't deleted.")
                }
            } else {
                print("DELETE statement could not be prepared.")
            }
            
            sqlite3_finalize(deleteStatement)
        }
    }
    
    func fetchFavoriteWords(limit: Int? = nil, offset: Int = 0, completion: @escaping ([String])->Void)
    {
        queue.async {
            
            var queryStatementString: String
            if limit != nil {
                queryStatementString = "SELECT word FROM favorite_word ORDER BY id ASC LIMIT ? OFFSET ?;"
            } else {
                queryStatementString = "SELECT word FROM favorite_word ORDER BY id ASC;"
            }
            
            var queryStatement: OpaquePointer?
            
            var words = [String]()
            
            if limit != nil {
                sqlite3_bind_int(queryStatement, 1, Int32(limit!))
                sqlite3_bind_int(queryStatement, 2, Int32(offset))
            }
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    if let result = sqlite3_column_text(queryStatement, 0) {
                        let word = String(describing: String(cString: result))
                        words.append(word)
                    }
                }
            } else {
                print("SELECT statement could not be prepared")
            }
            
            sqlite3_finalize(queryStatement)
            
            DispatchQueue.main.async {
                completion(words)
            }
        }
    }
    
    func favoriteWordCount(word: String, completion: @escaping (Int)->Void)
    {
        queue.async {
            
            let queryStatementString = "SELECT COUNT(*) FROM favorite_word WHERE word = ?;"
            var queryStatement: OpaquePointer?
            var count = 0
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(queryStatement, 1, (word as NSString).utf8String, -1, nil)
                
                if sqlite3_step(queryStatement) == SQLITE_ROW {
                    count = Int(sqlite3_column_int(queryStatement, 0))
                }
            } else {
                print("SELECT COUNT statement could not be prepared.")
            }
            sqlite3_finalize(queryStatement)
            
            DispatchQueue.main.async {
                completion(count)
            }
        }
    }
    
    private func dropTables()
    {
        queue.async {
            
            var errMsg: UnsafeMutablePointer<Int8>?
            
            let dropWordTableSQL = "DROP TABLE IF EXISTS word;"
            
            if sqlite3_exec(self.db, dropWordTableSQL, nil, nil, &errMsg) != SQLITE_OK {
                let errorMessage = String(cString: errMsg!)
                print("Drop table error: word - \(errorMessage)")
            } else {
                print("Table word successful droped.")
            }
            
            let dropFavoriteTableSQL = "DROP TABLE IF EXISTS favorite_word;"
            
            if sqlite3_exec(self.db, dropFavoriteTableSQL, nil, nil, &errMsg) != SQLITE_OK {
                let errorMessage = String(cString: errMsg!)
                print("Drop table error: favorite_word - \(errorMessage)")
            } else {
                print("Table favorite_word successful droped.")
            }
        }
    }
    
    private func createWordTable(completion: (()->Void)? = nil)
    {
        queue.async {
            
            let createWordTableCommand = """
        CREATE TABLE IF NOT EXISTS word(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word CHAR(255)
        );
        """
            
            var createWordTableStatement: OpaquePointer?
            
            if sqlite3_prepare_v2(self.db, createWordTableCommand, -1, &createWordTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createWordTableStatement) == SQLITE_DONE {
                    print("Table word created successful")
                } else {
                    print("Table word hasn't created")
                }
                
            } else {
                print("CREATE TABLE statement could not be prepared")
            }
            
            sqlite3_finalize(createWordTableStatement)
            
            var createIndexStatement: OpaquePointer?
            let createIndexStatementString = "CREATE INDEX IF NOT EXISTS idx_word_word ON word(word);"
            
            if sqlite3_prepare_v2(self.db, createIndexStatementString, -1, &createIndexStatement, nil) == SQLITE_OK {
                if sqlite3_step(createIndexStatement) == SQLITE_DONE {
                    print("Index for word.word has created")
                } else {
                    print("Index for word.word hasn't created")
                }
            } else {
                print("CREATE INDEX statement could not be prepared")
            }
            sqlite3_finalize(createIndexStatement)
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    private func createFavoriteWordTable()
    {
        queue.async {
            let createFavoriteWordTableCommand = """
        CREATE TABLE IF NOT EXISTS favorite_word(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word CHAR(255)
        );
        """
            
            var createFavoriteWordTableStatement: OpaquePointer?
            
            if sqlite3_prepare_v2(self.db, createFavoriteWordTableCommand, -1, &createFavoriteWordTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createFavoriteWordTableStatement) == SQLITE_DONE {
                    print("Table favorite_word has created successful")
                } else {
                    print("Table favorite_word hasn't created")
                }
                
            } else {
                print("CREATE TABLE statement could not be prepared")
            }
            
            sqlite3_finalize(createFavoriteWordTableStatement)
            
            var createIndexStatement: OpaquePointer?
            let createIndexStatementString = "CREATE INDEX IF NOT EXISTS idx_favorite_word_word ON favorite_word(word);"
            
            if sqlite3_prepare_v2(self.db, createIndexStatementString, -1, &createIndexStatement, nil) == SQLITE_OK {
                if sqlite3_step(createIndexStatement) == SQLITE_DONE {
                    print("Index for favorite_word.word has created")
                } else {
                    print("Index for favorite_word.word hasn't created")
                }
            } else {
                print("CREATE INDEX statement could not be prepared")
            }
            sqlite3_finalize(createIndexStatement)
        }
    }

    
    deinit {
        sqlite3_close(db)
    }
}

struct DMWord {
    let id: Int
    let word: String
}
