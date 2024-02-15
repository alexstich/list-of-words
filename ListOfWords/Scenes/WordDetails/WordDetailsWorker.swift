//
//  WordDetailsWorker.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 11.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

class WordDetailsWorker
{
    func fetchWordNumberOccurrance(word: String, completion: @escaping (Int)->Void)
    {
        DatabaseManager.shared.wordCount(word: word) { number in
            completion(number)
        }
    }
    
    func fetchFavoriteWordOccurrance(word: String, completion: @escaping (Bool)->Void)
    {
        DatabaseManager.shared.favoriteWordCount(word: word) { number in
            completion(number > 0)
        }
    }
    
    func addToFavoriteWords(word: String)
    {
        DatabaseManager.shared.insertWord(word: word)
    }
    
    func deleteFromListWords(word: String)
    {
        DatabaseManager.shared.deleteWord(word: word)
    }
    
    func deleteFromFavoriteWords(word: String)
    {
        DatabaseManager.shared.deleteFavoriteWord(word: word)
    }
}
