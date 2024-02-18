//
//  ListWordsPresenter.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 10.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

protocol ListWordsPresentationLogic
{
    func presentFetchedAllWords(response: ListWords.FetchAllWords.Response)
    func presentAddWordResult(response: ListWords.AddWord.Response)
    func presentFileCopiedResult(response: ListWords.PickFile.Response)
}

final class ListWordsPresenter: ListWordsPresentationLogic
{
    weak var viewController: ListWordsDisplayLogic?
    
    func presentFetchedAllWords(response: ListWords.FetchAllWords.Response)
    {
        switch response.result {
        case .success(let lists):
            let viewModel = ListWords.FetchAllWords.ViewModel(listWords: lists.listWords, favoriteListWords: lists.favoriteListWords)
            viewController?.displayFetchedAllWords(viewModel: viewModel)
        case .failure(let error):
            viewController?.displayError(errorMessage: error.localizedDescription)
        }
    }
    
    func presentAddWordResult(response: ListWords.AddWord.Response)
    {
        switch response.result {
        case .success(let word):
            if word != nil {
                let viewModel = ListWords.AddWord.ViewModel(word: word!)
                viewController?.displayAddWordResult(viewModel: viewModel)
            }
        case .failure(let error):
            viewController?.displayError(errorMessage: error.localizedDescription)
        }
    }

    func presentFileCopiedResult(response: ListWords.PickFile.Response) 
    {
        switch response.result {
        case .success(_):
            let viewModel = ListWords.PickFile.ViewModel()
            viewController?.displayFileCopyResult(viewModel: viewModel)
        case .failure(let error):
            viewController?.displayError(errorMessage: error.localizedDescription)
        }
    }
}
