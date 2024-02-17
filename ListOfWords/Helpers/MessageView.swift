//
//  MessageView.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 17.02.24.
//

import UIKit

class MessageView: UIView
{
    enum MessageType {
        case alert, info, warning
    }
    
    private var messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.alpha = 0.0
        self.layer.cornerRadius = 10.0
        self.clipsToBounds  =  true
        
        messageLabel = UILabel(frame: CGRect())
        messageLabel.textColor = UIColor.white
        messageLabel.textAlignment = .center;
        messageLabel.font.withSize(12.0)
        messageLabel.clipsToBounds  =  true
        messageLabel.numberOfLines = 0
        
        self.addSubview(messageLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let labelTop = NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 16)
        let labelBottom = NSLayoutConstraint(item: messageLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -16)
        let labelLeading = NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 16)
        let labelTrailing = NSLayoutConstraint(item: messageLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -16)
        
        NSLayoutConstraint.activate([centerX, labelTop, labelBottom, labelLeading, labelTrailing])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: String, type: MessageType)
    {
        messageLabel.text = message
        
        switch type {
        case .alert:
            self.backgroundColor = UIColor.systemRed.withAlphaComponent(1)
        case .info:
            self.backgroundColor = UIColor.systemBlue.withAlphaComponent(1)
        case .warning:
            self.backgroundColor = UIColor.systemOrange.withAlphaComponent(1)
            messageLabel.textColor = UIColor.black
        }
    }
}
