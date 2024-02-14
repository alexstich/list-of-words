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
    func fetchNumberOccurrance(word: String, completion: @escaping (Int)->Void)
    {
        DatabaseManager.shared.wordCount(word: word) { number in
            completion(number)
        }
    }
}
