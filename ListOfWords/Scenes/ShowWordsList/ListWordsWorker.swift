//
//  ListWordsWorker.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 10.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

final class ListWordsWorker
{
    func fetchListWords(excludingWords: [String], limit: Int, offset: Int, completion: @escaping ([String])->Void)
    {
        DataProvider().fetchListWords(excludingWords: excludingWords, limit: limit, offset: offset) { words in
            completion(words)
        }
    }
    
    func fetchFavoriteListWords(completion: @escaping ([String])->Void)
    {
        DataProvider().fetchFavoriteListWords { words in
            completion(words)
        }
    }
    
    func addToListWords(word: String, completion:  ((Int)->Void)?)
    {
        DataProvider().addToListWords(word: word, completion: { wordPosition in
            completion?(wordPosition)
        })
    }
    
    func selectAndMoveFile(sourceURL: URL, completion: @escaping (Bool, Error?) -> Void) 
    {
        guard let destinationURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(DataProvider().configuration.fileURL.lastPathComponent) else {
            print("There is no destination path")
            return
        }
        
        do {
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            
            print("File moved: \(destinationURL.path)")
            
            completion(true, nil)
        } catch {
            
            print("File moving error: \(error)")
            
            completion(false, error)
        }
    }
    
    func refreshDBTables(completion: @escaping (Bool, Error?)->Void)
    {
        DataProvider().refreshDBTables() { isSuccesful, error in
            completion(isSuccesful, error)
        }
    }
}
