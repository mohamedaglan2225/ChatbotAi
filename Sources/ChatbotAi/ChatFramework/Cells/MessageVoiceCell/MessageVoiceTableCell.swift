//
//  MessageVoiceTableCell.swift
//  Student
//
//  Created by Saad Sherif on 29/05/2023.
//

import UIKit
import AVFoundation

class MessageVoiceTableCell: UITableViewCell {

    // MARK: - IBOutlets -
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var voiceSlider: UISlider!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var mainVStackView: UIStackView!
    @IBOutlet private weak var mainHStackView: UIStackView!
    @IBOutlet private weak var voiceStackView: UIStackView!
    
    
    //MARK: - Properties -
    private var message: Message?
    
    
    // MARK: - Life Cycle -
    override func awakeFromNib() {
        super.awakeFromNib()
        transform = CGAffineTransform(scaleX: 1, y: -1)
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        durationLabel.text = ""
        self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    
    // MARK: - Configuration -
    func configure(message: Message, isSender: Bool) {
        self.message = message
        isSender ? configureMyCell() : configureOtherCell()
    }
    
    func configuration(message: Message, isSender: Bool) {
        self.message = message
        isSender ? configureMyCell() : configureOtherCell()
        updateUIForAudio(message: message)
    }
    
    // MARK: - IBOutlets -
    @IBAction private func playButtonWasPressed(_ sender: UIButton) {
        guard let url = self.message?.soundItem?.getLocalURL() else {return}
        SoundPlayer.shared.play(url: url, at: self.message?.soundItem?.currentTime ?? 0) { [weak self] status in
            guard let self = self else {return}
            
            switch status {
            case .playing:
                self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            case .pause:
                self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        } onProgress: { [weak self] progress in
            guard let self else {return}
            voiceSlider.setValue(Float(progress/self.getDuration(from: url)), animated: true)
            message?.soundItem?.currentTime = progress

        }
    }
    
    @IBAction private func sliderDidChangeValue(_ sender: UISlider) {
        if let localURL = self.message?.soundItem?.getLocalURL() {
            let progress = self.voiceSlider.value
            let totalDuration = self.getDuration(from: localURL)
            let selectedDuration = Double(progress)*totalDuration
            SoundPlayer.shared.seek(url: localURL, to: selectedDuration)
            self.message?.soundItem?.currentTime = selectedDuration
        }
    }
}

// MARK: - Helper Funcitons -

extension MessageVoiceTableCell {
    
    private func updateUIForAudio(message: Message) {
        guard let soundItem = message.soundItem, let localURL = soundItem.getLocalURL() else { return }
        let totalDuration = getDuration(from: localURL)
        voiceSlider.maximumValue = Float(totalDuration)
        voiceSlider.value = Float(soundItem.currentTime ?? 0.0)
        durationLabel.text = durationToString(totalDuration)
    }
    
    private func configureMyCell() {
        mainVStackView.alignment = .leading
//        mainHStackView.semanticContentAttribute = !Language.isRTL() ? .forceLeftToRight : .forceRightToLeft
//        voiceStackView.semanticContentAttribute = !Language.isRTL() ? .forceLeftToRight : .forceRightToLeft
//        voiceSlider.semanticContentAttribute = !Language.isRTL() ? .forceLeftToRight : .forceRightToLeft
    }
    
    private func configureOtherCell() {
        mainVStackView.alignment = .trailing
//        mainHStackView.semanticContentAttribute = !Language.isRTL() ? .forceRightToLeft : .forceLeftToRight
//        voiceStackView.semanticContentAttribute = !Language.isRTL() ? .forceRightToLeft : .forceLeftToRight
//        voiceSlider.semanticContentAttribute = !Language.isRTL() ? .forceRightToLeft : .forceLeftToRight
    }
    
    func getDuration(from path: URL) -> Double {
        let asset = AVURLAsset(url: path)
        let duration: CMTime = asset.duration
        let totalSeconds = CMTimeGetSeconds(duration)
        return totalSeconds
    }
    
    private func durationToString(_ duration: Double) -> String {
        let recordDuration = (duration) / 1000.0
        let minutes = Int(recordDuration) / 60 % 60
        let seconds = Int(recordDuration) % 60
        return String(format: "%02i:%02i", minutes,seconds)
    }
}

// MARK: - Message -
struct Message: Codable {
    var id, isSender: Int?
    var body: String?
    var type: String?
    var duration: Int?
    var name: String?
    var createdDt: String?
    var soundItem: SoundItem?

    enum CodingKeys: String, CodingKey {
        case id
        case isSender = "is_sender"
        case body, type, duration, name
        case createdDt = "created_dt"
    }
}
