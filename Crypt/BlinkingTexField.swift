import UIKit

final class BlinkingTexField: UITextField {
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textColor = .white
        keyboardType = .decimalPad
        backgroundColor = .clear
        borderStyle = .none
        attributedPlaceholder = NSAttributedString(
            string: "100.0",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        let underline = UIView()
        underline.backgroundColor = .white
        addSubview(underline)
        underline.translatesAutoresizingMaskIntoConstraints = false
        
        [
        underline.heightAnchor.constraint(equalToConstant: 3),
        underline.leftAnchor.constraint(equalTo: leftAnchor, constant: 2),
        underline.rightAnchor.constraint(equalTo: rightAnchor, constant: -2),
        underline.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ]
        .forEach { $0.isActive = true }
        underline.layer.cornerRadius = 1.5
        underline.startBlinking()
    }
}
