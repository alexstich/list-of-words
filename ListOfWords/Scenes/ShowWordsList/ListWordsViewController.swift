//
//  ListWordsViewController.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 10.02.24.
//  Copyright (c) 2024 Aleksei Grebenkin. All rights reserved.
//

import UIKit

protocol ListWordsDisplayLogic: AnyObject
{
    func displayFetchedListWords(viewModel: ListWords.FetchListWords.ViewModel)
}

final class ListWordsViewController: UIViewController, ListWordsDisplayLogic
{
    var interactor: ListWordsBusinessLogic?
    var router: (NSObjectProtocol & ListWordsRoutingLogic & ListWordsDataPassing)?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.bounces = true
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = true
        return tableView
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .blue
        refreshControl.attributedTitle = NSAttributedString(string: "reloading")
        return refreshControl
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
    
    
    // MARK: Object lifecycle
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        
        setupConf()
        setupViews()
        setupActions()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        fetchWords()
    }
    
    // MARK: Setup
    
    private func setupConf()
    {
        let viewController = self
        
        let interactor = ListWordsInteractor()
        let presenter = ListWordsPresenter()
        let router = ListWordsRouter()
        
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
                
        self.view.addSubview(tableView)
        self.view.addSubview(addButton)
        
        tableView.addSubview(refreshControl)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: CGFloat(50)),
            addButton.widthAnchor.constraint(equalToConstant: CGFloat(100)),
            addButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -30),
            addButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
        ])
    }
    
    @objc private func refreshTable()
    {
        fetchWords()
        
        self.refreshControl.endRefreshing()
        
        ToastMessage.show(message: "Это тестовое сообщение", controller: self)
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
    
    private func setupActions()
    {
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
        
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    // MARK: - Fetch words
    
    var displayedWords: ListWords.FetchListWords.ViewModel.Words = []
    var favoriteWords: ListWords.FetchListWords.ViewModel.Words = []
    

    
    func displayFetchedListWords(viewModel: ListWords.FetchListWords.ViewModel)
    {
        displayedWords = viewModel.displayedWords
        tableView.reloadData()
    }
}

// MARK: Ineractor actions
extension ListWordsViewController
{
    func fetchWords()
    {
        let request = ListWords.FetchListWords.Request()
        interactor?.fetchListWords(request: request)
    }
    
    func selectWord(indexPath: IndexPath)
    {
        let request = ListWords.FetchListWords.Request()
        interactor?.selectWord(request: request)
        
        router?.routeToWordDetails(segue: nil)
    }
}

// MARK: Table delegate methods
extension ListWordsViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0 {
            return "Favorites"
        }
        
        return "Pool"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
    {
        selectWord(indexPath: IndexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0 {
            return favoriteWords.count
        }
        
        return displayedWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var wordToDisplay = ""
        
        if indexPath.section == 0 {
            wordToDisplay = favoriteWords[indexPath.row]
        } else {
            wordToDisplay = displayedWords[indexPath.row]
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: WordTableViewCell.reuseId)
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier:  WordTableViewCell.reuseId)
        }
        
        cell?.textLabel?.text = wordToDisplay
        
        return cell!
    }
}
