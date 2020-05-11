import UIKit

extension UIView {
    func startBlinking() {
        alpha = 0.5
        UIView.animate(
            withDuration: 0.9,
            delay: 0.0,
            options: [AnimationOptions.autoreverse, .repeat, .allowUserInteraction],
            animations: {
                self.alpha = 1.0
        })
    }
    
    func stopBlinking() {
        layer.removeAllAnimations()
    }
}
