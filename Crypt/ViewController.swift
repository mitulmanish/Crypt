import UIKit

class ViewController: UIViewController {

    private var animator: UIViewControllerTransitioningDelegate?
    private var selectCoinsTableViewController: SelectCoinsTableViewController?

    @IBOutlet weak var contentScrollView: UIScrollView!

    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var customView: CustomView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            forDates: (old: Date().addingTimeInterval(-24 * 60 * 60 * 60), latest: Date()),
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
    }

    @IBAction func didBeginEditing(_ sender: UITextField) {
        selectCoinsTableViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.selectCoinsTableViewController = nil
        })
    }

    func dismissKeyboard() {
        guard quantityTextField.isFirstResponder else { return }
        quantityTextField.resignFirstResponder()
    }
}

class CustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
