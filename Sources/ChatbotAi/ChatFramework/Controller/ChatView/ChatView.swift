//
//  ChatView.swift
//  
//
//  Created by Mohamed Aglan on 5/14/24.
//

import UIKit
import MobileCoreServices
import AVKit
import CoreData

public protocol ReusableViewDelegate: AnyObject {
    func didTapBackButton()
}

class ChatView: UIViewController {
    
    
    //MARK: - IBOutLets -
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextContainerView: UIView!
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    @IBOutlet weak var sendMessageBt: UIButton!
    @IBOutlet weak var newChatsContainerStackView: UIStackView!
    @IBOutlet weak var newChatStackView: UIStackView!
    @IBOutlet weak var previousChatStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    //MARK: - Properties -
    let XIB_NAME = "ChatView"
    private var request = Networking()
    var chatModel: [Choice] = []
    
    public var apiKey: String?
    weak var delegate: ReusableViewDelegate?
    let timestamp = Date()
    var roomId: Int?
    var roomName = "Default Room"
    
    private let storage: MessagesStorage = {
        DefaultMessageStorage(coreDataWrapper: ServiceLocator.storage)
    }()
    
    
    
    
    //MARK: - LifeCycle Events -
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureInitialDesign()
    }

    public init() {
        super.init(nibName: "ChatView", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Configure UI -
    private func configureInitialDesign() {
        fetchCoreDataMessages()
        registerCells()
        registerKeyboardNotifications()
        setupTapGesture()
        newChatsContainerStackView.isHidden = true
        sendMessageBt.isHidden = true
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.text = "Enter message"
        messageTextView.delegate = self
        messageTextContainerView.layer.borderColor = UIColor(resource: .main).cgColor
        messageTextContainerView.layer.cornerRadius = 24
        messageTextContainerView.layer.borderWidth = 0.5
        messageTextContainerView.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    private func setupTapGesture() {
        let tapGestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGestureKeyboard)
        
        let tapGestureNewChat = UITapGestureRecognizer(target: self, action: #selector(newChatAction))
        newChatStackView.addGestureRecognizer(tapGestureNewChat)
        
        
        let tapGesturePreviousChat = UITapGestureRecognizer(target: self, action: #selector(gotToPreviousChatAction))
        previousChatStackView.addGestureRecognizer(tapGesturePreviousChat)
        
    }
    
    private func registerCells() {
        tableView.register(.init(nibName: "SenderTextCell", bundle: Bundle.module),forCellReuseIdentifier: "SenderTextCell")
        tableView.register(.init(nibName: "ReceiverTextCell", bundle: Bundle.module),forCellReuseIdentifier: "ReceiverTextCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func registerKeyboardNotifications() {
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       }
    
    
    private func fetchCoreDataMessages() {
        guard let id = roomId else {return}
        chatModel = self.storage.fetchMessages(roomId: id)
        tableView.reloadData()
    }
    

  
    @IBAction func sendMessageButton(_ sender: UIButton) {
        sendTextMessage()
    }
    
    
    @IBAction func recordButton(_ sender: UIButton) {
        sendRecord(sender)
    }
    
    
    @IBAction func moreButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            if sender.isSelected {
                self.newChatsContainerStackView.isHidden = false
            }else {
                self.newChatsContainerStackView.isHidden = true
            }
        }
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                self.bottomConstraint.constant = keyboardSize.height - self.view.safeAreaInsets.bottom
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc private func newChatAction() {
        
    }
    
    
    @objc private func gotToPreviousChatAction() {
        self.newChatsContainerStackView.isHidden = true
        self.view.removeFromSuperview()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//            guard let self = self else {return}
//            if let parentVC = parentViewController {
//                let destinationViewController = RoomsView()
//                destinationViewController.modalPresentationStyle = .fullScreen
//                parentVC.present(destinationViewController, animated: true, completion: nil)
//            } else {
//                print("Parent view controller not found")
//            }
//        }
    }
    
    
}

//MARK: - TableView Delegate & DataSource -
extension ChatView: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatModel.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chatModel[indexPath.row].message?.role == "User" {
            if let senderCell = tableView.dequeueReusableCell(withIdentifier: "SenderTextCell", for: indexPath) as? SenderTextCell {
                senderCell.configureCell(model: chatModel[indexPath.row])
                return senderCell
            }
        }else {
            if let receiverCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverTextCell", for: indexPath) as? ReceiverTextCell {
                receiverCell.configureCell(model: chatModel[indexPath.row])
                receiverCell.dropDownMenueClosure = { [weak self] in
                    guard let _ = self else {return}
//                    if let parentVC = parentViewController {
//                        let destinationViewController = EditOnMessagesController()
//                        destinationViewController.delegate = self
//                        parentVC.present(destinationViewController, animated: true, completion: nil)
//                    } else {
//                        print("Parent view controller not found")
//                    }
                }
                return receiverCell
            }
        }
//        
//        if indexPath.row % 2 == 0 {
//            if let senderCell = tableView.dequeueReusableCell(withIdentifier: "SenderTextCell", for: indexPath) as? SenderTextCell {
//                senderCell.configureCell(model: chatModel[indexPath.row])
//                return senderCell
//            }
//        }else {
//            if let receiverCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverTextCell", for: indexPath) as? ReceiverTextCell {
//                receiverCell.configureCell(model: chatModel[indexPath.row])
//                receiverCell.dropDownMenueClosure = { [weak self] in
//                    guard let _ = self else {return}
////                    if let parentVC = parentViewController {
////                        let destinationViewController = EditOnMessagesController()
////                        destinationViewController.delegate = self
////                        parentVC.present(destinationViewController, animated: true, completion: nil)
////                    } else {
////                        print("Parent view controller not found")
////                    }
//                }
//                return receiverCell
//            }
//        }
        return UITableViewCell()
    }
}

