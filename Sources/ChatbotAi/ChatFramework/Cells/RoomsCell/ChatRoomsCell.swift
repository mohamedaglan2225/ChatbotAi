//
//  ChatRoomsCell.swift
//  
//
//  Created by Mohamed Aglan on 5/13/24.
//

import UIKit

class ChatRoomsCell: UITableViewCell {

    @IBOutlet weak var chatRoomName: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0.1
        containerView.layer.borderColor = UIColor.white.cgColor
    }

   
    
}
