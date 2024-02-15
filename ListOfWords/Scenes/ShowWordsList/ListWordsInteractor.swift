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
    func fetchFavoriteListWords(request: ListWords.FetchFavoriteListWords.Request)
    func selectWord(request: ListWords.SelectWord.Request)
    func addWord(request: ListWords.AddWord.Request)
}

protocol ListWordsDataStore
{
    var selectedWord: ListWords.Word? { get set }
}

final class ListWordsInteractor: ListWordsBusinessLogic, ListWordsDataStore
{
    var presenter: ListWordsPresentationLogic?
    var worker: ListWordsWorker?
    
    var fullListWords: ListWords.Words = []
    var favoriteWords: ListWords.Words = []
    var selectedWord: ListWords.Word? = nil

    enum FetchingMode {
        case update_current, fetch_next
    }
    
    func fetchListWords(request: ListWords.FetchListWords.Request)
    {
        fetchListWords(mode: .fetch_next)
    }
    
    func fetchFavoriteListWords(request: ListWords.FetchFavoriteListWords.Request)
    {
        worker = ListWordsWorker()
        
        worker?.fetchFavoriteListWords { [weak self] listWords in
            
            guard let self = self else { return }
            self.favoriteWords = listWords

            let response = ListWords.FetchFavoriteListWords.Response(favoriteListWords: self.favoriteWords)
            self.presenter?.presentFetchedFavoriteListWords(response: response)
        }
    }
    
    func selectWord(request: ListWords.SelectWord.Request) 
    {
        switch request.indexPath.section {
        case 0:
            self.selectedWord = favoriteWords[request.indexPath.row]
        case 1:
            self.selectedWord = fullListWords[request.indexPath.row]
        default:
            break
        }
    }
    
    func addWord(request: ListWords.AddWord.Request) 
    {
        if request.word != nil {
            worker?.addToListWords(word: request.word!)
            fetchListWords(mode: .update_current)
            
            let response = ListWords.AddWord.Response(success: true, word: request.word!)
            presenter?.presentAddWordResult(response: response)
        }
    }
    
    private func fetchListWords(mode: FetchingMode)
    {
        worker = ListWordsWorker()
        
        var limit = 100
        var offset = fullListWords.count
        
        if mode == .update_current {
            limit = fullListWords.count
            offset = 0
        }
        
        worker?.fetchListWords(excludingWords: favoriteWords, limit: limit, offset: offset) { [weak self, mode] listWords in
            
            guard let self = self else { return }
            
            if mode == .update_current {
                self.fullListWords = listWords
            } else if mode == .fetch_next {
                self.fullListWords = self.fullListWords + listWords
            }
            
            let response = ListWords.FetchListWords.Response(listWords: self.fullListWords)
            self.presenter?.presentFetchedListWords(response: response)
        }
    }
}
