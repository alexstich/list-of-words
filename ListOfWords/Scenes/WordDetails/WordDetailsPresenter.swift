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
    func presentWord(response: WordDetails.FetchWord.Response)
    func presentNumberOccurrance(response: WordDetails.FetchNumberOccurrance.Response)
    func presentIsFavoriteWord(response: WordDetails.FetchFavoriteOccurrance.Response)
    func presentToggleFavoriteStatus(response: WordDetails.ToggleFavoriteStatus.Response)
    func presentAddWordResult(response: WordDetails.AddWord.Response)
    func presentDeleteWordResult(response: WordDetails.DeleteWord.Response)
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
    
    func presentIsFavoriteWord(response: WordDetails.FetchFavoriteOccurrance.Response)
    {
        let viewModel = WordDetails.FetchFavoriteOccurrance.ViewModel(isFavorite: response.isFavorite)
        viewController?.displayFavoriteStatus(viewModel: viewModel)
    }
    
    func presentToggleFavoriteStatus(response: WordDetails.ToggleFavoriteStatus.Response)
    {
        let viewModel = WordDetails.ToggleFavoriteStatus.ViewModel(isFavorite: response.isFavorite)
        viewController?.displayToggleFavoriteStatus(viewModel: viewModel)
    }
    
    func presentAddWordResult(response: WordDetails.AddWord.Response)
    {
        let viewModel = WordDetails.AddWord.ViewModel(result: response.success ? .success : .failure)
        viewController?.displayAddWordResult(viewModel: viewModel)
    }
    
    func presentDeleteWordResult(response: WordDetails.DeleteWord.Response)
    {
        let viewModel = WordDetails.DeleteWord.ViewModel(result: response.success ? .success : .failure)
        viewController?.displayDeleteWordResult(viewModel: viewModel)
    }
}
