//
//  WordDetailsInteractor.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 11.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

protocol WordDetailsBusinessLogic
{
    func fetchWord(request: WordDetails.FetchWord.Request)
    func fetchNumberOccurrance(request: WordDetails.FetchNumberOccurrance.Request)
    func addWord(request: WordDetails.AddWord.Request)
    func deleteWord(request: WordDetails.DeleteWord.Request)
    func markFavoriteWord(request: WordDetails.MakeFavoriteWord.Request)
}

protocol WordDetailsDataStore
{
    var word: String? { get set }
}

class WordDetailsInteractor: WordDetailsBusinessLogic, WordDetailsDataStore
{
    var word: String?
    var number: Int?
    
    var presenter: WordDetailsPresentationLogic?
    var worker: WordDetailsWorker?
    
    func fetchNumberOccurrance(request: WordDetails.FetchNumberOccurrance.Request)
    {
        worker = WordDetailsWorker()
        
        if let word = word {
            
            worker?.fetchNumberOccurrance(
                word: word,
                completion: { [weak self] number in
                    
                    self?.number = number
                    
                    let response = WordDetails.FetchNumberOccurrance.Response(number: number)
                    self?.presenter?.presentNumberOccurrance(response: response)
                }
            )
        }
    }
    
    func fetchWord(request: WordDetails.FetchWord.Request)
    {
        var response = WordDetails.FetchWord.Response(word: word ?? "")
        presenter?.presentWord(response: response)
    }
    
    func addWord(request: WordDetails.AddWord.Request)
    {
        //        worker = WordDetailsWorker()
        //        worker?.doSomeWork()
        //
        //        let response = WordDetails.AddWord.Response()
        //        presenter?.presentSomething(response: response)
    }
    
    func deleteWord(request: WordDetails.DeleteWord.Request)
    {
        //        worker = WordDetailsWorker()
        //        worker?.doSomeWork()
        //
        //        let response = WordDetails.AddWord.Response()
        //        presenter?.presentSomething(response: response)
    }
    
    func markFavoriteWord(request: WordDetails.MakeFavoriteWord.Request)
    {
        //        worker = WordDetailsWorker()
        //        worker?.doSomeWork()
        //
        //        let response = WordDetails.AddWord.Response()
        //        presenter?.presentSomething(response: response)
    }
}
