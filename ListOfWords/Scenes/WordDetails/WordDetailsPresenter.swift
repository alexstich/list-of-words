//
//  WordDetailsPresenter.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 11.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

protocol WordDetailsPresentationLogic
{
  func presentSomething(response: WordDetails.AddWord.Response)
}

class WordDetailsPresenter: WordDetailsPresentationLogic
{
  weak var viewController: WordDetailsDisplayLogic?
  
  // MARK: Do something
  
  func presentSomething(response: WordDetails.AddWord.Response)
  {
    let viewModel = WordDetails.AddWord.ViewModel()
    viewController?.displayOccurrance(value: 0)
  }
}
