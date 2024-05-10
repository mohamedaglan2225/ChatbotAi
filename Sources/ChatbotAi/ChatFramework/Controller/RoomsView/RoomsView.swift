//
//  RoomsView.swift
//  
//
//  Created by Mohamed Aglan on 5/10/24.
//

import UIKit

public class RoomsView: UIView {

    
    //MARK: - IBOutLets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newChatsView: UIView!
    
    
    
    //MARK: - Properties -
    private let storage: MessagesStorage = {
        DefaultMessageStorage(coreDataWrapper: ServiceLocator.storage)
    }()
    
    
    
    //MARK: - LifeCycle Events -
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        configureInitialDesign()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        configureInitialDesign()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "RoomsView", bundle: Bundle.module)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(view)
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    
    
    //MARK: - Configure Design -
    private func configureInitialDesign() {
        newChatsView.layer.cornerRadius = 16
        
        let newChatTap = UITapGestureRecognizer(target: self, action: #selector(newChatAction))
        newChatsView.addGestureRecognizer(newChatTap)
        
    }
    
    
    
    
    
    //MARK: - IBActions -
    @objc private func newChatAction() {
        let chatViewTap = ChatView(frame: self.bounds)
        let room = storage.getOrCreateRoom(with: "Room 2")
        let roomId = Int(room.roomId)
        chatViewTap.chatModel = self.storage.fetchMessages(roomId: roomId)
        self.addSubview(chatViewTap)
    }
    

}

