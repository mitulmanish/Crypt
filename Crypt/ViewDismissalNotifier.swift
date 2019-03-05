//
//  ViewDismissalNotifier.swift
//  Crypt
//
//  Created by Mitul Manish on 5/3/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//
import UIKit

protocol ViewDismissalNotifier where Self: UIViewController {
    var viewDismissed: (() -> Void)? { get set }
}
