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
        struct Lists
        {
            var listWords: Words
            var favoriteListWords: Words
        }
        
        struct Request
        {
            let mode: ListWordsInteractor.FetchingMode
        }
        
        struct Response
        {
            var result: Result<Lists, Error>
        }
        
        struct ViewModel
        {
            var listWords: Words
            var favoriteListWords: Words
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
            var result: Result<Word?, Error>
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
            var result: Result<Word?, Error>
        }
        
        struct ViewModel
        {
            var word: Word?
        }
    }
    
    enum PickFile
    {
        struct Request{
            let fileURL: URL
        }
        
        struct Response
        {
            var result: Result<Bool, Error>
        }
        
        struct ViewModel{}
    }
    
    enum RefreshDBTAbles
    {
        struct Request{}
        
        struct Response{}
        
        struct ViewModel{}
    }
}
