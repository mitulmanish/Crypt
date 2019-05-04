//
//  SelectCurrrecyTableViewController.swift
//  Crypt
//
//  Created by Mitul Manish on 4/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit

class SelectCurrrecyTableViewController: UITableViewController {
    private let cellID = "cellID"
    
    private var currencyList: [Currency] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(some: Int) {
        currencyList = []
        super.init(nibName: .none, bundle: .none)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SelectCurrencyTableViewCell.self, forCellReuseIdentifier: cellID)
        currencyList = [.aud, .bgn, .brl, .cad, .chf, .cny, .czk, .dkk, .eur, .hrk, .myr, .tryCurrency, .rub, .pln, .sek, .jpy]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrencies()
    }
    
    func fetchCurrencies() {
        guard let req = RequestFactory.getRequest(endpointType: .currencies) else {
            return
        }
        Service().fetch(urlRequest: req) { [weak self] (result: Result<CurrecyHolder, Error>) in
            switch result {
            case .success(let holder):
                self?.currencyList = holder.currencyList
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currencyList.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SelectCurrencyTableViewCell else {
            return
        }
        cell.currencyLabel.text = currencyList.getElementAt(index: indexPath.row).value?.currencyName
        cell.flagLabel.text = "🇮🇳"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SelectCurrencyTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//    }
//
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.accessoryType = .none
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
        return label
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        flagLabel.text = "🇪🇪"
        let stackView = UIStackView(arrangedSubviews: [flagLabel, currencyLabel])
        stackView.backgroundColor = .blue
        contentView.addSubview(stackView)
        stackView.fillSuperView(with: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
