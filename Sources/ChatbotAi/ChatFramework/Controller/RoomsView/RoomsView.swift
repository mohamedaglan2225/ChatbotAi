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
    
    var rooms: [Room] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    
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
        fetchRooms()
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
        registerTableView()
        newChatsView.layer.cornerRadius = 16
        
        let newChatTap = UITapGestureRecognizer(target: self, action: #selector(newChatAction))
        newChatsView.addGestureRecognizer(newChatTap)
        
    }
    
    
    private func fetchRooms() {
        self.rooms = self.storage.fetchRooms()
        print(rooms.count)
    }
    
    
    
    private func registerTableView() {
//        tableView.register(.init(nibName: "RoomsCell", bundle: Bundle.module),forCellReuseIdentifier: "RoomsCell")
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.separatorStyle = .none
    }
    
    
    //MARK: - IBActions -
    @objc private func newChatAction() {
        let chatViewTap = ChatView(frame: self.bounds)
        let newRoom = storage.getOrCreateRoom(with: "Room 3", forceNew: true)
//        let roomId = Int(room.roomId)
//        chatViewTap.chatModel = self.storage.fetchMessages(roomId: roomId)
        print("Room created with name: \(newRoom.name) and ID: \(newRoom.roomId)")
        self.addSubview(chatViewTap)
    }
    

}


//MARK: - TableView -
//extension RoomsView: UITableViewDataSource, UITableViewDelegate {
//    
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return rooms.count
//    }
//    
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsCell", for: indexPath) as? RoomsCell {
////            cell.configureCell(room: rooms[indexPath.row])
//            return cell
//        }
//        return UITableViewCell()
//    }
//}
