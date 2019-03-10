import UIKit

protocol DraggableViewType: class {
    func dismissKeyboard()
    func handleInteraction(enabled: Bool)
    var scrollView: UIScrollView { get }
}

class SelectCoinsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ViewDismissalNotifier {
    var viewDismissed: (() -> Void)?
    private var selectedCoin: Coin?
    let selection = UISelectionFeedbackGenerator()
    var coinSelected: ((Coin) -> ())?

    var filteredCoinCollection: CoinCollection? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
                if let coin = self.selectedCoin, let indexPath = self.indexPath(of: coin) {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                }
            }
        }
    }

    var originalCoinCollection: CoinCollection? {
        didSet {
            filteredCoinCollection = originalCoinCollection
        }
    }

    lazy var containerView: UIView = {
        return UIView()
    }()

    lazy var tableView: UITableView = {
        return UITableView()
    }()

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .darkGray
        (searchBar.value(forKey: "_searchField") as? UITextField)?.backgroundColor = .groupTableViewBackground
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

    init(selectedCoin: Coin?) {
        self.selectedCoin = selectedCoin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .darkGray
        containerView.backgroundColor = .darkGray

        setupSubViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let coinsData = UserDefaults.standard.data(forKey: "coins") {
            self.originalCoinCollection = try? JSONDecoder().decode(CoinCollection.self, from: coinsData)
            activityIndicator.removeFromSuperview()
        } else {
            AllCoinsNetworkOperationManager().getAllCoins(completionHandler: allCoins)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
    }

    override func viewDidLayoutSubviews() {
        view.round(corners: [.topLeft, .topRight], radius: 8)
    }
    
    private func setupSubViews() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        [containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
         containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ].forEach { $0.isActive = true }
        
        handlerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(handlerView)
        [handlerView.heightAnchor.constraint(equalToConstant: 4),
         handlerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
         handlerView.widthAnchor.constraint(equalToConstant: 90),
         handlerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8)
            ].forEach { $0.isActive = true }
        
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(searchBar)
        [searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
         searchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
         searchBar.topAnchor.constraint(equalTo: handlerView.bottomAnchor, constant: 8),
         searchBar.heightAnchor.constraint(equalToConstant: 44),
         searchBar.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            ].forEach { $0.isActive = true }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tableView)
        [tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
         tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
         tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
         tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ].forEach { $0.isActive = true }
        
        tableView.register(CoinTableViewCell.self, forCellReuseIdentifier: CoinTableViewCell.identifier)
        tableView.backgroundColor = .darkGray
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.addSubview(activityIndicator)
        [activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
         activityIndicator.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 16),
         activityIndicator.widthAnchor.constraint(equalToConstant: 36),
         activityIndicator.heightAnchor.constraint(equalTo: activityIndicator.widthAnchor)]
            .forEach { $0.isActive = true }
    }

    func allCoins(coinCollection: CoinCollection?) {
        self.originalCoinCollection = coinCollection
        guard let data = try? JSONEncoder().encode(coinCollection) else { return }
        UserDefaults.standard.set(data, forKey: "coins")
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCoinCollection?.coins.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let coin = filteredCoinCollection?.coins[indexPath.row],
            let cell = cell as? CoinTableViewCell else {
            return
        }
        cell.primaryLabel.text = coin.name
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoinTableViewCell.identifier, for: indexPath) as? CoinTableViewCell
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCoin = filteredCoinCollection?.coins[indexPath.row] else {
            return
        }
        self.selectedCoin = selectedCoin
        selection.selectionChanged()
        coinSelected?(selectedCoin)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        selectedCoin = nil
        let searchString = searchText.lowercased()
        if searchText.isEmpty {
            self.filteredCoinCollection = originalCoinCollection
        } else {
            self.filteredCoinCollection = filteredCoins(searchString: searchString)
        }
    }

    func filteredCoins(searchString: String) -> CoinCollection {
        let filteredCoins = originalCoinCollection?.coins.filter {
            ($0.name == searchString.lowercased())
                || ($0.code.lowercased() == searchString.lowercased())
                || $0.name.lowercased().hasPrefix(searchString.lowercased())
        }
        return CoinCollection(coins: filteredCoins ?? [])
    }
    
    func indexPath(of coin: Coin) -> IndexPath? {
        guard let index = filteredCoinCollection?.coins.firstIndex(of: coin) else {
            return nil
        }
        let indexPath = IndexPath(item: index, section: 0)
        return indexPath
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDismissed?()
    }
}

extension SelectCoinsTableViewController: DraggableViewType {
    
    var scrollView: UIScrollView {
        return tableView
    }

    func handleInteraction(enabled: Bool) {
        tableView.isUserInteractionEnabled = enabled
        searchBar.isUserInteractionEnabled = enabled
    }
    
    func dismissKeyboard() {
        guard searchBar.isFirstResponder else { return }
        searchBar.resignFirstResponder()
    }
}
