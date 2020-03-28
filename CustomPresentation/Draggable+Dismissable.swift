import UIKit

public typealias KeyboardDismissableDraggableView = KeyboardDismissable & DraggableViewType

public protocol DraggableViewType: AnyObject {
    func handleInteraction(enabled: Bool)
    var scrollView: UIScrollView { get }
}

public protocol KeyboardDismissable: AnyObject {
    func dismissKeyboard()
}
