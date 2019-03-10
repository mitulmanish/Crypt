import UIKit

class HomeViewController: UIViewController {

    private var animator: UIViewControllerTransitioningDelegate?
    private var selectDateTransitionDelegate: UIViewControllerTransitioningDelegate?
    private var resultsViewTransitionDelegate: UIViewControllerTransitioningDelegate?
    
    private var selectCoinsTableViewController: SelectCoinsTableViewController?

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var coinButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var resultsLabel: UILabel!
    
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
        amountTextField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        amountTextField.keyboardType = .decimalPad
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        quantityTextField.delegate = self
    }
    
    var shouldFetchHistoricalData: Bool {
        return (quantityTextField.text?.isEmpty == false && currentCoin != nil && concernedDate != nil)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func showResults(portfolio: PortfolioType) {
        let resultsViewController = ResultsViewController(portfolioType: portfolio)
        resultsViewTransitionDelegate = ModalViewControllerPresentationTransitionDelegate(portraitHeight: 150, landscapeHeight: 170, verticalMargin: 0, horizontalMargin: 0)
        resultsViewController.modalPresentationStyle = .custom
        resultsViewController.transitioningDelegate = resultsViewTransitionDelegate
        present(resultsViewController, animated: true, completion: .none)
    }
    
    func getPriceData(price: CoinPrice?, error: HistoricalPriceError?) {
        activityIndicator.stopAnimating()
        guard let currentPrice = price?.latest, let oldPrice = price?.old, let quantityInFloat = quantityBought else {
            return
        }
        let portfolio = ProfitCalculator(
            moneySpent: quantityInFloat,
            currectPrice: currentPrice,
            oldPrice: oldPrice
            ).computePortfolio()
        switch portfolio {
        case .profit(_, let currentValue):
            resultsLabel.text = "$ \(currentValue)"
        case .loss(_, let currentValue):
            resultsLabel.text = "$ \(currentValue)"
        case .neutral:
            resultsLabel.text = "$ \(quantityInFloat)"
        }
        showResults(portfolio: portfolio)
    }

    func getHistoricalData() {
        guard let coin = self.currentCoin,
            let date = self.concernedDate,
            quantityBought != nil
        else {
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        resultsLabel.text = nil
        let historicalDataNetworkOperationManager = HistoricalDataNetworkOperationManager()
        historicalDataNetworkOperationManager.requestCoinHistoricalData(
            forDates: (old: date,
                       latest: Date()),
            forCoin: coin,
            forCurrency: "usd",
            completionHandler: getPriceData)
    }

    @IBAction func selectCoin(_ sender: UIButton) {
        dismissKeyboard()
        guard isBeingPresented == false else { return }
        let selectCoinViewController = SelectCoinsTableViewController(selectedCoin: currentCoin)
        animator = DraggableTransitionDelegate()
        selectCoinViewController.modalPresentationStyle = .custom
        selectCoinViewController.transitioningDelegate = animator
        present(selectCoinViewController, animated: true, completion: nil)
        selectCoinViewController.coinSelected = { [weak self] coin in
            self?.currentCoin = coin
            self?.coinButton.setTitle(coin.name, for: .normal)
            self?.getHistoricalData()
        }
        selectCoinViewController.viewDismissed = { [weak self] in
            self?.getHistoricalData()
        }
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
        present(selectDateViewController, animated: true, completion: nil)
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
