import UIKit
import SwiftUI

class HomeViewController: UIViewController {

    private var animator: UIViewControllerTransitioningDelegate?
    private var selectDateTransitionDelegate: UIViewControllerTransitioningDelegate?
    private var resultsViewTransitionDelegate: UIViewControllerTransitioningDelegate?
    private var selectCoinsTableViewController: SelectCoinsTableViewController?

    @IBOutlet weak var coinButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultsLabel: UILabel!
    
    @IBOutlet weak var currencySelectionButton: UIButton!
    
    private var currentCoin: Coin?
    private var concernedDate: Date?
    
    private var quantityBought: Float? {
        guard let quantityBought = quantityTextField.text,
            let quantityInFloat = Float(quantityBought) else {
                return nil
        }
        return quantityInFloat
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view.addGestureRecognizer(tapGesturerecognizer)
        quantityTextField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        quantityTextField.keyboardType = .decimalPad
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        quantityTextField.delegate = self
    }
    
    private var shouldFetchHistoricalData: Bool {
        return quantityTextField.text?.isEmpty == false
            && currentCoin != nil
            && concernedDate != nil
    }

    @objc func screenTapped() {
        if quantityTextField.isFirstResponder {
            quantityTextField.resignFirstResponder()
        }
        guard shouldFetchHistoricalData else {
            return
        }
        getHistoricalData()
    }

    private func showResults(portfolio: PortfolioType) {
        let resultsViewController = ResultsViewController(portfolioType: portfolio)
        resultsViewTransitionDelegate = ModalViewControllerPresentationTransitionDelegate(
            portraitHeight: 150,
            landscapeHeight: 170,
            verticalMargin: 0,
            horizontalMargin: 0
        )
        resultsViewController.modalPresentationStyle = .custom
        resultsViewController.transitioningDelegate = resultsViewTransitionDelegate
        dismissThenPresent(viewController: resultsViewController)
    }
    
    func getPriceData(price: CoinPrice?, error: HistoricalPriceError?) {
        activityIndicator.stopAnimating()
        guard let error = error else {
            guard let currentPrice = price?.latest, let oldPrice = price?.old, let quantityInFloat = quantityBought else {
                return
            }
            let portfolio = ProfitCalculator(
                moneySpent: quantityInFloat,
                currectPrice: currentPrice,
                oldPrice: oldPrice
                ).computePortfolio()
            var formattedString: String?
            switch portfolio {
            case .profit(_, let currentValue):
                formattedString = "$ \(currentValue)"
            case .loss(_, let currentValue):
                formattedString = "$ \(currentValue)"
            case .neutral:
                formattedString = "$ \(quantityInFloat)"
            }
            resultsLabel.text = formattedString ?? ""
            showResults(portfolio: portfolio)
            return
        }
        showPriceFetchError(error: error)
    }
    
    func showPriceFetchError(error: HistoricalPriceError) {
        let resultsViewController = ResultsViewController(error: error)
        resultsViewTransitionDelegate = ModalViewControllerPresentationTransitionDelegate(
            portraitHeight: 220,
            landscapeHeight: 150,
            verticalMargin: 0,
            horizontalMargin: 0
        )
        resultsViewController.modalPresentationStyle = .custom
        resultsViewController.transitioningDelegate = resultsViewTransitionDelegate
        if presentedViewController == .none {
            present(resultsViewController, animated: true, completion: .none)
        }
    }
    
    func dismissThenPresent(viewController: UIViewController) {
        if presentedViewController == .none {
            present(viewController, animated: true, completion: .none)
        } else {
            dismiss(animated: true) { [weak self] in
                self?.present(viewController, animated: true, completion: .none)
            }
        }
    }
    
    private (set) var historicalDataNetworkOperationManager: HistoricalDataNetworkOperationManager?
    
    func computePriceRequestParams() -> PriceRequestParams? {
        guard let coin = self.currentCoin,
            let date = self.concernedDate,
            let quantityBought = self.quantityBought
            else {
                return .none
        }
        return PriceRequestParams(
            quantityBought: quantityBought,
            currentDate: Date(),
            historicalDate: date,
            coin: coin
        )
    }
    
