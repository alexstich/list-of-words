//
//  ResponseError.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 14.02.24.
//

import Foundation

enum ResponseError: Error
{
    case dataFetchError
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .dataFetchError:
            return "Data could not be loaded"
        case .networkError:
            return "The network is not available"
        }
    }
}
