//
//  MessagesView.swift
//  
//
//  Created by Mohamed Aglan on 5/15/24.
//

import UIKit

class MessagesView: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    public init() {
        super.init(nibName: "MessagesView", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
