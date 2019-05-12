//
//  Draggable+Dismissable.swift
//  Crypt
//
//  Created by Mitul Manish on 9/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//
import UIKit

typealias KeyboardDismissableDraggableView = KeyboardDismissable & DraggableViewType

protocol DraggableViewType: class {
    func handleInteraction(enabled: Bool)
    var scrollView: UIScrollView { get }
}

protocol KeyboardDismissable: class {
    func dismissKeyboard()
}
