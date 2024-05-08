//
//  RecordView.swift
//  
//
//  Created by Mohamed Aglan on 4/20/24.
//


import UIKit
import AVFoundation

protocol VoiceNoteDelegate: AnyObject {
    func updateWithVoiceNote(record: Data,duration:Double)
}

class RecordView: UIViewController {

    @IBOutlet weak var recordDuration: UILabel!
    
    //MARK:- Varaibels Declaration
    lazy var timer = Timer()
    weak var voiceNoteDelegate:VoiceNoteDelegate?
    private var duration:Int = 1
    private var recorder:AVAudioRecorder!
    private var player:AVAudioPlayer!
    private var audioFileURL:URL!
    private let session = AVAudioSession.sharedInstance()
    private var isRecorded:Bool = true
    private var isAudioRecordingGranted: Bool = false {
        didSet {
            if self.isAudioRecordingGranted {
                self.startRecord()
            }
        }
    }
    

    //MARK:- viewDidLoad
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        checkRecordPermission()
    }
    
    
    public init() {
        super.init(nibName: "RecordView", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func calculateDuration(duration:Int)->String{
        self.duration += 1
        let hours = duration / 3600
        let minutes = (duration / 60) % 60
        let seconds = duration % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    

    //MARK:- Check Record Premission
    func checkRecordPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    //MARK:- Setup Session
    func setupSession(){
        do{
            try session.setActive(true)
            try session.setCategory(.playAndRecord)
            try session.overrideOutputAudioPort(.speaker)
        }catch let error{
            print("error in seting up session: \(error.localizedDescription)")
        }
    }
    
    //MARK:- Setup Recorder
    private func setupRecorder(){
        if isAudioRecordingGranted{
            setupSession()
            let recordSettings: [String: Any] =
                
                [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
            
            do {
                recorder = try AVAudioRecorder(url: getFileURL(), settings: recordSettings)
                recorder.delegate = self
                recorder.isMeteringEnabled = true
                recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
            } catch {
                recorder = nil
                print(error.localizedDescription)
            }
        }else {
            print("Don't have access to use your microphone.")
        }
        
    }
    
    //MARK:- Start Record
    private func startRecord(){
        setupRecorder()
        recorder.record()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.recordDuration.text = self.calculateDuration(duration: self.duration)
            print( self.calculateDuration(duration: self.duration))
        })
    }
    
    //MARK:- Stop Record
    private func stopRecord(){
        finishAudioRecording(success: true)
    }
    
    //MARK:- Setup Recorder
    func getFileURL() -> URL {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        print("🖍\(currentFileName)")
        let documentsDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectoryPath.appendingPathComponent(currentFileName)
        print("writing to soundfile url: '\(fileURL)'")
        if FileManager.default.fileExists(atPath: fileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(fileURL.absoluteString) exists")
        }
        return fileURL
    }
    
    func finishAudioRecording(success: Bool) {
        if success {
            self.recorder.stop()
            self.recorder = nil
            self.timer.invalidate()
            if isRecorded{
                print("recorded successfully.")
            }else{
                print("record canceled.")
            }
        } else {
            print("Recording failed.")
        }
    }
    
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        isRecorded = true
        stopRecord()
        dismiss(animated:true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        isRecorded = false
        stopRecord()
        dismiss(animated:true)
    }
    
}


//MARK:- AVAudio Recorder Delegate Methods
extension RecordView:AVAudioRecorderDelegate{
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard isRecorded else{return}
        if let recordData = try? Data(contentsOf: recorder.url){
            let asset = AVAsset(url: recorder.url)
            voiceNoteDelegate?.updateWithVoiceNote(record: recordData, duration: (asset.duration.seconds * 1000))
        }
    }
}
