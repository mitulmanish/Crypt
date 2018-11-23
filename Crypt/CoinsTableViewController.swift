//
//  CoinsTableViewController.swift
//  Crypt
//
//  Created by Mitul Manish on 26/4/18.
//  Copyright © 2018 Mitul Manish. All rights reserved.
//

import UIKit

class CoinsTableViewController: UITableViewController, UISearchBarDelegate {
    
    var originalCoinsData: [Coin]!
    var coins: [Coin]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        self.originalCoinsData = coins
    }
    
    var searchController: UISearchController!
    
    fileprivate func setupSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.textLabel?.text = coins[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.isActive = false
        dismiss(animated: true, completion: nil)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchText.lowercased()
        if searchText.isEmpty {
            self.coins = originalCoinsData
        } else {
            self.coins = originalCoinsData.filter { $0.code.lowercased().hasPrefix(searchString) ||
                $0.name.lowercased().hasPrefix(searchString)
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
