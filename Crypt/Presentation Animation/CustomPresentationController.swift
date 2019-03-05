//
//  SelectDatePresentationController.swift
//  Crypt
//
//  Created by Mitul Manish on 19/1/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController{
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    private let portraitHeight: CGFloat
    private let landscapeHeight: CGFloat
    
    init(portraitHeight: CGFloat,
         landscapeHeight: CGFloat,
         presentedViewController: UIViewController,
         presentingViewController: UIViewController) {
        self.portraitHeight = portraitHeight
        self.landscapeHeight = landscapeHeight
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
    }

    @objc func dismiss(){
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = self.containerView,
            let traitCollection = presentedView?.traitCollection else {
            return .zero
        }
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .compact), (.compact, .compact):
            return CGRect(origin: CGPoint(x: 8, y: containerView.frame.height - landscapeHeight - 44), size: CGSize(width: containerView.frame.width - 16, height: landscapeHeight))
        case (.compact, .regular), (.regular, .regular):
            return CGRect(origin: CGPoint(x: 8, y: containerView.frame.height - 44 - portraitHeight), size: CGSize(width: containerView.frame.width - 16, height: portraitHeight))
        case (.unspecified, .unspecified),
             (.unspecified, .compact),
             (.unspecified, .regular),
             (.compact, .unspecified),
             (.regular, .unspecified):
            return CGRect(origin: CGPoint(x: 0, y: containerView.frame.height/2), size: CGSize(width: containerView.frame.width, height: containerView.frame.height/2))
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        containerView?.addGestureRecognizer(tapGestureRecognizer)
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        containerView?.removeGestureRecognizer(tapGestureRecognizer)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        self.presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
