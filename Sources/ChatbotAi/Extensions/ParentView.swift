//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/8/24.
//

import Foundation
import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            parentResponder = responder.next
        }
        return nil
    }
}

extension UIViewController {
    public func parentIQContainerViewController() -> UIViewController? {
        return self
    }
    
}
