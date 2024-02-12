//
//  ToastMessage.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 11.02.24.
//

import UIKit

import UIKit

class ToastMessage: NSObject {
    
    enum Purpose {
        case alert, info, warning
    }
    
    static func show(message: String, purpuse: Purpose = .alert, controller: UIViewController? = nil)
    {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 10.0
        toastContainer.clipsToBounds  =  true
        
        switch purpuse {
        case .alert:
            toastContainer.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        case .info:
            toastContainer.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        case .warning:
            toastContainer.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        }
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        
        var controller = controller
        
        if controller == nil {
            controller = self.getTopController()
        }
        
        controller!.view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = NSLayoutConstraint(item: toastLabel, attribute: .centerX, relatedBy: .equal, toItem: toastContainer, attribute: .centerX, multiplier: 1, constant: 0)
        let labelTop = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 16)
        let labelBottom = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -16)
        let labelLeading = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 16)
        let labelTrailing = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -16)
        
        let containerCenterX = NSLayoutConstraint(item: toastContainer, attribute: .centerX, relatedBy: .equal, toItem: controller!.view, attribute: .centerX, multiplier: 1, constant: 0)
        let containerTop = NSLayoutConstraint(item: toastContainer, attribute: .top, relatedBy: .equal, toItem: controller!.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20)
        let containerLeading = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: controller!.view, attribute: .leading, multiplier: 1, constant: 30)
        let containerTrailing = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: controller!.view, attribute: .trailing, multiplier: 1, constant: -30)
        
        NSLayoutConstraint.activate([centerX, labelTop, labelBottom, labelLeading, labelTrailing, containerCenterX, containerTop, containerLeading, containerTrailing])
        
        UIView.animate(withDuration: 0.5, animations: {
            toastContainer.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        }
    }
    
    static func getTopController() -> UIViewController
    {
        let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            
        let activeWindow = windowScene?.windows.first(where: { $0.isKeyWindow })
    
        var topController: UIViewController? = activeWindow?.rootViewController
        
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        
        if let _navController = topController as? UINavigationController {
            topController = _navController.viewControllers.last
        }
        
        return topController!
    }
}

