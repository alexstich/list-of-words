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
        DataProvider().fetchWordNumberOccurrance(word: word) { number in
            completion(number)
        }
    }
    
    func fetchFavoriteWordOccurrance(word: String, completion: @escaping (Bool)->Void)
    {
        DataProvider().fetchFavoriteWordOccurrance(word: word) { number in
            completion(number > 0)
        }
    }
    
    func addToListWords(word: String, completion: @escaping (Int)->Void)
    {
        DataProvider().addToListWords(word: word) { wordPosition in
            completion(wordPosition)
        }
    }
    
    func addToFavoriteWords(word: String)
    {
        DataProvider().addToFavoriteWords(word: word)
    }
    
    func deleteFromListWords(word: String)
    {
        DataProvider().deleteFromListWords(word: word)
    }
    
    func deleteFromFavoriteWords(word: String)
    {
        DataProvider().deleteFromFavoriteWords(word: word)
    }
}
