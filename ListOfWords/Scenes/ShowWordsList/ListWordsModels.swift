//
//  ListWordsModels.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 10.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

enum ListWords
{

    // MARK: Use cases
    
    enum FetchAllWords
    {
        struct Request 
        {
            let mode: ListWordsInteractor.FetchingMode
        }
        
        struct Response
        {
            var listWords: Words
            var favoriteListWords: Words
        }
        
        struct ViewModel
        {
            var displayedWords: Words
            var displayedFavoriteWords: Words
        }
    }
    
    enum SelectWord
    {
        struct Request 
        {
            var indexPath: IndexPath
        }
        
        struct Response
        {
            var word: Word
        }
        
        struct ViewModel
        {
            var word: Word
        }
    }
    
    enum AddWord
    {
        enum Result {
            case success, failure
        }
        
        struct Request
        {
            var word: Word?
        }
        
        struct Response
        {
            var success: Bool = false
            var word: Word?
        }
        
        struct ViewModel
        {
            var word: Word?
            var result: Result = .failure
        }
    }
}
