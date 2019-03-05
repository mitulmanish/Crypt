//
//  SelectDateTransitionDelegate.swift
//  Crypt
//
//  Created by Mitul Manish on 5/3/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//
import UIKit

class HalfScreenPresentationTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private let portraitHeight: CGFloat
    private let landscapeHeight: CGFloat
    
    init(portraitHeight: CGFloat, landscapeHeight: CGFloat) {
        self.portraitHeight = portraitHeight
        self.landscapeHeight = landscapeHeight
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(portraitHeight: portraitHeight, landscapeHeight: landscapeHeight, presentedViewController: presented, presentingViewController: source)
    }
}
