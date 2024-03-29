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
    func addWord()
    func deleteWord()
    func makeFavouriteWord()
    func displayOccurrance(value: Int)
}

class WordDetailsViewController: UIViewController, WordDetailsDisplayLogic
{
    var interactor: WordDetailsBusinessLogic?
    var router: (NSObjectProtocol & WordDetailsRoutingLogic & WordDetailsDataPassing)?
    
    private let wordLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.black
        lbl.textAlignment = .center;
        lbl.font.withSize(14.0)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let wordOccurranceNumberTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.gray
        lbl.textAlignment = .center;
        lbl.font.withSize(14.0)
        lbl.numberOfLines = 0
        lbl.text = "Occurance number:"
        return lbl
    }()
    
    private let wordOccurranceNumberLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.gray
        lbl.textAlignment = .center;
        lbl.font.withSize(14.0)
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
    
    private let markFavouriteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Make favourite", for: .normal)
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
    }
    
    //      override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    //      {
    //        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    //      }
    //
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupConfig()
        setupViews()
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
        self.view.addSubview(markFavouriteButton)
        
        wordLbl.translatesAutoresizingMaskIntoConstraints = false
        wordOccurranceNumberTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        wordOccurranceNumberLbl.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        markFavouriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wordLbl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            wordLbl.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            wordLbl.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            wordLbl.heightAnchor.constraint(equalToConstant: CGFloat(50)),
        ])
        
        NSLayoutConstraint.activate([
            wordOccurranceNumberTitleLbl.topAnchor.constraint(equalTo: self.wordLbl.bottomAnchor, constant: 20),
            wordOccurranceNumberTitleLbl.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            wordOccurranceNumberTitleLbl.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            wordOccurranceNumberTitleLbl.heightAnchor.constraint(equalToConstant: CGFloat(50)),
        ])
        
        NSLayoutConstraint.activate([
            wordOccurranceNumberLbl.topAnchor.constraint(equalTo: self.wordOccurranceNumberTitleLbl.bottomAnchor, constant: 20),
            wordOccurranceNumberLbl.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            wordOccurranceNumberLbl.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            wordOccurranceNumberLbl.heightAnchor.constraint(equalToConstant: CGFloat(50)),
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
            markFavouriteButton.topAnchor.constraint(equalTo: self.deleteButton.bottomAnchor, constant: 20),
            markFavouriteButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 50),
            markFavouriteButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -50),
            markFavouriteButton.heightAnchor.constraint(equalToConstant: CGFloat(50)),
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
    
    // MARK: Actions
        
    func addWord()
    {
        let request = WordDetails.AddWord.Request()
        interactor?.addWord(request: request)
    }
    
    func deleteWord()
    {
        let request = WordDetails.DeleteWord.Request()
        interactor?.deleteWord(request: request)
    }
    
    func makeFavouriteWord()
    {
        let request = WordDetails.MakeFavouriteWord.Request()
        interactor?.markFavouriteWord(request: request)
    }
    
    func displayOccurrance(value: Int) 
    {
        wordOccurranceNumberLbl.text = "\(value)"
    }
}
