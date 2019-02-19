import UIKit

class ViewController: UIViewController {

    private var animator: UIViewControllerTransitioningDelegate?
    private var selectCoinsTableViewController: SelectCoinsTableViewController?

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var coinButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!

    @IBOutlet weak var contentScrollView: UIScrollView!

    @IBOutlet weak var quantityTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view.addGestureRecognizer(tapGesturerecognizer)
        amountTextField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        amountTextField.keyboardType = .decimalPad
    }

    @objc func screenTapped() {
        guard quantityTextField.isFirstResponder else {
            return
        }
        quantityTextField.resignFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func getPriceData(price: CoinPrice?, error: HistoricalPriceError?) {
        print("xxx: \(price)")
    }

    func buttonTounched() {
        let coin = Coin(id: 363, name: "Bitcoin", code: "BTC")
        let historicalDataNetworkOperationManager = HistoricalDataNetworkOperationManager()
        historicalDataNetworkOperationManager.requestCoinHistoricalData(
            forDates: (old: Date().addingTimeInterval(-24 * 60 * 60 * 60),
                       latest: Date()),
            forCoin: coin,
            forCurrency: "usd",
            completionHandler: getPriceData)
    }

    @IBAction func selectCoin(_ sender: UIButton) {
        dismissKeyboard()
        guard isBeingPresented == false else { return }
        let vc = SelectCoinsTableViewController()
        animator = DraggableTransitionDelegate()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = animator
        present(vc, animated: true, completion: nil)
        vc.coinSelected = { [weak self] coin in
            self?.coinButton.setTitle(coin.name, for: .normal)
        }
    }

    @IBAction func didBeginEditing(_ sender: UITextField) {
        selectCoinsTableViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.selectCoinsTableViewController = nil
        })
    }

    var selectDateTransitionDelegate: UIViewControllerTransitioningDelegate?
    
    @IBAction func dateSelected(_ sender: UIButton) {
        let selectDateViewController = SelectDateViewController()
        selectDateTransitionDelegate = SelectDateTransitionDelegate()
        selectDateViewController.transitioningDelegate = selectDateTransitionDelegate
        selectDateViewController.modalPresentationStyle = .custom
        present(selectDateViewController, animated: true, completion: nil)
        selectDateViewController.dateChanged = { date in
            print(date.description)
        }
    }

    func dismissKeyboard() {
        guard quantityTextField.isFirstResponder else { return }
        quantityTextField.resignFirstResponder()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
