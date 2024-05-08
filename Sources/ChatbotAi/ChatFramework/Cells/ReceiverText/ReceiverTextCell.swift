//
//  ReceiverTextCell.swift
//  Farhety
//
//  Created by Mohamed Aglan on 3/12/24.
//

import UIKit

class ReceiverTextCell: UITableViewCell {

    
    //MARK: - IBOutLets -
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dropMenueBt: UIButton!
    
    
    //MARK: - Properties -
    var dropDownMenueClosure: (() -> ())?
    
    
    //MARK: - LifeCycle Events -
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
//        handleMenueShape()
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        containerView.layer.cornerRadius = 16
        
    }
    
    
    public func configureCell(model: Choice) {
        if let message = model.message?.content {
            self.messageLabel.text = message
        }
    }
   
    
    
    //MARK: - IBActions -
    @IBAction func droDownMenueButton(sender: UIButton) {
        dropDownMenueClosure?()
    }
    
}

//extension ReceiverTextCell {
//    var menuItems: [UIAction] {
//        return [
//            UIAction(title: "Copy", image: UIImage(resource: .copy) ,handler: { [weak self] (_) in
//                guard let self = self else {return}
//                
//            }),
//            UIAction(title: "Share", image: UIImage(resource: .share) , handler: { [weak self] (_) in
//                guard let self = self else {return}
//                
//            }),
//            UIAction(title: "Edit", image: UIImage(resource: .edit) , handler: { [weak self] (_) in
//                guard let self = self else {return}
//                
//            })
//        ]
//    }
//    
//    var demoMenu: UIMenu {
//        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
//    }
//
//    
//    private func handleMenueShape() {
//        dropMenueBt.menu = demoMenu
//        dropMenueBt.showsMenuAsPrimaryAction = true
//    }
//    
//}
