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
    func displayFetchedAllWords(viewModel: ListWords.FetchAllWords.ViewModel)
    func displayAddWordResult(viewModel: ListWords.AddWord.ViewModel)
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
    
    var isLoadingData = false
    
    // MARK: Object lifecycle
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        
        setupConf()
        setupViews()
        setupActions()
        setupObserves()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    deinit{
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        fetchAllWords(mode: .fetch_next)
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
    
    private func setupObserves()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: .addedWordToListWordsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: .deletedWordFromListWordsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: .addedWordToFavoriteListWordsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: .deletedWordFromFavoriteListWordsNotification, object: nil)
    }
    
    @objc private func refreshTable()
    {
        fetchAllWords(mode: .update_current)
        
        self.refreshControl.endRefreshing()
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
        
        addButton.addAction(UIAction { [weak self] _ in
            self?.showAddWordController(
                title: "Add word",
                message: "Type word that needs to be added to the end of the file.",
                completion: { word in
                    let request = ListWords.AddWord.Request(word: word)
                    self?.interactor?.addWord(request: request)
                }
            )
        }, for: .touchUpInside)
    }
    
    
    // MARK: - Display logic
    
    var displayedWords: Words = []
    var favoriteWords: FavoriteWords = []
    
    func displayFetchedAllWords(viewModel: ListWords.FetchAllWords.ViewModel)
    {
        displayedWords = viewModel.displayedWords
        favoriteWords = viewModel.displayedFavoriteWords
        tableView.reloadData()
    }
    
    func displayAddWordResult(viewModel: ListWords.AddWord.ViewModel)
    {
        if viewModel.result == .success {
            MessageManager.shared.showAlert(message: ("Word have been added", .info), from: self)
        } else {
            MessageManager.shared.showAlert(message: ("Word have not been added", .alert), from: self)
        }
    }
    
    private func showAddWordController(title: String, message: String, completion: @escaping (String?)->Void)
    {
        let addWordController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        addWordController.addTextField(configurationHandler: { textField in
            textField.text = nil
            textField.minimumFontSize = 12
            textField.textColor = .black
            textField.keyboardType = .default
        })
        
        addWordController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak addWordController] _ in
            addWordController?.dismiss(animated: true)
        }))
        
        addWordController.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak addWordController] action in
            let word = addWordController?.textFields?[0].text
            completion(word)
            addWordController?.dismiss(animated: true)
        }))
        
        showDetailViewController(addWordController, sender: nil)
    }
}


// MARK: Ineractor actions
extension ListWordsViewController
{
    func fetchAllWords(mode: ListWordsInteractor.FetchingMode)
    {
        let request = ListWords.FetchAllWords.Request(mode: mode)
        interactor?.fetchAllWords(request: request)
    }
    
    func selectWord(indexPath: IndexPath)
    {
        let request = ListWords.SelectWord.Request(indexPath: indexPath)
        interactor?.selectWord(request: request)
        
        router?.routeToWordDetails(segue: nil)
    }
}


// MARK: Table data source delegate methods
extension ListWordsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView()
        
        
        let label = UILabel()
        label.textAlignment = .left
        label.font.withSize(14.0)
        
        if section == 0 {
            headerView.backgroundColor = UIColor.orange.withAlphaComponent(0.7)
            label.text = "Favorites"
        } else {
            headerView.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
            label.text = "Pool"
        }
        
        headerView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.centerYAnchor),
            label.leftAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leftAnchor, constant: 10),
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat 
    {
        return 45
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0 {
            return "Favorites"
        }
        
        return "Pool"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
    {
        selectWord(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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

// MARK: Table scroll delegate methods
extension ListWordsViewController: UITableViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) 
    {
        // fetch new batch of word when you come down
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if !isLoadingData && (offsetY > (contentHeight - scrollViewHeight)) {
            
            // this prevent multiple fetching because scrollViewDidScroll is invoked a lot of times
            isLoadingData = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.isLoadingData = false
            }

            fetchAllWords(mode: .fetch_next)
        }
    }
}
