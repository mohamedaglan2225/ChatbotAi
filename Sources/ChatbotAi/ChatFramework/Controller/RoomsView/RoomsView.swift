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
    
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window != nil {
            fetchRooms()
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
        rooms = storage.fetchRooms()
    }
    
    
    
    private func registerTableView() {
        tableView.register(.init(nibName: "ChatRoomsCell", bundle: Bundle.module),forCellReuseIdentifier: "ChatRoomsCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func presentInputAlert() {
        // Create the alert controller
        let alertController = UIAlertController(title: "title", message: "Please enter your information", preferredStyle: .alert)
        
        // Add a text field to the alert controller
        alertController.addTextField { textField in
            textField.placeholder = "Type something here..."
            let newRoomId = self.storage.createNewRoom(roomName: textField.text ?? "Default")
            if let parentVC = self.parentViewController {
                let destinationViewController = ChatView()
                destinationViewController.roomId = Int(newRoomId.roomId)
                destinationViewController.modalPresentationStyle = .fullScreen
                parentVC.present(destinationViewController, animated: true, completion: nil)
            } else {
                fatalError("Parent view controller not found")
            }
        }
        
        // Create the OK action
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
            // Retrieve the first text field's text
            if let textField = alertController?.textFields?.first, let inputText = textField.text {
                print("Input: \(inputText)")
                // Handle the input text
            }
        }
        
        // Create the Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add actions to the alert controller
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        if let parentVC = parentViewController {
            parentVC.present(alertController, animated: true, completion: nil)
        } else {
            fatalError("Parent view controller not found")
        }
        
    }
    
    
    
    
    //MARK: - IBActions -
    @objc private func newChatAction() {
       presentInputAlert()
    }
    
}


//MARK: - TableView -
extension RoomsView: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomsCell", for: indexPath) as? ChatRoomsCell {
            cell.chatRoomName.text = rooms[indexPath.row].name ?? ""
            return cell
        }
        return UITableViewCell()
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let parentVC = parentViewController {
            let destinationViewController = ChatView()
            destinationViewController.modalPresentationStyle = .fullScreen
            destinationViewController.roomId = Int(rooms[indexPath.row].roomId)
            parentVC.present(destinationViewController, animated: true, completion: nil)
        } else {
            fatalError("Parent view controller not found")
        }
    }
}
