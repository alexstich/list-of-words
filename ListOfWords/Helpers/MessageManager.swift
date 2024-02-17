//
//  MessageManager.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 17.02.24.
//

import UIKit

class MessageManager
{
    static let shared = MessageManager()
    
    var messageShowingInterval: Double = 1
    
    private var alertsQueue: [(String, MessageView.MessageType)] = []
    private var isShowingAlert = false
    
    private init() {}
    
    func showAlert(message: (String, MessageView.MessageType), from topController: UIViewController?) {
        
        var from = topController
        
        if from == nil {
            from = self.getTopController()
        }
        
        alertsQueue.append(message)
        showNextAlert(from: from!)
    }
    
    private func showNextAlert(from topController: UIViewController)
    {
        guard !alertsQueue.isEmpty else { return }
        
        guard !isShowingAlert else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.showNextAlert(from: topController)
            }
            return
        }
        
        let message = alertsQueue.removeFirst()
        isShowingAlert = true
        
        let messageView = MessageView()
        messageView.configure(with: message.0, type: message.1)
        
        if let topView = topController.view {
            
            topView.addSubview(messageView)
            messageView.alpha = 0
            
            messageView.translatesAutoresizingMaskIntoConstraints = false
            
            let containerCenterX = NSLayoutConstraint(item: messageView, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1, constant: 0)
            let containerTop = NSLayoutConstraint(item: messageView, attribute: .top, relatedBy: .equal, toItem: topView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20)
            let containerLeading = NSLayoutConstraint(item: messageView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: topView, attribute: .leading, multiplier: 1, constant: 30)
            let containerTrailing = NSLayoutConstraint(item: messageView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: topView, attribute: .trailing, multiplier: 1, constant: -30)
            
            NSLayoutConstraint.activate([containerCenterX, containerTop, containerLeading, containerTrailing])
            
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    
                    messageView.alpha = 1
                    
                }, completion: { _ in
           
                    UIView.animate(
                        withDuration: 0.5,
                        delay: self.messageShowingInterval,
                        options: [],
                        animations: {
                            
                            messageView.alpha = 0
                            
                        }, completion: { _ in
                            
                            messageView.removeFromSuperview()
                            
                            self.isShowingAlert = false
                            
                            self.showNextAlert(from: topController)
                        }
                    )
                }
            )
        }
    }
    
    func getTopController() -> UIViewController
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
