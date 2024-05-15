//
//  MessagesView.swift
//  
//
//  Created by Mohamed Aglan on 5/15/24.
//

import UIKit

class MessagesView: UIViewController {

    
    //MARK: - IBOutLets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextContainerView: UIView!
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    @IBOutlet weak var sendMessageBt: UIButton!
    @IBOutlet weak var newChatsContainerStackView: UIStackView!
    @IBOutlet weak var newChatStackView: UIStackView!
    @IBOutlet weak var previousChatStackView: UIStackView!
    
    
    
    //MARK: - Properties -
    
    
    
    
    
    //MARK: - LifeCycle Events -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    public init() {
        super.init(nibName: "MessagesView", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //MARK: - Configure UI -
    
    
    
    
    
    
    //MARK: - IBActions -
    @IBAction func sendTextMessageButton(_ sender: UIButton) {
        
    }
    
    
    @IBAction func sendRecordButton(_ sender: UIButton) {
    }
    
    @IBAction func moreButton(_ sender: UIButton) {
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
    }
    
}
