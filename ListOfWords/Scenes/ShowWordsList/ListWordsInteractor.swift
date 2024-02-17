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
    func fetchAllWords(request: ListWords.FetchAllWords.Request)
    func selectWord(request: ListWords.SelectWord.Request)
    func addWord(request: ListWords.AddWord.Request)
}

protocol ListWordsDataStore
{
    var selectedWord: Word? { get set }
}

final class ListWordsInteractor: ListWordsBusinessLogic, ListWordsDataStore
{
    var presenter: ListWordsPresentationLogic?
    var worker: ListWordsWorker?
    
    var fullListWords: Words = []
    var favoriteWords: FavoriteWords = []
    var selectedWord: Word? = nil

    enum FetchingMode {
        case update_current, fetch_next
    }
    
    func fetchAllWords(request: ListWords.FetchAllWords.Request)
    {
        fetchAllWords(mode: request.mode)
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
            fetchAllWords(mode: .update_current)
            
            let response = ListWords.AddWord.Response(success: true, word: request.word!)
            presenter?.presentAddWordResult(response: response)
        }
    }
    
    private func fetchAllWords(mode: FetchingMode)
    {
        worker = ListWordsWorker()

        worker?.fetchFavoriteListWords { [weak self] favoriteListWords in

            guard let self = self else { return }
            self.favoriteWords = favoriteListWords
            
            self.fetchListWords(mode: mode, completion: { [weak self, favoriteListWords] listWords in
                let response = ListWords.FetchAllWords.Response(listWords: listWords, favoriteListWords: favoriteListWords)
                self?.presenter?.presentFetchedAllWords(response: response)
            })
        }
    }
    
    private func fetchListWords(mode: FetchingMode, completion: @escaping (Words)->Void)
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
            
            completion(self.fullListWords)
        }
    }
}
