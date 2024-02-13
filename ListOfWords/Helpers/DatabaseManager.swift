//
//  DatabaseManager.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 12.02.24.
//

import Foundation
import SQLite3

class DatabaseManager 
{
    static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    private let dbQueue = DispatchQueue(label: "DatabaseQueue")
    
    private init() 
    {
        openDatabase()
        createTables()
    }
    
    private func openDatabase() 
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("db.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Ошибка при открытии базы данных")
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
    
    func fillWordTableFrom(array: [String])
    {
        dbQueue.async {
            for value in array {
                self.insertWord(word: value)
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
    
    func insertWord(word: String) 
    {
        dbQueue.async {
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
        }
    }
    
    func deleteWord(word: String) 
    {
        dbQueue.async {
            
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

    func insertFavoriteWord(word: String) 
    {
        dbQueue.async {
            
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
        dbQueue.async {
            
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
        dbQueue.async {
            
            var queryStatementString: String
            if limit != nil {
                queryStatementString = "SELECT DISTINCT(word) FROM word ORDER BY id ASC LIMIT ? OFFSET ?;"
            } else {
                queryStatementString = "SELECT DISTINCT(word) FROM word ORDER BY id ASC;"
            }
            
            var queryStatement: OpaquePointer?
            
            var words = [String]()
            
            if limit != nil {
                sqlite3_bind_int(queryStatement, 1, Int32(limit!))
                sqlite3_bind_int(queryStatement, 2, Int32(offset))
            }
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let word = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                    words.append(word)
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

    func fetchWords(excludingWords excludedWords: [String], limit: Int = 100, offset: Int = 0, completion: @escaping ([String])->Void)
    {
        dbQueue.async {
            
            let excludedWordsPlaceholder = excludedWords.map{ _ in "?" }.joined(separator: ",")
            
            let queryStatementString = """
        SELECT * FROM word WHERE word NOT IN (\(excludedWordsPlaceholder)) ORDER BY id ASC LIMIT ? OFFSET ?;
        """
            var queryStatement: OpaquePointer?
            
            var words = [String]()
            
            if sqlite3_prepare_v2(self.db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                for (index, name) in excludedWords.enumerated() {
                    sqlite3_bind_text(queryStatement, Int32(index + 1), (name as NSString).utf8String, -1, nil)
                }
                
                sqlite3_bind_int(queryStatement, Int32(excludedWords.count + 1), Int32(limit))
                sqlite3_bind_int(queryStatement, Int32(excludedWords.count + 2), Int32(offset))
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
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
    
    private func createWordTable()
    {
        dbQueue.async {
            
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
        }
    }
    
    private func createFavoriteWordTable()
    {
        dbQueue.async {
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
