import UIKit

extension UIWindow {
    // This is the delegate's window; it should never be nil and it usually is the key window.
    @objc public class var root: UIWindow {
        guard let optionalRootWindow = UIApplication.shared.delegate?.window,
            let rootWindow = optionalRootWindow else { fatalError("Fatal Error: delegate's window is nil!") }
        return rootWindow
    }

    // Some Apple classes set a different window to be the key window while presenting viewcontrollers,
    // so keyWindow should be taken with a grain of salt and it might not be what we expect.
    // It should not be nil and, most of the time, it should be the same as `root`.
    public class var key: UIWindow {
        guard let keyWindow = UIApplication.shared.keyWindow else { fatalError("Fatal Error: now window is set to keyWindow") }
        return keyWindow
    }
}
