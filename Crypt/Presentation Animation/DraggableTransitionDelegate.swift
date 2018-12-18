import Foundation
import UIKit

class DraggableTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DraggablePresentationController(presentedViewController: presented, presenting: source)
    }
}

private extension CGFloat {
    // Spring animation
    static let springDampingRatio: CGFloat = 0.7
    static let springInitialVelocityY: CGFloat =  10
}

private extension Double {
    // Spring animation
    static let animationDuration: Double = 0.2
}

enum DragDirection {
    case up
    case down
}

enum DraggablePosition {
    case collapsed
    case open
    case midway

    var heightMulitiplier: CGFloat {
        switch self {
        case .collapsed:
            return 0.2
        case .open:
            return 0.95
        case .midway:
            return 0.5
        }
    }

    var downBoundary: CGFloat {
        switch self {
        case .collapsed:
            return 0.0
        case .open:
            return 0.8
        case .midway:
            return 0.35
        }
    }

    var upBoundary: CGFloat {
        switch self {
        case .collapsed:
            return 0.0
        case .open:
            return 0.65
        case .midway:
            return 0.27
        }
    }

    var dimAplha: CGFloat {
        switch self {
        case .collapsed:
            return 0.0
        case .open:
            return 0.45
        case .midway:
            return 0.2
        }
    }

    func yOrigin(for maxHeight: CGFloat) -> CGFloat {
        return maxHeight - (maxHeight * heightMulitiplier)
    }

    func nextPosition(for direction: DragDirection) -> DraggablePosition {
        switch(self, direction) {
        case (.collapsed, .up):
            return .midway
        case (.collapsed, .down):
            return .collapsed
        case (.open, .up):
            return .open
        case (.open, .down):
            return .midway
        case (.midway, .up):
            return .open
        case (.midway, .down):
            return .collapsed
        }
    }
}

final class DraggablePresentationController: UIPresentationController {

    private var draggableView: DraggableViewType? {
        return presentedViewController as? DraggableViewType
    }

    // MARK: Private
    private var dimmingView = UIView()
    private var draggablePosition: DraggablePosition = .midway {
        didSet {
            if draggablePosition == .open {
                draggableView?.handleInteraction(enabled: true)
            } else {
                draggableView?.handleInteraction(enabled: false)
            }

            switch (oldValue, draggablePosition) {
            case (.midway, .collapsed):
                presentedViewController.dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
    }

    private let springTiming = UISpringTimingParameters(dampingRatio: .springDampingRatio, initialVelocity: CGVector(dx: 0, dy: .springInitialVelocityY))
    private var animator: UIViewPropertyAnimator?

    private var dragDirection: DragDirection = .up
    private let maxFrame = CGRect(x: 0, y: 0, width: UIWindow.root.bounds.width, height: UIWindow.root.bounds.height + UIWindow.key.safeAreaInsets.bottom)
    private var panOnPresented = UIGestureRecognizer()

    override var frameOfPresentedViewInContainerView: CGRect {
        let presentedViewOrigin = CGPoint(x: 0, y: draggablePosition.yOrigin(for: maxFrame.height))
        let presentedViewSize = CGSize(width: maxFrame.width, height: maxFrame.height)
        return CGRect(origin: presentedViewOrigin, size: presentedViewSize)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        containerView.insertSubview(dimmingView, at: 1)
        dimmingView.alpha = 0
        dimmingView.backgroundColor = .black
        dimmingView.frame = containerView.frame
        draggableView?.handleInteraction(enabled: false)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        animator = UIViewPropertyAnimator(duration: .animationDuration, timingParameters: self.springTiming)
        animator?.isInterruptible = true
        panOnPresented = UIPanGestureRecognizer(target: self, action: #selector(userDidPan(panRecognizer:)))
        presentedView?.addGestureRecognizer(panOnPresented)
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    @objc private func userDidPan(panRecognizer: UIPanGestureRecognizer) {
        draggableView?.dismissKeyboard()
        let translationPoint = panRecognizer.translation(in: presentedView)
        let currentOriginY = draggablePosition.yOrigin(for: maxFrame.height)
        let newOffset = translationPoint.y + currentOriginY
        dragDirection = newOffset > currentOriginY ? .down : .up

        let canDragInProposedDirection = dragDirection == .up &&
            draggablePosition == .open ? false : true

        if newOffset >= 0 && canDragInProposedDirection {
            switch panRecognizer.state {
            case .began, .changed:
                presentedView?.frame.origin.y = newOffset
            case .ended:
                animate(newOffset)
            default:
                break
            }
        }
    }

    private func animate(_ dragOffset: CGFloat) {
        let distanceFromBottom = maxFrame.height - dragOffset

        switch dragDirection {
        case .up:
            if distanceFromBottom > (maxFrame.height * DraggablePosition.open.upBoundary) {
                animate(to: .open)
            } else if distanceFromBottom > (maxFrame.height * DraggablePosition.midway.upBoundary) {
                animate(to: .midway)
            } else {
                animate(to: .collapsed)
            }
        case .down:
            if distanceFromBottom > (maxFrame.height * DraggablePosition.open.downBoundary) {
                animate(to: .open)
            } else if distanceFromBottom > (maxFrame.height * DraggablePosition.midway.downBoundary) {
                animate(to: .midway)
            } else {
                animate(to: .collapsed)
            }
        }

    }
    private func animate(to position: DraggablePosition) {
        guard let animator = animator else { return }

        animator.addAnimations {
            self.presentedView?.frame.origin.y = position.yOrigin(for: self.maxFrame.height)
            self.dimmingView.alpha = position.dimAplha
        }

        animator.addCompletion { (animationPosition) in
            switch animationPosition {
            case .end:
                self.draggablePosition = position
            default: break
            }
        }
        animator.startAnimation()
    }
}

// MARK: Public
extension DraggablePresentationController {
    func animateToOpen() {
        animate(to: .open)
    }
}


