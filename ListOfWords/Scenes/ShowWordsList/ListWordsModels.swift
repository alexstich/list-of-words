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
    
    enum FetchListWords
    {
        struct Request {}
        
        struct Response
        {
            var listWords: ViewModel.Words
        }
        
        struct ViewModel
        {
            typealias Word = String
            typealias Words = [String]
            
            var displayedWords: Words
        }
    }
    
    enum SelectWord
    {
        struct Request {}
        
        struct Response
        {
            var word: ViewModel.Word
        }
        
        struct ViewModel
        {
            typealias Word = String
            var word: Word
        }
    }
    
    enum AddWord
    {
        struct Request {}
        
        struct Response
        {
            var word: ViewModel.Word
        }
        
        struct ViewModel
        {
            typealias Word = String
            var word: Word
        }
    }
}
