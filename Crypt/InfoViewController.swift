//
//  InfoViewController.swift
//  Crypt
//
//  Created by Mitul Manish on 10/5/20.
//  Copyright © 2020 Mitul Manish. All rights reserved.
//

import UIKit
import CompactModal

class InfoViewController: UIViewController {

    private let primaryText: String
    private let ctaText: String
    
    init(
        primaryText: String,
        ctaText: String
    ) {
        self.primaryText = primaryText
        self.ctaText = ctaText
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 8
        view.backgroundColor = .darkText
        
        let container = UIView()
        container.backgroundColor = .darkText
        
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        [
        container.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
        container.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
        container.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
        container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32)
            ].forEach { $0.isActive = true }
        
        let ctaButton = UIButton(type: .system)
        ctaButton.backgroundColor = .lightGray
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        ctaButton.layer.cornerRadius = 8
        ctaButton.setTitle(ctaText, for: .normal)
        
        container.addSubview(ctaButton)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        ctaButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.5),
        ctaButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ctaButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)]
            .forEach { $0.isActive = true
        }
        
        ctaButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        let primaryLabel = UILabel()
        primaryLabel.text = primaryText
        primaryLabel.font = UIFont.systemFont(ofSize: 32)
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryLabel.numberOfLines = 0
        primaryLabel.textAlignment = .center
        primaryLabel.textColor = .white
        
        container.addSubview(primaryLabel)
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        primaryLabel.leftAnchor.constraint(equalTo: container.leftAnchor),
        primaryLabel.rightAnchor.constraint(equalTo: container.rightAnchor),
        primaryLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        primaryLabel.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -16)
            ]
            .forEach { $0.isActive = true
        }
    }
    
    @objc func saveButtonTapped() {
        dismiss(animated: true)
    }
}

extension InfoViewController: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        CompactModalPresentationController(
            portraitHeight: 250,
            landscapeHeight: 250,
            marginFromBottom: 8,
            sideMargin: 8,
            presentedViewController: presented,
            presentingViewController: source
        )
    }
}
