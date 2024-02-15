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
        DatabaseManager.shared.fetchWords(excludingWords: excludingWords, limit: limit, offset: offset) { words in
            completion(words)
        }
    }
    
    func fetchFavoriteListWords(completion: @escaping ([String])->Void)
    {
        DatabaseManager.shared.fetchFavoriteWords { words in
            completion(words)
        }
    }
    
    func addToListWords(word: String)
    {
        DatabaseManager.shared.insertWord(word: word)
    }
}
