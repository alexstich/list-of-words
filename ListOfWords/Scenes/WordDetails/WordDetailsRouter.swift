//
//  WordDetailsRouter.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 11.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

@objc protocol WordDetailsRoutingLogic
{
}

protocol WordDetailsDataPassing
{
    var dataStore: WordDetailsDataStore? { get }
}

class WordDetailsRouter: NSObject, WordDetailsRoutingLogic, WordDetailsDataPassing
{
    weak var viewController: WordDetailsViewController?
    var dataStore: WordDetailsDataStore?
}
