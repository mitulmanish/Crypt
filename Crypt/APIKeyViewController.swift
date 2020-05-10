import ScrollingContainer
import UIKit
import RxCocoa
import RxSwift
import RxRelay

final class APIKeyViewController: ScrollingContainer {
    
    private let bag = DisposeBag()
    private let serviceProviderURL = URL(string: "https://www.cryptocurrencychart.com")!
    let saveButton = UIButton(type: .system)
    lazy var apiKeyTextField = textField(text: "API Key")
    lazy var apiSecretTextField = textField(text: "API Secret")
    
    private let apiKey: BehaviorRelay<String?>
    private let apiSecret: BehaviorRelay<String?>
    
    init(
        apiKey: BehaviorRelay<String?>,
        apiSecret: BehaviorRelay<String?>
    ) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        super.init()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        
        let savedAPIKey = apiKey.value
        let savedAPISecret = apiSecret.value
        
        apiKeyTextField.text = savedAPIKey
        apiSecretTextField.text = savedAPISecret
        
        let url = "www.cryptocurrencychart.com"
        let keyExplainer = "Get your API Key and Secret from \(url)"
        let range = keyExplainer.range(of: url)!
        let nsRange = NSRange(range, in: keyExplainer)
        let attr = NSMutableAttributedString(string: keyExplainer)
        attr.addAttribute(.link, value: url, range: nsRange)
        
        let label = UILabel()
        label.attributedText = attr
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .white
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        label.addGestureRecognizer(tapGesture)
        
        saveButton.setTitle("Save", for: .normal)
        let isSaveButtonEnabled = apiKeyTextField.text != ""
            && apiSecretTextField.text != ""
        let savedButtonColor: UIColor = isSaveButtonEnabled ? .white : .gray
        saveButton.setTitleColor(savedButtonColor, for: .normal)
        saveButton.isEnabled = isSaveButtonEnabled
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        let vStack = UIStackView(arrangedSubviews: [
            spacer(height: 16),
            label,
            spacer(height: 24),
            self.label(text: "API Key", fontSize: 18),
            apiKeyTextField,
            self.label(text: "API Secret", fontSize: 18),
            apiSecretTextField,
            spacer(height: 16),
            saveButton
        ])
        vStack.axis = .vertical
        vStack.spacing = 16
        
        contentView.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        [vStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
        vStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
        vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)]
            .forEach { $0.isActive = true
        }
        
        Observable.combineLatest(
            apiKeyTextField.rx.text,
            apiSecretTextField.rx.text
        )
        .filter { apiKey, apiSecret in
            apiKey?.isEmpty == false
            && apiSecret?.isEmpty == false
        }
        .map { (apiKey, apiSecret) -> Bool in
            let apiKeyValid = apiKey?.count ?? 0 > 12
            let apiSecretValid = apiSecret?.count ?? 0 > 12
            return apiKeyValid && apiSecretValid
        }
        .subscribe(onNext: { [weak self] val in
            DispatchQueue.main.async {
                let color: UIColor = val ? .white : .gray
                self?.saveButton.setTitleColor(color, for: .normal)
                self?.saveButton.isEnabled = val
            }
        })
        .disposed(by: bag)
    }
    
    @objc private func labelTapped() {
        UIApplication.shared.open(
            serviceProviderURL
        )
    }
    
    @objc private func saveButtonTapped() {
        guard let apiKey = apiKeyTextField.text, let apiSecret = apiSecretTextField.text else {
            return
        }
        let userDefault = UserDefaults()
        userDefault.set(apiKey, forKey: UserDefaults.apiKeyPath)
        userDefault.set(apiSecret, forKey: UserDefaults.apiSecretPath)
        
        self.apiKey.accept(apiKey)
        self.apiSecret.accept(apiSecret)
        
        let infoVC = InfoViewController(primaryText: "Your API Key and Secret is now saved", ctaText: "OK")
        present(infoVC, animated: true)
    }
    
    private func label(text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.numberOfLines = 0
        label.textColor = .white
        label.isUserInteractionEnabled = true
        return label
    }
    
    private func textField(text: String = "Your text here") -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textColor = .white
        textField.placeholder = text
        textField.text = nil
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        textField.backgroundColor = .lightGray
        return textField
    }
    
    private func spacer(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
}

extension UserDefaults {
    static let apiKeyPath = "apiKey"
    static let apiSecretPath = "apiSecret"
}
