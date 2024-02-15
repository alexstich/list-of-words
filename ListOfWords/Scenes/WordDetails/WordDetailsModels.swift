//
//  WordDetailsModels.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 11.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

enum WordDetails
{
    typealias Word = String
    typealias Words = [String]
    
    // MARK: Use cases
    
    enum FetchWord
    {
        struct Request
        {
        }
        struct Response
        {
            let word: String
        }
        struct ViewModel
        {
            let word: String
        }
    }
    
    enum FetchNumberOccurrance
    {
        struct Request
        {
        }
        struct Response
        {
            let number: Int
        }
        struct ViewModel
        {
            let number: Int
        }
    }
    
    enum FetchFavoriteOccurrance
    {
        struct Request
        {
        }
        struct Response
        {
            let isFavorite: Bool
        }
        struct ViewModel
        {
            let isFavorite: Bool
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
    
    enum DeleteWord
    {
        enum Result {
            case success, failure
        }
        struct Request
        {
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
    
    enum ToggleFavoriteStatus
    {
        struct Request
        {
        }
        struct Response
        {
            let isFavorite: Bool
        }
        struct ViewModel
        {
            let isFavorite: Bool
        }
    }
}