//MARK: - Handle Actions -
extension ChatView {
    
    private func sendTextMessage() {
        
        guard let id = roomId else {return}
        
        if let message = messageTextView.text {
            let sentMessage = ChatMessage(role: "User", content: message)
//            self.chatModel.append(Choice(index: nil, message: sentMessage, logprobs: "", finishReason: ""))
            self.chatModel.insert(Choice(index: 0, message: sentMessage, logprobs: "", finishReason: ""), at: 0)
            self.storage.saveMessages(message, id)
        }
        
        request.sendChatRequest(prompt: messageTextView.text, apiKey: apiKey ?? "") { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    // Handle the response from ChatGPT
                    if let responseContent = success.choices?.first?.message?.content {
                        let chatGPTMessage = ChatMessage(role: "ChatGPt", content: responseContent)
//                        self.chatModel.append(Choice(index: nil, message: chatGPTMessage, logprobs: nil, finishReason: nil))
                        self.chatModel.insert(Choice(index: 0, message: chatGPTMessage, logprobs: "", finishReason: ""), at: 0)
                        self.storage.saveMessages(responseContent, id)
                    }
                    self.tableView.reloadData()
                    self.sendMessageBt.isHidden = true
                    self.textHeight.constant = 40
                    self.messageTextView.text = ""
                    self.tableView.scrollToTop()
                case .failure(let failure):
                    print("Error: \(failure)")
                }
            }
        }
    }
    
    private func sendRecord(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            Task{
                if await checkForPermissions() {
                    switch AVAudioSession.sharedInstance().recordPermission {
                    case .granted:
                        let popOver = RecordView()
                        
                        popOver.preferredContentSize = CGSize(width: 250, height: 60)
                        popOver.modalPresentationStyle = .popover
                        popOver.voiceNoteDelegate = self
                        if let popOverPresentaion = popOver.popoverPresentationController {
                            popOverPresentaion.permittedArrowDirections = .down
                            popOverPresentaion.sourceView = sender
                            popOverPresentaion.sourceRect = sender.bounds
                            popOverPresentaion.delegate = self
//                            if let parentVC = parentViewController {
//                                parentVC.present(popOver, animated: true, completion: nil)
//                            } else {
//                                print("Parent view controller not found")
//                            }
                        }
                        break
                        
                    default:
                        
                        let alert = UIAlertController(title: "", message: "noRecordPermission", preferredStyle: .alert)
                        let settingsAction = UIAlertAction(title: "settings", style: .default) { _ in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                        }
                        let cancelAction = UIAlertAction(title: "cancel", style: .default, handler: nil)
                        alert.addAction(settingsAction)
                        alert.addAction(cancelAction)
//                        if let parentVC = parentViewController {
//                            parentVC.present(alert, animated: true, completion: nil)
//                        } else {
//                            print("Parent view controller not found")
//                        }
                    }
                    
                }else {
                    presentPermissionAlert()
                }
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

//MARK: - Networking -
extension ChatView: EditOnMessageAction {
    
    func editMessage(message: String) {
        self.chatModel.append(Choice(index: 0, message: ChatMessage(role: "", content: message), logprobs: "", finishReason: ""))
        request.sendChatRequest(prompt: messageTextView.text, apiKey: apiKey ?? "") { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.chatModel.append(Choice(index: 0, message: ChatMessage(role: "", content: success.choices?.first?.message?.content ?? ""), logprobs: "", finishReason: ""))
                    self.tableView.reloadData()
                case .failure(let failure):
                    print("Error: \(failure)")
                }
            }
        }
    }
}

//MARK: - Networking -
extension ChatView: VoiceNoteDelegate {
    func updateWithVoiceNote(record: Data, duration: Double) {
        request.sendAudioFileToOpenAI(audioData: record, model: "whisper-1", apiKey: apiKey ?? "") { result in
            switch result {
            case .success(let transcriptionResponse):
                // Handle success
                print("Transcription Response: \(transcriptionResponse)")
            case .failure(let error):
                // Handle failure
                print("Error: \(error)")
            }
        }
    }
    
    
}
