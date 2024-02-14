//
//  WordDetailsPresenter.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 11.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

protocol WordDetailsPresentationLogic
{
    func presentNumberOccurrance(response: WordDetails.FetchNumberOccurrance.Response)
    func presentWord(response: WordDetails.FetchWord.Response)
}

class WordDetailsPresenter: WordDetailsPresentationLogic
{
    weak var viewController: WordDetailsDisplayLogic?
    
    func presentNumberOccurrance(response: WordDetails.FetchNumberOccurrance.Response)
    {
        let viewModel = WordDetails.FetchNumberOccurrance.ViewModel(number: response.number)
        viewController?.displayNumberOccurrance(viewModel: viewModel)
    }
    
    func presentWord(response: WordDetails.FetchWord.Response)
    {
        let viewModel = WordDetails.FetchWord.ViewModel(word: response.word)
        viewController?.displayWord(viewModel: viewModel)
    }
}
