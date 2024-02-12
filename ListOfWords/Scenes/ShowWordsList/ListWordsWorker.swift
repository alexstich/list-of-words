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
    func fetchListWords(excludingWords: [String], limit: Int, offset: Int, completion: ([String])->Void)
    {
        let words = DatabaseManager.shared.fetchWords(excludingWords: excludingWords, limit: limit, offset: offset)
        
        completion(words)
    }
    
    func addToListWords(word: String)
    {
        DatabaseManager.shared.insertWord(word: word)
    }
}
