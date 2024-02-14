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
    
    enum AddWord
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
    
    enum DeleteWord
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
    
    enum MakeFavoriteWord
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
}
