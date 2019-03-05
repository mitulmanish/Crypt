//
//  ResultsViewController.swift
//  Crypt
//
//  Created by Mitul Manish on 5/3/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, ViewDismissalNotifier {
    var viewDismissed: (() -> Void)?
    
    @IBOutlet weak var resultsLabel: UILabel!
    private let portfolioType: PortfolioType
    
    init(portfolioType: PortfolioType) {
        self.portfolioType = portfolioType
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var text: String?
        
        switch portfolioType {
        case .profit(let amount, _):
            text = "You made a \nprofit of $ \(amount)"
        case .loss(let amount, _):
            text = "You made a \nloss of $ \(amount)"
        case .neutral:
            text = "No profit \nno loss"
        }
        resultsLabel.text = text
    }
    
    override func viewDidLayoutSubviews() {
        view.round(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: .none)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDismissed?()
    }
}
