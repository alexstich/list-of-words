//
//  ListWordsInteractor.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 10.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

protocol ListWordsBusinessLogic
{
    func fetchListWords(request: ListWords.FetchListWords.Request)
    func selectWord(request: ListWords.FetchListWords.Request)
}

protocol ListWordsDataStore
{
    var selectedWord: ListWords.FetchListWords.ViewModel.Word? { get set }
}

final class ListWordsInteractor: ListWordsBusinessLogic, ListWordsDataStore
{
    var presenter: ListWordsPresentationLogic?
    var worker: ListWordsWorker?
    
    var fullListWords: ListWords.FetchListWords.ViewModel.Words = []
    var favouriteWords: ListWords.FetchListWords.ViewModel.Word? = nil
    var selectedWord: ListWords.FetchListWords.ViewModel.Word? = nil

    
    func fetchListWords(request: ListWords.FetchListWords.Request)
    {
        worker = ListWordsWorker()
        
        worker?.fetchListWords() { [weak self] listWords in
            
            self?.listWords = listWords
            
            let response = ListWords.FetchListWords.Response(listWords: listWords)
            self?.presenter?.presentFetchedListWords(response: response)
        }
    }
}
