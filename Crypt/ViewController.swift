import UIKit

enum PortfolioType {
    case profit(amount: Float, currentValue: Float)
    case loss(amount: Float, currentValue: Float)
    case neutral
}

struct ProfitCalculator {
    let moneySpent: Float
    let currectPrice: Float
    let oldPrice: Float
    
    func computePortfolio() -> PortfolioType {
        let unitsBoughtAtPrice = ((1.0 / oldPrice) * moneySpent)
        
        let valueAtCurentRate = unitsBoughtAtPrice * currectPrice
        
        let difference = (currectPrice - oldPrice) * unitsBoughtAtPrice
        guard difference != 0.0 else {
            return .neutral
        }
        return difference > 0 ?
            .profit(amount: difference, currentValue: valueAtCurentRate)
            : .loss(amount: difference, currentValue: valueAtCurentRate)
    }
}
class ViewController: UIViewController {

    private var animator: UIViewControllerTransitioningDelegate?
    private var selectDateTransitionDelegate: UIViewControllerTransitioningDelegate?
    
    private var selectCoinsTableViewController: SelectCoinsTableViewController?

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var coinButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!

    @IBOutlet weak var contentScrollView: UIScrollView!

    @IBOutlet weak var quantityTextField: UITextField!
    
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

    func getPriceData(price: CoinPrice?, error: HistoricalPriceError?) {
        guard let currentPrice = price?.latest, let oldPrice = price?.old, let quantityInFloat = quantityBought else {
            return
        }
        let portfolio = ProfitCalculator(
            moneySpent: quantityInFloat,
            currectPrice: currentPrice,
            oldPrice: oldPrice
            ).computePortfolio()
        
        switch portfolio {
        case .profit(let amount, let currentValue):
            print(">> Profit: \(amount) currentValue: \(currentValue)")
        case .loss(let amount, let currentValue):
            print(">> Loss: \(amount) currentValue: \(currentValue)")
        case .neutral:
            print(">> Neutal")
        }
    }

    func getHistoricalData() {
        guard let coin = self.currentCoin, let date = self.concernedDate else {
            return
        }
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
        let vc = SelectCoinsTableViewController(selectedCoin: currentCoin)
        animator = DraggableTransitionDelegate()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = animator
        present(vc, animated: true, completion: nil)
        vc.coinSelected = { [weak self] coin in
            self?.currentCoin = coin
            self?.coinButton.setTitle(coin.name, for: .normal)
        }
    }

    @IBAction func didBeginEditing(_ sender: UITextField) {
        selectCoinsTableViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.selectCoinsTableViewController = nil
        })
    }
    
    @IBAction func dateSelected(_ sender: UIButton) {
        let selectDateViewController = SelectDateViewController(selectedDate: concernedDate ?? Date())
        selectDateTransitionDelegate = SelectDateTransitionDelegate()
        selectDateViewController.transitioningDelegate = selectDateTransitionDelegate
        selectDateViewController.modalPresentationStyle = .custom
        present(selectDateViewController, animated: true, completion: nil)
        selectDateViewController.dateChanged = { [weak self] date in
            self?.concernedDate = date
            self?.formatDate(date: date)
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
