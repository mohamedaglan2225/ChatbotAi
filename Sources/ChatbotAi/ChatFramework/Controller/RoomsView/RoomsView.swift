//
//  RoomsView.swift
//  
//
//  Created by Mohamed Aglan on 5/10/24.
//

import UIKit

class RoomsView: UIViewController {

    
    //MARK: - IBOutLets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newChatsView: UIView!
    
    
    
    //MARK: - Properties -
    
    
    
    //MARK: - LifeCycle Events -
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInitialDesign()
        
    }

    public init() {
        super.init(nibName: "RoomsView", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Configure Design -
    private func configureInitialDesign() {
        newChatsView.layer.cornerRadius = 16
        
        let newChatTap = UITapGestureRecognizer(target: self, action: #selector(newChatAction))
        newChatsView.addGestureRecognizer(newChatTap)
        
    }
    
    
    
    
    
    //MARK: - IBActions -
    @objc private func newChatAction() {
        
    }
    

}

