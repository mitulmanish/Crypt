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
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(24)
        label.textColor = .white
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .darkGray
        contentView.addSubview(primaryLabel)
        primaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        primaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        primaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        primaryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        primaryLabel.textColor = selected ? .green : .white
    }
}
