//
//  CoinTableViewCell.swift
//  Crypt
//
//  Created by Mitul Manish on 8/12/18.
//  Copyright © 2018 Mitul Manish. All rights reserved.
//

import UIKit

class CoinTableViewCell: UITableViewCell {

    static let identifier = "CoinCell"

    lazy var primaryLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(24)
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func layoutSubviews() {
        setupPrimaryLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        primaryLabel.textColor = selected ? .purple : .black
    }

    override var isSelected: Bool {
        didSet {
            primaryLabel.textColor = isSelected ? .purple : .black
        }
    }

    private func setupPrimaryLabel() {
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(primaryLabel)
        primaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        primaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        primaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        primaryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
