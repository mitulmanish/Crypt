import Foundation
import UIKit

public class DraggableTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?, source: UIViewController
    ) -> UIPresentationController? {
        DraggablePresentationController(
            presentedViewController: presented,
            presenting: source
        )
    }
}

private enum DragDirection {
    case up
    case down
}

private enum DraggablePosition {
    case open
    case mid
    case collapsed

    var heightMulitiplier: CGFloat {
        switch self {
        case .collapsed:
            return 0.2
        case .open:
            return 0.9
        case .mid:
            return 0.5
        }
    }

    var downBoundary: CGFloat {
        switch self {
        case .collapsed:
            return 0.0
        case .open:
            return 0.8
        case .mid:
            return 0.35
        }
    }

    var upBoundary: CGFloat {
        switch self {
        case .collapsed:
            return 0.0
        case .open:
            return 0.65
        case .mid:
            return 0.27
        }
    }

    func yOrigin(for maxHeight: CGFloat) -> CGFloat {
        return maxHeight - (maxHeight * heightMulitiplier)
    }
}

private final class DraggablePresentationController: UIPresentationController {

    private var draggableViewController: KeyboardDismissableDraggableView {
        guard let presentedViewController = presentedViewController as?  KeyboardDismissableDraggableView else {
            fatalError("presentedViewController must conform to KeyboardDismissableDraggableView")
        }
        return presentedViewController
    }

    private var presentedViewOriginY: CGFloat {
        presentedView?.frame.origin.y ?? 0
    }

    private var draggablePosition: DraggablePosition = .open {
        didSet {
            if draggablePosition == .open {
                draggableViewController.scrollView.isScrollEnabled = true
                draggableViewController.handleInteraction(enabled: true)
            } else {
                draggableViewController.handleInteraction(enabled: false)
            }
        }
    }
    
    private var dragDirection: DragDirection = .up
    private var animator: UIViewPropertyAnimator?

    private var maxFrame: CGRect {
        return CGRect(x: 0, y: 0, width: containerView?.bounds.width ?? 0, height: containerView?.bounds.height ?? 0)
    }

    private var presentedViewGestureRecognizer = UIPanGestureRecognizer()
    private var containerViewGestureRecognizer = UITapGestureRecognizer()
    private var presentedViewGestureDelegate: PresentedViewGestureDelegate?
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let yOrigin = draggablePosition.yOrigin(for: maxFrame.height)
        let presentedViewOrigin = CGPoint(x: 0, y: yOrigin)
        let presentedViewSize = CGSize(
            width: containerView?.bounds.width ?? 0,
            height: (containerView?.bounds.height ?? 0) - yOrigin
        )
        return CGRect(origin: presentedViewOrigin, size: presentedViewSize)
    }

    override func containerViewDidLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func presentationTransitionWillBegin() {
        draggableViewController.handleInteraction(enabled: true)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        animator = UIViewPropertyAnimator(
            duration: .animationDuration,
            curve: .easeInOut
        )
        animator?.isInterruptible = false
        presentedViewGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(userDidPan(panRecognizer:))
        )
        presentedView?.addGestureRecognizer(presentedViewGestureRecognizer)
        presentedViewGestureDelegate = PresentedViewGestureDelegate(
            scrollView: draggableViewController.scrollView
        )
        presentedViewGestureRecognizer.delegate = presentedViewGestureDelegate
        containerViewGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(receivedTouch)
        )
        containerViewGestureRecognizer.delegate = self
        containerView?.addGestureRecognizer(containerViewGestureRecognizer)
        animate(to: .open)
    }

    @objc func receivedTouch(tapRecognizer: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: .none)
    }

    @objc private func userDidPan(panRecognizer: UIPanGestureRecognizer) {
        draggableViewController.dismissKeyboard()
        let translationPoint = panRecognizer.translation(in: presentedView)
        let currentOriginY = draggablePosition.yOrigin(for: maxFrame.height)
        let newOffset = translationPoint.y + currentOriginY
        let adjustedOffset = (newOffset < 0) ? -1 * newOffset : newOffset

        dragDirection = adjustedOffset > currentOriginY ? .down : .up

        let canDragInProposedDirection = dragDirection == .up &&
            draggablePosition == .open ? false : true

        if newOffset >= 0 && canDragInProposedDirection {
            switch panRecognizer.state {
            case .began, .changed:
                presentedView?.frame.origin.y = max(DraggablePosition.open.yOrigin(for: maxFrame.height), adjustedOffset)
            case .ended:
                animate(max(DraggablePosition.open.yOrigin(for: maxFrame.height), adjustedOffset))
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
            } else if distanceFromBottom > (maxFrame.height * DraggablePosition.mid.upBoundary) {
                animate(to: .mid)
            } else {
                animate(to: .collapsed)
            }
        case .down:
            if distanceFromBottom > (maxFrame.height * DraggablePosition.open.downBoundary) {
                animate(to: .open)
            } else if distanceFromBottom > (maxFrame.height * DraggablePosition.mid.downBoundary) {
                animate(to: .mid)
            } else {
                animate(to: .collapsed)
            }
        }
    }

    private func getDraggablePosition() -> DraggablePosition {
        let distanceFromBottom = maxFrame.height - presentedViewOriginY

        switch dragDirection {
        case .up:
            if distanceFromBottom > (maxFrame.height * DraggablePosition.open.upBoundary) {
                return .open
            } else if distanceFromBottom > (maxFrame.height * DraggablePosition.mid.upBoundary) {
                return .mid
            } else {
                return .collapsed
            }
        case .down:
            if distanceFromBottom > (maxFrame.height * DraggablePosition.open.downBoundary) {
                return .open
            } else if distanceFromBottom > (maxFrame.height * DraggablePosition.mid.downBoundary) {
                return .mid
            } else {
                return .collapsed
            }
        }
    }

    private func animate(to position: DraggablePosition) {
        guard let animator = animator else { return }

        animator.addAnimations {
            self.presentedView?.frame.origin.y = position.yOrigin(for: self.maxFrame.height)
        }

        animator.addCompletion { _ in
            self.draggablePosition = position
        }
        animator.startAnimation()
    }
}

extension DraggablePresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: presentedView)
        return presentedView?.bounds.contains(touchPoint) == false
    }
}


private final class PresentedViewGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    
    private let scrollView: UIScrollView
    
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let velocity = gestureRecognizer.velocity(in: scrollView)
        if scrollView.contentOffset.y <= 0,
            scrollView.isDecelerating == false,
            velocity.y > 0 {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
        return false
    }
}


private extension CGFloat {
    static let springDampingRatio: CGFloat = 0.7
    static let springInitialVelocityY: CGFloat =  10
}

private extension Double {
    static let animationDuration: Double = 0.22
}
