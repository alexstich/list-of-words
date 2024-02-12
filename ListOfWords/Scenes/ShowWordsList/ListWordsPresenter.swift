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
    func presentFetchedListWords(response: ListWords.FetchListWords.Response)
}

final class ListWordsPresenter: ListWordsPresentationLogic
{
    weak var viewController: ListWordsDisplayLogic?
    
    func presentFetchedListWords(response: ListWords.FetchListWords.Response)
    {
        let viewModel = ListWords.FetchListWords.ViewModel(displayedWords: response.listWords)
        viewController?.displayFetchedListWords(viewModel: viewModel)
    }
}
