//
//  DataProvider.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 17.02.24.
//

import Foundation

final class DataProvider
{
    private(set) var configuration: DataProviderConfiguration
    
    init()
    {
        self.configuration = DataProviderConfiguration.shared
    }
    
    func refreshDBTables(completion: @escaping (Bool, Error?)->Void)
    {
        DBManager.shared.refreshDbTables() {
            
            do {
                let content = try String(contentsOfFile: self.configuration.fileURL.path, encoding: .utf8)
                let wordsArray = content.components(separatedBy: "\n")
                DBManager.shared.fillWordTableFrom(array: wordsArray) {
                    completion(true, nil)
                    return
                }

            } catch {
                print("File reading error occur: \(error.localizedDescription)")
                completion(false, error)
            }
        }
    }
    
    func fetchListWords(excludingWords: [String], limit: Int, offset: Int, completion: @escaping ([String])->Void)
    {
        DBManager.shared.fetchWords(excludingWords: excludingWords, limit: limit, offset: offset) { words in
            completion(words)
        }
    }
    
    func fetchFavoriteListWords(completion: @escaping ([String])->Void)
    {
        DBManager.shared.fetchFavoriteWords { words in
            completion(words)
        }
    }
    
    func addToListWords(word: String, completion: @escaping (Int)->Void)
    {
        let path = configuration.fileURL.path
        
        DBManager.shared.insertWord(word: word) { wordPosition in
            FileProcessor.shared.appendLineToFile(atPath: path, word: word, completion: nil)
            completion(wordPosition)
        }
    }
    
    func addToFavoriteWords(word: String)
    {
        DBManager.shared.insertFavoriteWord(word: word)
    }
    
    func fetchWordNumberOccurrance(word: String, completion: @escaping (Int)->Void)
    {
        DBManager.shared.wordCount(word: word) { number in
            completion(number)
        }
    }
    
    func fetchFavoriteWordOccurrance(word: String, completion: @escaping (Int)->Void)
    {
        DBManager.shared.favoriteWordCount(word: word) { number in
            completion(number)
        }
    }
    
    func deleteFromListWords(word: String)
    {
        let path = configuration.fileURL.path
        
        DBManager.shared.fetchRawNumberOfDeletingWord(word: word) { lineNumber in
            if let lineNumber = lineNumber {
                FileProcessor.shared.removeLineFromFile(atPath: path, lineNumber: lineNumber, completion: nil)
            }
            
            DBManager.shared.deleteWord(word: word)
        }
    }
    
    func deleteFromFavoriteWords(word: String)
    {
        DBManager.shared.deleteFavoriteWord(word: word)
    }
}
