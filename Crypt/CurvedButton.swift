//
//  CurvedButton.swift
//  Crypt
//
//  Created by Mitul Manish on 22/1/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit

class CurvedButton: UIButton {
    override func awakeFromNib() {
        round(corners: [.allCorners], radius: 8)
    }
}
