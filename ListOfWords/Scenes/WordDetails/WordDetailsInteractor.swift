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
    func fetchFavoriteOccurrance(request: WordDetails.FetchFavoriteOccurrance.Request)
    
    func toggleFavoriteStatus(request: WordDetails.ToggleFavoriteStatus.Request)
    func addWord(request: WordDetails.AddWord.Request)
    func deleteWord(request: WordDetails.DeleteWord.Request)

}

protocol WordDetailsDataStore
{
    var word: String? { get set }
}

class WordDetailsInteractor: WordDetailsBusinessLogic, WordDetailsDataStore
{
    var word: String?
    var number: Int?
    var isFavorite: Bool = false
    
    var presenter: WordDetailsPresentationLogic?
    var worker: WordDetailsWorker? = WordDetailsWorker()
    
    func fetchWord(request: WordDetails.FetchWord.Request)
    {
        let response = WordDetails.FetchWord.Response(word: word ?? "")
        presenter?.presentWord(response: response)
    }
    
    func fetchNumberOccurrance(request: WordDetails.FetchNumberOccurrance.Request)
    {
        if let word = word {
            
            worker?.fetchWordNumberOccurrance(
                word: word,
                completion: { [weak self] number in
                    
                    self?.number = number
                    
                    let response = WordDetails.FetchNumberOccurrance.Response(number: number)
                    self?.presenter?.presentNumberOccurrance(response: response)
                }
            )
        }
    }
    
    func fetchFavoriteOccurrance(request: WordDetails.FetchFavoriteOccurrance.Request)
    {
        if let word = word {
            
            worker?.fetchFavoriteWordOccurrance(
                word: word,
                completion: { [weak self] isFavorite in
                    
                    self?.isFavorite = isFavorite
                    
                    let response = WordDetails.FetchFavoriteOccurrance.Response(isFavorite: isFavorite)
                    self?.presenter?.presentIsFavoriteWord(response: response)
                }
            )
        }
    }
    
    func addWord(request: WordDetails.AddWord.Request)
    {
        if word != nil {
            worker?.addToListWords(word: word!) { [weak self] wordPosition in
                
                guard let self = self else { return }
                
                let response = WordDetails.AddWord.Response(success: true, word: self.word!)
                self.presenter?.presentAddWordResult(response: response)
                
                NotificationCenter.default.post(name: .addedWordToListWordsNotification, object: nil, userInfo: ["wordPosition": wordPosition])
            }
        }
    }
    
    func deleteWord(request: WordDetails.DeleteWord.Request)
    {
        if word != nil {
            worker?.deleteFromListWords(word: word!)
            let response = WordDetails.DeleteWord.Response(success: true, word: word!)
            presenter?.presentDeleteWordResult(response: response)
        }
        
        NotificationCenter.default.post(name: .deletedWordFromListWordsNotification, object: nil, userInfo: nil)
    }
    
    func toggleFavoriteStatus(request: WordDetails.ToggleFavoriteStatus.Request)
    {
        var response: WordDetails.ToggleFavoriteStatus.Response
        
        if word != nil && isFavorite {
            worker?.deleteFromFavoriteWords(word: word!)
            response = WordDetails.ToggleFavoriteStatus.Response(isFavorite: false)
            
            NotificationCenter.default.post(name: .deletedWordFromFavoriteListWordsNotification, object: nil, userInfo: nil)
            
        } else {
            worker?.addToFavoriteWords(word: word!)
            response = WordDetails.ToggleFavoriteStatus.Response(isFavorite: true)
            
            NotificationCenter.default.post(name: .addedWordToFavoriteListWordsNotification, object: nil, userInfo: nil)
        }
        
        self.isFavorite = !self.isFavorite
        
        presenter?.presentToggleFavoriteStatus(response: response)
    }
}