    private var priceRequestParams: PriceRequestParams?
    
    var shouldRequestNewPriceData: Bool {
        guard let priceRequestParams = self.priceRequestParams else {
            return true
        }
        return computePriceRequestParams() != priceRequestParams
    }
    
    func getHistoricalData() {
        guard shouldRequestNewPriceData else {
            return
        }
        guard let priceRequestParams = computePriceRequestParams() else {
            return
        }
        self.priceRequestParams = priceRequestParams
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        resultsLabel.text = nil
        historicalDataNetworkOperationManager = HistoricalDataNetworkOperationManager()
        historicalDataNetworkOperationManager?.requestCoinHistoricalData(
            forDates: (old: priceRequestParams.historicalDate,
                       latest: priceRequestParams.currentDate),
            forCoin: priceRequestParams.coin,
            forCurrency: "usd",
            completionHandler: getPriceData)
    }

    @IBAction func selectCoin(_ sender: UIButton) {
        dismissKeyboard()
        let selectCoinViewController = SelectCoinsTableViewController(selectedCoin: currentCoin)
        animator = DraggableTransitionDelegate()
        selectCoinViewController.modalPresentationStyle = .custom
        selectCoinViewController.transitioningDelegate = animator
        dismissThenPresent(viewController: selectCoinViewController)
        selectCoinViewController.coinSelected = { [weak self] coin in
            self?.currentCoin = coin
            self?.coinButton.setTitle(coin.name, for: .normal)
            self?.getHistoricalData()
        }
        selectCoinViewController.viewDismissed = { [weak self] in
            self?.getHistoricalData()
        }
    }
    
    private var currencySelectionTransitionDelegate: DraggableTransitionDelegate?
    @IBAction func didSelectCurrencySelection(_ sender: UIButton) {
        currencySelectionTransitionDelegate = DraggableTransitionDelegate()
        let vc = SelectCurrrecyViewController()
        vc.transitioningDelegate = currencySelectionTransitionDelegate
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: .none)
    }
    

    @IBAction func didBeginEditing(_ sender: UITextField) {
        selectCoinsTableViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.selectCoinsTableViewController = nil
        })
    }
    
    @IBAction func dateSelected(_ sender: UIButton) {
        let selectDateViewController = SelectDateViewController(selectedDate: concernedDate ?? Date())
        selectDateTransitionDelegate = ModalViewControllerPresentationTransitionDelegate(portraitHeight: 250, landscapeHeight: 270, verticalMargin: 8, horizontalMargin: 0)
        selectDateViewController.transitioningDelegate = selectDateTransitionDelegate
        selectDateViewController.modalPresentationStyle = .custom
        dismissThenPresent(viewController: selectDateViewController)
        selectDateViewController.dateChanged = { [weak self] date in
            self?.concernedDate = date
            self?.formatDate(date: date)
            self?.getHistoricalData()
        }
        selectDateViewController.viewDismissed = { [weak self] in
            self?.getHistoricalData()
        }
    }
    
    func formatDate(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let formattedText = formatter.string(from: date)
        dateButton.setTitle(formattedText, for: .normal)
    }

    func dismissKeyboard() {
        guard quantityTextField.isFirstResponder else { return }
        quantityTextField.resignFirstResponder()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resultsLabel.text = nil
    }
}


// For testing purposes
//    private func fetchPriceBetweenDates() {
//        let endPoint = EndPointConstructor.history(coin: Coin(id: 363, name: "Bitcoin", code: "BTC"), fromDate: Date().addingTimeInterval(-24 * 60 * 60 * 5), toDate: Date().addingTimeInterval(-24 * 60 * 60 * 1), currency: "USD")
//        guard let req = RequestFactory.getRequest(endpointType: .currencies) else {
//            return
//        }
//        Service().fetch(urlRequest: req) { (result: Result<CurrecyHolder, Error>) in
//            switch result {
//            case .success(let holder):
//                print(holder.baseCurrencies.count)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
