//
//  SenderTextCell.swift
//  Farhety
//
//  Created by Mohamed Aglan on 3/12/24.
//

import UIKit

public class SenderTextCell: UITableViewCell {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        messageLabel.sizeToFit()
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        containerView.layer.cornerRadius = 16
    }
    
    
    public func configureCell(model: Choice) {
        if let message = model.message?.content {
            self.messageLabel.text = message
        }
    }
    
    
}
