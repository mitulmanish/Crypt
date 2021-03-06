//
//  SelectCurrrecyTableViewController.swift
//  Crypt
//
//  Created by Mitul Manish on 4/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit
import NetworkingKit
import Drawer

private final class CurrenciesTableViewController: UITableViewController {
    
    private let cellID = "cellID"
    var viewScrolled: (() -> Void)?
    var currencySelected: ((Currency) -> Void)?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
          let indicator = UIActivityIndicatorView(style: .medium)
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
    
    private var currencyList: [Currency] = [Currency]() {
        didSet {
            OperationQueue.main.addOperation { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SelectCurrencyTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.separatorStyle = .none
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.bringSubviewToFront(view)
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrencies()
    }
    
    private func fetchCurrencies() {
        guard let req = RequestFactory.getRequest(endpointType: .currencies) else {
            return
        }
        activityIndicator.startAnimating()
        Service.fetch(urlRequest: req) { [weak self] (result: Result<CurrecyHolder, Error>) in
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
        currencyList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellID,
            for: indexPath
        ) as? SelectCurrencyTableViewCell else {
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
        44.0
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
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
}

protocol CurrencySelectionDelegate: AnyObject {
    func didSelectCurrency(currency: Currency)
}

final class SelectCurrencyViewController: UIViewController, ViewDismissalNotifier {
    
    private var currencyList: [Currency] = [Currency]() {
        didSet {
            OperationQueue.main.addOperation { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    private var tableView: UITableView {
        // swiftlint:disable:next force_cast
        currenciesTableViewController.view as! UITableView
    }
    
    private lazy var handlerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 2
        return view
    }()
    
    weak var selectionDelegate: CurrencySelectionDelegate?
    var viewDismissed: (() -> Void)?
    
    private let selection = UISelectionFeedbackGenerator()
    private let containerView = UIView()
    private let currenciesTableViewController = CurrenciesTableViewController()
    
    init() {
        super.init(nibName: .none, bundle: .none)
        transitioningDelegate = self
        modalPresentationStyle = .custom
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.round(corners: [.topLeft, .topRight], radius: 8)
    }
    
    private func setupSubViews() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        [containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tableView)
        
        [tableView.topAnchor.constraint(equalTo: handlerView.bottomAnchor),
         tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
         tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
         tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ].forEach { $0.isActive = true }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDismissed?()
    }
}

extension SelectCurrencyViewController: KeyboardDismissableDraggableView {
    
    func dismissKeyboard() {}
    
    var scrollView: UIScrollView {
        tableView
    }
          
    func handleInteraction(enabled: Bool) {
        tableView.isUserInteractionEnabled = enabled
    }
}

extension SelectCurrencyViewController: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?, source: UIViewController
    ) -> UIPresentationController? {
        DraggablePresentationController(
            presentedViewController: presented,
            presenting: source
        )
    }
}
