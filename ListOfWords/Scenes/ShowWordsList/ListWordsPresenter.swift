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
}

final class ListWordsPresenter: ListWordsPresentationLogic
{
    weak var viewController: ListWordsDisplayLogic?
    
    func presentFetchedAllWords(response: ListWords.FetchAllWords.Response)
    {
        let viewModel = ListWords.FetchAllWords.ViewModel(displayedWords: response.listWords, displayedFavoriteWords: response.favoriteListWords)
        viewController?.displayFetchedAllWords(viewModel: viewModel)
    }
    
    func presentAddWordResult(response: ListWords.AddWord.Response)
    {
        let viewModel = ListWords.AddWord.ViewModel(result: response.success ? .success : .failure)
        viewController?.displayAddWordResult(viewModel: viewModel)
    }
}
