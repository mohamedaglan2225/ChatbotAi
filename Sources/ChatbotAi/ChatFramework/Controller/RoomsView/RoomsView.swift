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
        print("All Rooms are here \(storage.fetchRooms())")
        rooms = storage.fetchRooms()
    }
    
    
    
    private func registerTableView() {
        tableView.register(.init(nibName: "ChatRoomsCell", bundle: Bundle.module),forCellReuseIdentifier: "ChatRoomsCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    
    //MARK: - IBActions -
    @objc private func newChatAction() {
//        let chatViewTap = ChatView(frame: self.bounds)
//        let newRoom = storage.getOrCreateRoom(with: )
//        print("Room created with name: \(newRoom.name) and ID: \(newRoom.roomId)")
//        self.addSubview(chatViewTap)
    }
    

}


//MARK: - TableView -
extension RoomsView: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomsCell", for: indexPath) as? ChatRoomsCell {
            cell.chatRoomName.text = "\(rooms[indexPath.row].roomId)"
            return cell
        }
        return UITableViewCell()
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let parentVC = parentViewController {
            let destinationViewController = MessagesView()
//            destinationViewController.roomId = Int(rooms[indexPath.row].roomId)
            parentVC.present(destinationViewController, animated: true, completion: nil)
        } else {
            print("Parent view controller not found")
        }
//        chatViewTap.roomId = Int(rooms[indexPath.row].roomId)
//        self.addSubview(chatViewTap)
    }
}
