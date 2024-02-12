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
    typealias Word = String
    typealias Words = [String]
    
    // MARK: Use cases
    
    enum FetchListWords
    {
        struct Request {}
        
        struct Response
        {
            var listWords: Words
        }
        
        struct ViewModel
        {
            var displayedWords: Words
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
            var show: Bool = false
        }
    }
}
