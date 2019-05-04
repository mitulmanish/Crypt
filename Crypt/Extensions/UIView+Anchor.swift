//
//  UIView+Anchor.swift
//  Crypt
//
//  Created by Mitul Manish on 4/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit

extension UIView {
    func fillSuperView(with insets: UIEdgeInsets = .zero) {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        [leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: insets.left),
         trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -insets.right),
         topAnchor.constraint(equalTo: superView.topAnchor, constant: insets.top),
         bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -insets.bottom)
            ].forEach { $0.isActive = true }
    }
}
