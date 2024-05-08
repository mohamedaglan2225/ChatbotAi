//
//  EditOnMessagesController.swift
//
//
//  Created by Mohamed Aglan on 4/19/24.
//

import UIKit

protocol EditOnMessageAction {
    func editMessage(message: String)
}

public class EditOnMessagesController: UIViewController {
    
    //MARK: - IBOutLets -
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var shortMessageStackView: UIStackView!
    @IBOutlet weak var longMessageStackView: UIStackView!
    @IBOutlet weak var unofficialStackView: UIStackView!
    @IBOutlet weak var professionalStackView: UIStackView!
    
    
    //MARK: - Properties -
    var delegate: EditOnMessageAction?
    
    //MARK: - LifeCycle Events -
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    public init() {
        super.init(nibName: "EditOnMessagesController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     
    //MARK: - Configure UI -
    private func configureUI() {
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.white.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        containerView.layer.shadowRadius = 2
        
        let shortMessageTap = UITapGestureRecognizer(target: self, action: #selector(sendShortMessageAction))
        shortMessageStackView.addGestureRecognizer(shortMessageTap)
        
        let longMessageTap = UITapGestureRecognizer(target: self, action: #selector(longMessageAction))
        longMessageStackView.addGestureRecognizer(longMessageTap)
        
        
        let unofficalMessageTap = UITapGestureRecognizer(target: self, action: #selector(unofficialMessageAction))
        unofficialStackView.addGestureRecognizer(unofficalMessageTap)
        
        
        let professionalMessageTap = UITapGestureRecognizer(target: self, action: #selector(professionalMessageAction))
        professionalStackView.addGestureRecognizer(professionalMessageTap)
    }
    
    
    
    //MARK: - IBActions -
    @objc private func sendShortMessageAction() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {return}
            self.delegate?.editMessage(message: "Make your response shorter")
        }
    }
    
    @objc private func longMessageAction() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {return}
            self.delegate?.editMessage(message: "Make your response longer")
        }
    }
    
    @objc private func unofficialMessageAction() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {return}
            self.delegate?.editMessage(message: "Write the same answer in a unformal way")
        }
    }
    
    @objc private func professionalMessageAction() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {return}
            self.delegate?.editMessage(message: "Write the same answer in a professional manner")
        }
    }
    
}
