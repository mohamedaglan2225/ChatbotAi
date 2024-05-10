//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/8/24.
//

import UIKit
import AVKit

extension ChatView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        if messageTextView.contentSize.height < 60 {
            textHeight.constant = messageTextView.contentSize.height
        }
        if messageTextView.text == "" {
            sendMessageBt.isHidden = true
            messageTextContainerView.layer.borderColor = UIColor.white.cgColor
        }else {
            sendMessageBt.isHidden = false
            messageTextContainerView.layer.borderColor = UIColor.blue.cgColor
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        messageTextView.text = ""
        
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if messageTextView.textColor == UIColor.lightGray {
            messageTextView.text = nil
            messageTextView.textColor = UIColor.black
        }
        return true
    }
    
}

extension ChatView {
    func parentContainerViewController() -> UIViewController? {
        
        var matchController = viewContainingController()
        var parentContainerViewController: UIViewController?
        
        if var navController = matchController?.navigationController {
            
            while let parentNav = navController.navigationController {
                navController = parentNav
            }
            
            var parentController: UIViewController = navController
            
            while let parent = parentController.parent,
                  (parent.isKind(of: UINavigationController.self) == false &&
                   parent.isKind(of: UITabBarController.self) == false &&
                   parent.isKind(of: UISplitViewController.self) == false) {
                
                parentController = parent
            }
            
            if navController == parentController {
                parentContainerViewController = navController.topViewController
            } else {
                parentContainerViewController = parentController
            }
        } else if let tabController = matchController?.tabBarController {
            
            if let navController = tabController.selectedViewController as? UINavigationController {
                parentContainerViewController = navController.topViewController
            } else {
                parentContainerViewController = tabController.selectedViewController
            }
        } else {
            while let parentController = matchController?.parent,
                  (parentController.isKind(of: UINavigationController.self) == false &&
                   parentController.isKind(of: UITabBarController.self) == false &&
                   parentController.isKind(of: UISplitViewController.self) == false) {
                
                matchController = parentController
            }
            
            parentContainerViewController = matchController
        }
        
        let finalController = parentContainerViewController?.parentIQContainerViewController() ?? parentContainerViewController
        
        return finalController
        
    }
    
    
    func viewContainingController() -> UIViewController? {
        
        var nextResponder: UIResponder? = self
        
        repeat {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            
        } while nextResponder != nil
        
        return nil
    }
    
}

extension ChatView {
    public func checkForPermissions() async -> Bool {
        let hasPermissions = await self.avAuthorization(mediaType: .audio)
        return hasPermissions
    }
    
    public  func avAuthorization(mediaType: AVMediaType) async -> Bool {
        let mediaAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch mediaAuthorizationStatus {
        case .denied, .restricted: return false
        case .authorized: return true
        case .notDetermined:
            if #available(iOS 13.0, *) {
                return await withCheckedContinuation { continuation in
                    AVCaptureDevice.requestAccess(for: mediaType) { granted in
                        continuation.resume(returning: granted)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        @unknown default: return false
        }
        
        return false
    }
    
}

extension ChatView {
    
    public func presentPermissionAlert() {
        
        let alert = UIAlertController(title: "Microphone Access Denied", message: "Please grant access to the microphone in Settings to continue using this feature.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        if let parentVC = parentViewController {
            parentVC.present(parentVC, animated: true, completion: nil)
        } else {
            print("Parent view controller not found")
        }
    }
}

extension ChatView: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
