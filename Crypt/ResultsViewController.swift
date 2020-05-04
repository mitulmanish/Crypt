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
    
    private let portfolioType: PortfolioType?
    private let error: Error?
    private let currency: Currency?
    
    init(portfolioType: PortfolioType, currency: Currency) {
        self.error = .none
        self.portfolioType = portfolioType
        self.currency = currency
        super.init(nibName: nil, bundle: .main)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    init(error: Error) {
        self.portfolioType = .none
        self.error = error
        self.currency = .none
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var text: String?
        let currencyText = currency?.currencyName ?? ""
        
        switch portfolioType {
        case .profit(let amount, _)?:
            text = "You made a \nprofit of \(currencyText) \(amount)"
        case .loss(let amount, _)?:
            text = "You made a \nloss of \(currencyText) \(amount)"
        case .neutral?:
            text = "No profit \nno loss"
        case .none:
            break
        }
        
        if let error = self.error {
            text = error.localizedDescription
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

extension ResultsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return ModalPresentationController(
            portraitHeight: 150,
            landscapeHeight: 170,
            marginFromBottom: 0,
            sideMargin: 0,
            presentedViewController: presented,
            presentingViewController: source
        )
    }
}
