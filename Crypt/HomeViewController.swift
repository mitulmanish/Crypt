import UIKit
import SwiftUI
import Combine
import Drawer

class HomeViewController: UIViewController {
    
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
    private var currentCurrency: Currency
    
    private var quantityBought: Float? {
        guard let quantityBought = quantityTextField.text,
            let quantityInFloat = Float(quantityBought) else {
                return nil
        }
        return quantityInFloat
    }
    
    private var priceRequestParams: PriceRequestParams?
    
    var shouldRequestNewPriceData: Bool {
        guard let priceRequestParams = self.priceRequestParams else {
            return true
        }
        return computePriceRequestParams() != priceRequestParams
    }
    
    private var shouldFetchHistoricalData: Bool {
        quantityTextField.text?.isEmpty == false
               && currentCoin != nil
               && concernedDate != nil
    }
    
    private var historicalPriceComparisonProvider: HistoricalPriceComparisonProvider
    private var networkActivitySubscriber: AnyCancellable?
    
    init() {
        currentCurrency = .usd
        historicalPriceComparisonProvider = HistoricalPriceComparisonProvider()
        super.init(nibName: .none, bundle: .none)
    }
    
    required init?(coder: NSCoder) {
        currentCurrency = .usd
        historicalPriceComparisonProvider = HistoricalPriceComparisonProvider()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view.addGestureRecognizer(tapGesturerecognizer)
        quantityTextField.attributedPlaceholder = NSAttributedString(
            string: "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        quantityTextField.keyboardType = .decimalPad
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        quantityTextField.delegate = self
        currencySelectionButton.setTitle(
            "\(currentCurrency.currencyName)",
            for: .normal
        )
        currencySelectionButton.contentVerticalAlignment = .bottom
        
        networkActivitySubscriber = historicalPriceComparisonProvider
            .networkActivityPublisher
            .sink { [activityIndicator] in
            if $0 {
                activityIndicator?.startAnimating()
            } else {
                activityIndicator?.stopAnimating()
            }
        }
    }
    
    @objc func screenTapped() {
        if quantityTextField.isFirstResponder {
            quantityTextField.resignFirstResponder()
        }
        guard shouldFetchHistoricalData else { return }
        getHistoricalData()
    }
    
    private func showResults(portfolio: PortfolioType) {
        let resultsViewController = ResultsViewController(portfolioType: portfolio, currency: currentCurrency)
        dismissThenPresent(viewController: resultsViewController)
    }
    
    func getPriceData(price: CoinPrice?, error: Error?) {
        guard let error = error else {
            guard let currentPrice = price?.latest,
                let oldPrice = price?.old,
                let quantityInFloat = quantityBought else {
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
                formattedString = "\(currentCurrency.currencyName) \(currentValue)"
            case .loss(_, let currentValue):
                formattedString = "\(currentCurrency.currencyName) \(currentValue)"
            case .neutral:
                formattedString = "\(currentCurrency.currencyName) \(quantityInFloat)"
            }
            resultsLabel.text = formattedString ?? ""
            showResults(portfolio: portfolio)
            return
        }
        showPriceFetchError(error: error)
    }
    
    func showPriceFetchError(error: Error) {
        let resultsViewController = ResultsViewController(error: error)
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
    
    func getHistoricalData() {
        guard let priceRequestParams = computePriceRequestParams(), shouldRequestNewPriceData else {
            return
        }
        self.priceRequestParams = priceRequestParams
        resultsLabel.text = nil
        historicalPriceComparisonProvider.price(
            forDates: (old: priceRequestParams.historicalDate,
                       latest: priceRequestParams.currentDate),
            forCoin: priceRequestParams.coin,
            forCurrency: currentCurrency.currencyName,
            completionHandler: getPriceData
        )
    }
    
    @IBAction func selectCoin(_ sender: UIButton) {
        dismissKeyboard()
        let selectCoinViewController = SelectCoinsTableViewController(selectedCoin: currentCoin)
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
    
    @IBAction func didSelectCurrencySelection(_ sender: UIButton) {
        let viewController = SelectCurrencyViewController()
        viewController.selectionDelegate = self
        present(viewController, animated: true)
    }
    
    @IBAction func didBeginEditing(_ sender: UITextField) {
        selectCoinsTableViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.selectCoinsTableViewController = nil
        })
    }
    
    @IBAction func dateSelected(_ sender: UIButton) {
        let selectDateViewController = SelectDateViewController(selectedDate: concernedDate ?? Date())
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

extension HomeViewController: CurrencySelectionDelegate {
    func didSelectCurrency(currency: Currency) {
        currencySelectionButton.setTitle("\(currency.currencyName)", for: .normal)
        currentCurrency = currency
    }
}
