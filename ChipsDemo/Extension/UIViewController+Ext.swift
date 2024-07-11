import Foundation
import UIKit

extension UIViewController {
    static var topViewController: UIViewController? {
        UIApplication.shared.windows.last(where: { $0.isKeyWindow })?.rootViewController?.topMostViewController()
    }

    func topMostViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }

        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? self
        }

        if let tabBarController = self as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return selectedViewController.topMostViewController()
            }
        }

        return self
    }

    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension String: DropdownItem {
    var readonlyText: String {
        self
    }

    var displayText: String {
        self
    }

    var optionText: String {
        self
    }
}

extension Int: DropdownItem {
    var readonlyText: String {
        String(self)
    }

    var displayText: String {
        String(self)
    }

    var optionText: String {
        String(self)
    }
}


