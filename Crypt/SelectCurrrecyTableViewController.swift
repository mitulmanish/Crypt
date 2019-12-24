//
//  SelectCurrrecyTableViewController.swift
//  Crypt
//
//  Created by Mitul Manish on 4/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit
import NetworkingKit

class CurrenciesTableViewController: UITableViewController {
    
    private let cellID = "cellID"
    var viewScrolled: (() -> ())?
    var currencySelected: ((Currency) -> Void)?
    
    init() {
        super.init(nibName: .none, bundle: .none)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var currencyList: [Currency] = [Currency]() {
        didSet {
            OperationQueue.main.addOperation { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SelectCurrencyTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrencies()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func fetchCurrencies() {
        guard let req = RequestFactory.getRequest(endpointType: .currencies) else {
            return
        }
        Service.fetch(urlRequest: req) { [weak self]
            (result: Result<CurrecyHolder, Error>) in
            switch result {
            case .success(let holder):
                self?.currencyList = holder.currencyList
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SelectCurrencyTableViewCell else {
            return UITableViewCell()
        }
        guard let currency = currencyList
            .getElementAt(index: indexPath.row).value else {
                return cell
        }
        cell.currencyLabel.text = currency.currencyName
        cell.flagLabel.text = currency.flag
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currency = currencyList.getElementAt(index: indexPath.row).value else { return }
        currencySelected?(currency)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewScrolled?()
    }
}

class SelectCurrencyTableViewCell: UITableViewCell {
    
    lazy var flagLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 36).isActive = true
        return label
    }()
    
    lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .darkGray
        backgroundColor = .darkGray
        
        let stackView = UIStackView(arrangedSubviews: [flagLabel, currencyLabel])
        stackView.backgroundColor = .blue
        contentView.addSubview(stackView)
        stackView.fillSuperView(with: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        accessoryType = selected ? .checkmark : .none
    }
}

protocol CurrencySelectionDelegate: AnyObject {
    func didSelectCurrency(currency: Currency)
}

class SelectCurrrecyViewController: UIViewController, UISearchBarDelegate, ViewDismissalNotifier {
    
    private var currencyList: [Currency] = [Currency]() {
        didSet {
            OperationQueue.main.addOperation { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    var selectionDelegate: CurrencySelectionDelegate?
    
    var tableView: UITableView {
        return currenciesTableViewController.view as! UITableView
    }
    
    var currenciesTableViewController: CurrenciesTableViewController = {
        return CurrenciesTableViewController()
    }()
    
    var viewDismissed: (() -> Void)?
    let selection = UISelectionFeedbackGenerator()
    
    lazy var containerView: UIView = {
        return UIView()
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .darkGray
        searchBar.isTranslucent = false
        searchBar.searchBarStyle = .default
        return searchBar
    }()
    
    lazy var handlerView: UIView = {
        let view = UIView()
        view.backgroundColor = .groupTableViewBackground
        view.layer.cornerRadius = 4
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init() {
        super.init(nibName: .none, bundle: .none)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        containerView.backgroundColor = .darkGray
        tableView.backgroundColor = .darkGray
        
        setupSubViews()
        
        currenciesTableViewController.currencySelected = { [weak self] currency in
            self?.selectionDelegate?.didSelectCurrency(currency: currency)
                self?.dismiss(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currenciesTableViewController.viewScrolled = { [weak self] in
            if self?.searchBar.isFirstResponder ?? false {
                self?.searchBar.resignFirstResponder()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.round(corners: [.topLeft, .topRight], radius: 8)
    }
    
    private func setupSubViews() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        [containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), containerView.heightAnchor.constraint(equalToConstant: 66),
         containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
         containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ].forEach { $0.isActive = true }
        
        handlerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(handlerView)
        [handlerView.heightAnchor.constraint(equalToConstant: 4),
         handlerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
         handlerView.widthAnchor.constraint(equalToConstant: 88),
         handlerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8)
            ].forEach { $0.isActive = true }
        
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(searchBar)
        [searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
         searchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
         searchBar.topAnchor.constraint(equalTo: handlerView.bottomAnchor, constant: 8),
         searchBar.heightAnchor.constraint(equalToConstant: 48),
         searchBar.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            ].forEach { $0.isActive = true }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tableView)
        
        [tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
         tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
         tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
         tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ].forEach { $0.isActive = true }
        
        tableView.addSubview(activityIndicator)
        [activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
         activityIndicator.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 16),
         activityIndicator.widthAnchor.constraint(equalToConstant: 36),
         activityIndicator.heightAnchor.constraint(equalTo: activityIndicator.widthAnchor)]
            .forEach { $0.isActive = true }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDismissed?()
    }
}

extension SelectCurrrecyViewController: DraggableViewType {
    
    var scrollView: UIScrollView {
        return tableView
    }
    
    func handleInteraction(enabled: Bool) {
        [tableView, searchBar].forEach {
            $0.isUserInteractionEnabled = enabled
        }
    }
}

extension SelectCurrrecyViewController: KeyboardDismissable {
    func dismissKeyboard() {
        guard searchBar.isFirstResponder else { return }
        searchBar.resignFirstResponder()
    }
}
