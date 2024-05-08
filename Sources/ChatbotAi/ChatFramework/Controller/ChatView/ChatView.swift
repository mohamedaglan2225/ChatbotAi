//
//  ChatView.swift
//  
//
//  Created by Mohamed Aglan on 5/8/24.
//

import UIKit
import MobileCoreServices
import AVKit
import CoreData


public protocol ReusableViewDelegate: AnyObject {
    func didTapBackButton()
}

public class ChatView: UIView {

    //MARK: - IBOutLets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextContainerView: UIView!
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    @IBOutlet weak var sendMessageBt: UIButton!
    
    
    
    
    
    //MARK: - Properties -
    let XIB_NAME = "ChatView"
    private var request = Networking()
    private var chatModel: [Choice] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    public var apiKey: String?
    weak var delegate: ReusableViewDelegate?
    let timestamp = Date()
    var room: Room!
    
    private let storage: MessagesStorage = {
        DefaultMessageStorage(coreDataWrapper: ServiceLocator.storage)
    }()
    
    
    
    
    //MARK: - LifeCycle Events -
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
        let nib = UINib(nibName: XIB_NAME, bundle: Bundle.module)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(view)
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    
    //MARK: - Configure UI -
    private func configureInitialDesign() {
        fetchCoreDataMessages()
        registerCells()
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.delegate = self
        messageTextContainerView.layer.borderColor = UIColor.white.cgColor
        messageTextContainerView.layer.cornerRadius = 14
        messageTextContainerView.layer.borderWidth = 0.5
        messageTextContainerView.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    
    private func registerCells() {
        tableView.register(.init(nibName: "SenderTextCell", bundle: Bundle.module),forCellReuseIdentifier: "SenderTextCell")
        tableView.register(.init(nibName: "ReceiverTextCell", bundle: Bundle.module),forCellReuseIdentifier: "ReceiverTextCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    
    private func fetchCoreDataMessages() {
        do {
            self.chatModel = self.storage.fetchMessages()
        }catch {
            fatalError("Catched Error")
        }
    }
    
    
    
    //MARK: - IBActions -
    @IBAction func sendMessageButton(_ sender: UIButton) {
        sendTextMessage()
    }
    
    
    @IBAction func recordButton(_ sender: UIButton) {
        sendRecord(sender)
    }
    
    @IBAction func moreButton(_ sender: UIButton) {
//        if let parentVC = parentViewController {
//            let destinationViewController = OldChattingView()
//            parentVC.present(destinationViewController, animated: true, completion: nil)
//        } else {
//            print("Parent view controller not found")
//        }
    }
    
    
    
}


//MARK: - TableView Delegate & DataSource -
extension ChatView: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatModel.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            if let senderCell = tableView.dequeueReusableCell(withIdentifier: "SenderTextCell", for: indexPath) as? SenderTextCell {
                senderCell.configureCell(model: chatModel[indexPath.row])
                return senderCell
            }
        }else {
            if let receiverCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverTextCell", for: indexPath) as? ReceiverTextCell {
                receiverCell.configureCell(model: chatModel[indexPath.row])
                receiverCell.dropDownMenueClosure = { [weak self] in
                    guard let self = self else {return}
                    if let parentVC = parentViewController {
                        let destinationViewController = EditOnMessagesController()
                        destinationViewController.delegate = self
                        parentVC.present(destinationViewController, animated: true, completion: nil)
                    } else {
                        print("Parent view controller not found")
                    }
                }
                return receiverCell
            }
        }
        return UITableViewCell()
    }
}


//MARK: - Handle Actions -
extension ChatView {
    
    private func sendTextMessage() {
        self.chatModel.append(Choice(index: 0, message: ChatMessage(role: "", content: messageTextView.text ?? ""), logprobs: "", finishReason: ""))
        
        self.storage.saveMessages(messageTextView.text)
        
        request.sendChatRequest(prompt: messageTextView.text, apiKey: apiKey ?? "") { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    print("Response ID: \(success.id ?? "")")
                    print("Response Model: \(success.model ?? "")")
                    print("Response Content Message: \(success.choices?.first?.message?.content ?? "")")
                    
                    // Handle the response from ChatGPT
                    if let responseContent = success.choices?.first?.message?.content {
                        let chatGPTMessage = ChatMessage(role: "ChatGPt", content: responseContent)
                        self.chatModel.append(Choice(index: nil, message: chatGPTMessage, logprobs: nil, finishReason: nil))
                        self.storage.saveMessages(responseContent)
                    }
                    self.tableView.reloadData()
                case .failure(let failure):
                    print("Error: \(failure)")
                }
            }
        }
        
        textHeight.constant = 40
        messageTextView.text = ""
        tableView.scrollToTop()
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
                            if let parentVC = parentViewController {
                                parentVC.present(popOver, animated: true, completion: nil)
                            } else {
                                print("Parent view controller not found")
                            }
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
                        if let parentVC = parentViewController {
                            parentVC.present(alert, animated: true, completion: nil)
                        } else {
                            print("Parent view controller not found")
                        }
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
                    print("Response ID: \(success.id ?? "")")
                    print("Response Model: \(success.model ?? "")")
                    print("Response Content Message: \(success.choices?.first?.message?.content ?? "")")
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
