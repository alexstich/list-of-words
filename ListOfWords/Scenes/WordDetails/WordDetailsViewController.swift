//
//  WordDetailsViewController.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 11.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

protocol WordDetailsDisplayLogic: AnyObject
{
    func displayWord(viewModel: WordDetails.FetchWord.ViewModel)
    func displayNumberOccurrance(viewModel: WordDetails.FetchNumberOccurrance.ViewModel)
    func displayFavoriteStatus(viewModel: WordDetails.FetchFavoriteOccurrance.ViewModel)
    func displayToggleFavoriteStatus(viewModel: WordDetails.ToggleFavoriteStatus.ViewModel)
    func displayAddWordResult(viewModel: WordDetails.AddWord.ViewModel)
    func displayDeleteWordResult(viewModel: WordDetails.DeleteWord.ViewModel)
}

class WordDetailsViewController: UIViewController, WordDetailsDisplayLogic
{
    var interactor: WordDetailsBusinessLogic?
    var router: (NSObjectProtocol & WordDetailsRoutingLogic & WordDetailsDataPassing)?
    
    private let wordLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.black
        lbl.textAlignment = .center;
        lbl.font.withSize(18.0)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let wordOccurranceNumberTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.gray
        lbl.textAlignment = .center;
        lbl.font.withSize(16.0)
        lbl.numberOfLines = 0
        lbl.text = "Occurance number:"
        return lbl
    }()
    
    private let wordOccurranceNumberLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.gray
        lbl.textAlignment = .center;
        lbl.font.withSize(16.0)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let addButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Add word", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.clipsToBounds = true
        return btn
    }()
    
    private let deleteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Delete word", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.clipsToBounds = true
        return btn
    }()
    
    private let markFavoriteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.clipsToBounds = true
        return btn
    }()
    
    
    // MARK: Object lifecycle
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        
        setupConfig()
        setupViews()
        setupActions()
        setupObserves()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: View lifecycle

    override func viewWillAppear(_ animated: Bool) 
    {
        super.viewWillAppear(animated)
        
        fetchWord()
        fetchNumberOccurrance()
        fetchFavoriteOccurrance()
    }
    
    
    // MARK: Setup
    
    private func setupConfig()
    {
        let viewController = self
        let interactor = WordDetailsInteractor()
        let presenter = WordDetailsPresenter()
        let router = WordDetailsRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    private func setupViews()
    {
        title = "List of Words"
        
        self.view.backgroundColor = .white
        
        
        self.view.addSubview(wordLbl)
        self.view.addSubview(wordOccurranceNumberTitleLbl)
        self.view.addSubview(wordOccurranceNumberLbl)
        self.view.addSubview(addButton)
        self.view.addSubview(deleteButton)
        self.view.addSubview(markFavoriteButton)
        
        wordLbl.translatesAutoresizingMaskIntoConstraints = false
        wordOccurranceNumberTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        wordOccurranceNumberLbl.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        markFavoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wordLbl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            wordLbl.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            wordLbl.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            wordLbl.heightAnchor.constraint(equalToConstant: CGFloat(50)),
        ])
        
        NSLayoutConstraint.activate([
            wordOccurranceNumberTitleLbl.topAnchor.constraint(equalTo: self.wordLbl.bottomAnchor, constant: 20),
            wordOccurranceNumberTitleLbl.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            wordOccurranceNumberTitleLbl.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            wordOccurranceNumberTitleLbl.heightAnchor.constraint(equalToConstant: CGFloat(40)),
        ])
        
        NSLayoutConstraint.activate([
            wordOccurranceNumberLbl.topAnchor.constraint(equalTo: self.wordOccurranceNumberTitleLbl.bottomAnchor, constant: 10),
            wordOccurranceNumberLbl.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            wordOccurranceNumberLbl.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            wordOccurranceNumberLbl.heightAnchor.constraint(equalToConstant: CGFloat(40)),
        ])
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: self.wordOccurranceNumberLbl.bottomAnchor, constant: 40),
            addButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 50),
            addButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -50),
            addButton.heightAnchor.constraint(equalToConstant: CGFloat(50)),
        ])
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: self.addButton.bottomAnchor, constant: 20),
            deleteButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 50),
            deleteButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -50),
            deleteButton.heightAnchor.constraint(equalToConstant: CGFloat(50)),
        ])
        
        NSLayoutConstraint.activate([
            markFavoriteButton.topAnchor.constraint(equalTo: self.deleteButton.bottomAnchor, constant: 20),
            markFavoriteButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 50),
            markFavoriteButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -50),
            markFavoriteButton.heightAnchor.constraint(equalToConstant: CGFloat(50)),
        ])
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: Setup notification observers
    
    private func setupObserves()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchNumberOccurrance), name: .addedWordToListWordsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchNumberOccurrance), name: .deletedWordFromListWordsNotification, object: nil)
    }
    
    
    // MARK: Setup actions
    
    private func setupActions()
    {
        addButton.addAction(UIAction { [weak self] _ in
            self?.addWord()
        }, for: .touchUpInside)
        
        deleteButton.addAction(UIAction { [weak self] _ in
            self?.deleteWord()
        }, for: .touchUpInside)
        
        markFavoriteButton.addAction(UIAction { [weak self] _ in
            self?.toogleFavoriteStatus()
        }, for: .touchUpInside)
    }
    
    
    // MARK: Interactor invokes
    
    private func fetchWord()
    {
        let request = WordDetails.FetchWord.Request()
        interactor?.fetchWord(request: request)
    }
    
    @objc private func fetchNumberOccurrance()
    {
        let request = WordDetails.FetchNumberOccurrance.Request()
        interactor?.fetchNumberOccurrance(request: request)
    }
    
    private func fetchFavoriteOccurrance()
    {
        let request = WordDetails.FetchFavoriteOccurrance.Request()
        interactor?.fetchFavoriteOccurrance(request: request)
    }
    
    private func toogleFavoriteStatus()
    {
        let request = WordDetails.ToggleFavoriteStatus.Request()
        interactor?.toggleFavoriteStatus(request: request)
    }
    
    private func addWord()
    {
        let request = WordDetails.AddWord.Request()
        interactor?.addWord(request: request)
    }
    
    private func deleteWord()
    {
        let request = WordDetails.DeleteWord.Request()
        interactor?.deleteWord(request: request)
    }
    
    
    // MARK: Display Logic
    
    func displayNumberOccurrance(viewModel: WordDetails.FetchNumberOccurrance.ViewModel)
    {
        wordOccurranceNumberLbl.text = "\(viewModel.number)"
    }
    
    func displayWord(viewModel: WordDetails.FetchWord.ViewModel)
    {
        wordLbl.text = "\(viewModel.word)"
    }
    
    func displayFavoriteStatus(viewModel: WordDetails.FetchFavoriteOccurrance.ViewModel) 
    {
        if viewModel.isFavorite {
            markFavoriteButton.setTitle("Mark as unfavourite", for: .normal)
        } else {
            markFavoriteButton.setTitle("Mark as favourite", for: .normal)
        }
    }
    
    func displayToggleFavoriteStatus(viewModel: WordDetails.ToggleFavoriteStatus.ViewModel)
    {
        if viewModel.isFavorite {
            markFavoriteButton.setTitle("Mark as unfavourite", for: .normal)
            MessageProvider.shared.showAlert(message: ("Word have been added to favorite", .info), from: self)
        } else {
            markFavoriteButton.setTitle("Mark as favourite", for: .normal)
            MessageProvider.shared.showAlert(message: ("Word have been removed from favorite", .info), from: self)
        }
    }
    
    func displayAddWordResult(viewModel: WordDetails.AddWord.ViewModel)
    {
        if viewModel.result == .success {
            MessageProvider.shared.showAlert(message: ("Word have been added", .info), from: self)
        } else {
            MessageProvider.shared.showAlert(message: ("Word have not been added", .alert), from: self)
        }
    }
    
    func displayDeleteWordResult(viewModel: WordDetails.DeleteWord.ViewModel)
    {
        if viewModel.result == .success {
            MessageProvider.shared.showAlert(message: ("Word have been deleted", .info), from: self)
        } else {
            MessageProvider.shared.showAlert(message: ("Word have not been deleted", .alert), from: self)
        }
    }
}
