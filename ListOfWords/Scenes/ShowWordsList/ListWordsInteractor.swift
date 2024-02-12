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

    
    func fetchListWords(request: ListWords.FetchListWords.Request)
    {
        fetchListWords()
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
            fetchListWords()
        }
    }
    
    private func fetchListWords()
    {
        worker = ListWordsWorker()
        
        worker?.fetchListWords(excludingWords: favoriteWords, limit: 100, offset: fullListWords.count) { [weak self] listWords in
            
            self?.fullListWords = self!.fullListWords + listWords
            
            let response = ListWords.FetchListWords.Response(listWords: listWords)
            self?.presenter?.presentFetchedListWords(response: response)
        }
    }
}
