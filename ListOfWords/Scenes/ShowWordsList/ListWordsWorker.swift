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
    func fetchListWords(_ completion: (ListWords.FetchListWords.ViewModel.Words)->Void)
    {
        if let path = Bundle.main.path(forResource: "list_of_words", ofType: "txt"){
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let wordsArray = content.components(separatedBy: "\n")
                completion(wordsArray)
            } catch {
                print("File reading error ocure: \(error.localizedDescription)")
            }
        }
    }
}
