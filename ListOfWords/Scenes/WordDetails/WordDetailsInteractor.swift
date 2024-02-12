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
    
    var presenter: WordDetailsPresentationLogic?
    var worker: WordDetailsWorker?
    //var name: String = ""
    
    // MARK: Do something
    
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
