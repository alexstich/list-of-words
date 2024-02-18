//
//  Result.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 18.02.24.
//

import Foundation

enum Result<Success, Failure: Error> 
{
    case success(Success)
    case failure(Failure)

    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
