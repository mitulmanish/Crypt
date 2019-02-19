//
//  SelectDatePresentationController.swift
//  Crypt
//
//  Created by Mitul Manish on 19/1/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit

class SelectDateTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SelectDatePresentationController(presentedViewController: presented, presenting: source)
    }
}

class SelectDatePresentationController: UIPresentationController{
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()

    @objc func dismiss(){
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let traitCollection = presentedView?.traitCollection else {
            return .zero
        }
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .compact), (.compact, .compact):
            let presentedViewLandscapeHeight: CGFloat = 220
            return CGRect(origin: CGPoint(x: 8, y: containerView!.frame.height - presentedViewLandscapeHeight - 44), size: CGSize(width: containerView!.frame.width - 16, height: presentedViewLandscapeHeight))
        case (.compact, .regular), (.regular, .regular):
            let presentedViewPortraitHeight: CGFloat = 300
            return CGRect(origin: CGPoint(x: 8, y: self.containerView!.frame.height - 44 - presentedViewPortraitHeight), size: CGSize(width: self.containerView!.frame.width - 16, height: presentedViewPortraitHeight))
        case (.unspecified, .unspecified),
             (.unspecified, .compact),
             (.unspecified, .regular),
             (.compact, .unspecified),
             (.regular, .unspecified):
            return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height/2), size: CGSize(width: self.containerView!.frame.width, height: self.containerView!.frame.height/2))
        }
    }

    override func presentationTransitionWillBegin() {

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
