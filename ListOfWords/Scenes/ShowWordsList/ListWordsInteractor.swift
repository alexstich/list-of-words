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
    func pickFile(request: ListWords.PickFile.Request)
    func refreshDBTables(request: ListWords.RefreshDBTAbles.Request)
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
            
            worker?.addToListWords(word: request.word!, completion: nil)
            
            fetchAllWords(mode: .fetch_next)
            
            let response = ListWords.AddWord.Response(result:  .success(request.word!))
            presenter?.presentAddWordResult(response: response)
        }
    }
    
    func pickFile(request: ListWords.PickFile.Request)
    {
        worker?.selectAndMoveFile(sourceURL: request.fileURL, completion: { (isSuccessful, error) in
            if isSuccessful {
                self.presenter?.presentFileMovedResult(response: ListWords.PickFile.Response(result: .success(true)))
            } else if let error = error {
                let error_ = NSError(domain: "Copying file error:\n\(error.localizedDescription)", code: 0)
                self.presenter?.presentFileMovedResult(response: ListWords.PickFile.Response(result: .failure(error_)))
            }
        })
    }
    
    func refreshDBTables(request: ListWords.RefreshDBTAbles.Request) 
    {
        worker?.refreshDBTables() { [weak self] (isSuccessful, error) in
            if isSuccessful {
                
                self?.favoriteWords = []
                self?.fullListWords = []
                
                self?.fetchAllWords(mode: .fetch_next)
                
            } else if let error = error {
                
                let error_ = NSError(domain: "Refreshing table error:\n\(error.localizedDescription)", code: 0)
                let response = ListWords.FetchAllWords.Response(result: .failure(error_))
                self?.presenter?.presentFetchedAllWords(response: response)
            }
        }
    }
    
    private func fetchAllWords(mode: FetchingMode)
    {
        worker = ListWordsWorker()

        worker?.fetchFavoriteListWords { [weak self] favoriteListWords in

            guard let self = self else { return }
            self.favoriteWords = favoriteListWords
            
            self.fetchListWords(mode: mode, completion: { [weak self, favoriteListWords] listWords in
                let response = ListWords.FetchAllWords.Response(result: .success(ListWords.FetchAllWords.Lists(listWords: listWords, favoriteListWords: favoriteListWords)))
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
