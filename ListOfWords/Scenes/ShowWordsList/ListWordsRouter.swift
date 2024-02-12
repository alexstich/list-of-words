//
//  ListWordsRouter.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 10.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

@objc protocol ListWordsRoutingLogic
{
    func routeToWordDetails(segue: UIStoryboardSegue?)
}

protocol ListWordsDataPassing
{
    var dataStore: ListWordsDataStore? { get }
}

final class ListWordsRouter: NSObject, ListWordsRoutingLogic, ListWordsDataPassing
{
    weak var viewController: ListWordsViewController?
    var dataStore: ListWordsDataStore?
    
    // MARK: Routing
    
    func routeToWordDetails(segue: UIStoryboardSegue?)
    {
        if let segue = segue {
            let destinationVC = segue.destination as! WordDetailsViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToWordDetails(source: dataStore!, destination: &destinationDS)
        } else {
            let destinationVC = WordDetailsViewController()
            var destinationDS = destinationVC.router!.dataStore!
            passDataToWordDetails(source: dataStore!, destination: &destinationDS)
            navigateToWordDetails(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToWordDetails(source: ListWordsViewController, destination: WordDetailsViewController)
    {
        source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToWordDetails(source: ListWordsDataStore, destination: inout WordDetailsDataStore)
    {
        destination.word = source.selectedWord
    }
}
