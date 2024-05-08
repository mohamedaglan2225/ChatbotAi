//
//  SoundPlayer.swift
//  Designers
//
//  Created by Mohamed Aglan on 3/21/24.
//

import Foundation
import AVFoundation

public class SoundPlayer {
    
    //MARK: - Enums-
    enum Status {
        case playing
        case pause
    }
    
    //MARK: - Initializer -
    private init() {}
    
    //MARK: - Singleton Properties -
    static let shared = SoundPlayer()
    
    //MARK: - Properties -
    private var _player: AVPlayer?
    private var _lastURL: URL?
    private var _lastOnSuccess: ((_ status: SoundPlayer.Status)->())?
    private var _currentStatus: Status = .pause
    private var _timeObserverToken: Any?
    
    //MARK: - Logic -
    func play(
        url: URL,
        at time: Double,
        onSuccess: @escaping (_ status: SoundPlayer.Status)->(),
        onProgress: @escaping (_ progress: Double)->()
    ) {
        guard self._lastURL != url else {
            switch self._currentStatus {
            case .playing:
                self._player?.pause()
                self._currentStatus = .pause
                onSuccess(.pause)
                onProgress(self._player?.currentTime().seconds ?? 0)
            case .pause:
                self._player?.play()
                self._currentStatus = .playing
                onSuccess(.playing)
            }
            return
        }
        self._lastOnSuccess?(.pause)
        self._lastURL = url
        self._lastOnSuccess = onSuccess
        self._player?.pause()
        if let timeObserverToken = self._timeObserverToken {
            self._player?.removeTimeObserver(timeObserverToken)
            self._timeObserverToken = nil
        }
        self._player = nil
        self._player = AVPlayer(url: url)
        self._player?.play()
        self.seek(url: url, to: time)
        self._currentStatus = .playing
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self._player?.currentItem)
        let interval = CMTime(
            seconds: 0.5,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
        self._timeObserverToken = self._player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { _ in
            if let seconds = self._player?.currentTime().seconds {
                onProgress(seconds)
            }
        }
        onSuccess(.playing)
    }
    
    func seek(url: URL, to seconds: Double) {
        guard self._lastURL == url else {return}
        let time = CMTime(seconds: seconds, preferredTimescale: 60000)
        self._player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func pause(url: URL) {
        guard url == self._lastURL else {return}
        self._player?.pause()
        self._currentStatus = .pause
        self._lastOnSuccess?(.pause)
    }
    
    func stop() {
        self._player?.pause()
        self._currentStatus = .pause
        self._lastOnSuccess?(.pause)
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification){
        self._player?.seek(to: CMTime.zero)
        self._player?.pause()
        self._lastOnSuccess?(.pause)
        self._lastOnSuccess = nil
    }
    
}

class SoundItem {
    
    enum Status {
        case notReady
        case downloading
        case ready
    }
    
    private(set) var currentStatus: Status = .notReady
    private var _currentTime: Double = 0
    
    private var _currentFrame: CGRect?
    var currentFrame: CGRect? {
        get {
            return self._currentFrame
        }
        set {
            self._currentFrame = newValue
        }
    }
    
    var soundWaveformImageData: Data?
    
    init(audioFileRemoteURL: URL) {
        self.handle(remoteURL: audioFileRemoteURL)
    }
    
    var currentTime: Double {
        get {
            return self._currentTime
        }
        set {
            if newValue >= 0 {
                self._currentTime = newValue
            } else {
                self._currentTime = 0
            }
        }
    }
    
    private var _audioFileLocalURL: URL? {
        didSet {
            self.currentStatus = .ready
            self.onSoundLocalURLSet?(.ready)
        }
    }
    
    var onSoundLocalURLSet: ((_ status: SoundItem.Status)->())?
    
    
    private func handle(remoteURL: URL) {
        self.onSoundLocalURLSet?(.downloading)
        let task = URLSession.shared.downloadTask(with: remoteURL) { [weak self] downloadedURL, urlResponse, error in
            
            guard let self = self else {return}
            guard let downloadedURL = downloadedURL else { return }
            let cachesFolderURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let audioFileURL = cachesFolderURL!.appendingPathComponent("audio-\(UUID()).mp3")
            try? FileManager.default.copyItem(at: downloadedURL, to: audioFileURL)
            DispatchQueue.main.async {
                self._audioFileLocalURL = audioFileURL
                self.onSoundLocalURLSet?(.ready)
            }
        }
        task.resume()
    }
    
    func getLocalURL() -> URL? {
        return self._audioFileLocalURL
    }
    
    
}
