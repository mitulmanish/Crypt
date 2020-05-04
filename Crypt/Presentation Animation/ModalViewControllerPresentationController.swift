//
//  SelectDatePresentationController.swift
//  Crypt
//
//  Created by Mitul Manish on 19/1/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit

class ModalPresentationController: UIPresentationController {
    private var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    private let portraitHeight: CGFloat
    private let landscapeHeight: CGFloat
    private let marginFromBottom: CGFloat
    private let sideMargin: CGFloat
    
    init(portraitHeight: CGFloat,
         landscapeHeight: CGFloat,
         marginFromBottom: CGFloat,
         sideMargin: CGFloat,
         presentedViewController: UIViewController,
         presentingViewController: UIViewController) {
        self.portraitHeight = portraitHeight
        self.landscapeHeight = landscapeHeight
        self.marginFromBottom = marginFromBottom
        self.sideMargin = sideMargin
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let sideMargin = computeSideMargin()
        let totalVerticalMargin = computeTotalVerticalMargin()
        
        guard let containerView = self.containerView,
            let traitCollection = presentedView?.traitCollection else {
            return .zero
        }
        return computePresentedViewRect(
            traitCollection: traitCollection,
            sideMargin: sideMargin,
            containerView: containerView,
            totalVerticalMargin: totalVerticalMargin
        )
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
    
    private func computeSideMargin() -> CGFloat {
        if #available(iOS 11, *) {
            return presentingViewController.view.directionalLayoutMargins.leading
                +  presentingViewController.view.directionalLayoutMargins.trailing
                + sideMargin
        } else { 
            return presentingViewController.view.layoutMargins.right
                +  presentingViewController.view.layoutMargins.left
                + sideMargin
        }
    }
    
    private func computeTotalVerticalMargin() -> CGFloat {
        if #available(iOS 11, *) {
            return presentingViewController.view.directionalLayoutMargins.bottom
                + presentingViewController.view.directionalLayoutMargins.top
                + marginFromBottom
        } else {
            return presentingViewController.view.layoutMargins.top
                + presentingViewController.view.layoutMargins.bottom
                + marginFromBottom
        }
    }
    
    @objc func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    private func computePresentedViewRect(traitCollection: UITraitCollection, sideMargin: CGFloat,
                                          containerView: UIView, totalVerticalMargin: CGFloat) -> CGRect {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular), (.regular, .regular):
            let point = CGPoint(
                x: sideMargin,
                y: containerView.frame.height - totalVerticalMargin - portraitHeight
            )
            return CGRect(
                origin: point,
                size: CGSize(width: containerView.frame.width - (2 * sideMargin), height: portraitHeight)
            )
        case (.regular, .compact), (.compact, .compact):
            let point = CGPoint(
                x: sideMargin,
                y: containerView.frame.height - totalVerticalMargin - landscapeHeight
            )
            return CGRect(
                origin: point,
                size: CGSize(width: containerView.frame.width - (2 * sideMargin), height: landscapeHeight)
            )
        case (.unspecified, .unspecified),
             (.unspecified, .compact),
             (.unspecified, .regular),
             (.compact, .unspecified),
             (.regular, .unspecified):
            return CGRect(origin: CGPoint(
                x: 0,
                y: containerView.frame.height / 2),
                size: CGSize(
                    width: containerView.frame.width,
                    height: containerView.frame.height / 2
                )
            )
        default:
            return .zero
        }
    }
}
