//
//  ViewController.swift
//  IOS-audio-player-exploration
//
//  Created by Charlotte Payne on 20/11/2019.
//  Copyright © 2019 Charlotte Payne. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    var isPlaying = false
    var timer: Timer!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var isPodcastPlaying = false
    var asset: AVAsset!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        trackTitle.text = "Future Islands - Tin Man"
        let path = Bundle.main.path(forResource: "Future Islands - Tin Man", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Can't load audio 🤯 ", error)
        }
        
        let series = "Podcast about politics"
        let episode = "Week 3 of election drama - December 2019"
        // Generate image artwork - don't want to do this on the main thread? Could be blocking on a slow network.
//        let imageUrl = URL(string: "http://live-wallpaper.net/iphone/img/app/i/p/iphone-4s-wallpapers-mobile-backgrounds-dark_2466f886de3472ef1fa968033f1da3e1_raw_1087fae1932cec8837695934b7eb1250_raw.jpg")
//        var err: Error?
//        var imageData: NSData = NSData.dataWithContentsOfURL(url, error: &err)
//        var bgImage = UIImage(data: imageData)
        
        self.prepareToPlay()
        self.setNowPlayingInfo(title: episode, show: series)
        self.setupRemoteTransportControls()
        
    }
    
    @objc func prepareToPlay() {
        guard let podcastUrl = URL(string: "https://stitcher.acast.com/livestitches/357679fe-f83a-4a36-9628-a2b49ddd2b29/567af75258700dc4d7db903653df6f12.mp3?aid=357679fe-f83a-4a36-9628-a2b49ddd2b29&chid=8e80ba05-2f15-4479-a6cc-b2f6635a1fe0&ci=dc925dea-16cb-4c5a-9faa-fc3f090af9f2&pf=rss&uid=ec3d110d853b28d2483f893f5d1aaece&Expires=1587339277&Signature=RWEM2fj8OhkWSkcZfcrfFLVOJM1ezjoyUUrk2AClt1kyaYG9JlS7Klp9fXSPsEJzffjGix4yV-iGZmWqq4OsxpmTi3WE3z1Ic6AieZJTIeaohdryS7OeXE5DxXAjvz3P5AHvakLtnUww70HdRv7TjY85FroYRVzqR%7EKwA0nZ8hTbhSR-RwjNhhPLToSD5Wl3tAda1EKUAhBoSrAtOwlREpfdb1KztS6NCX%7Ez4tA%7ENBDPzzN1WKAoEEwT5i6DZk8RCx1x33R5an%7EKcziviyUGPYbJwdvqsKpZoAJ9UiPP4lMPP40EOnMVyFZfQ1-Cg%7EYn7JHvbREACEl4LQe2-Y1uXg__&Key-Pair-Id=APKAJXAFARUOTJQ3BLOQ")
        
        else {
            return
        }
        
        asset = AVAsset(url: podcastUrl)
        
        let assetKeys = [
            "playable",
            "hasProtectedContent"
        ]
        
        playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
        
        // Capture all state changes to the item’s status
        playerItem.addObserver(self, forKeyPath: "status", options: [.old, .new], context: &playerItem)
        
        player = AVPlayer(playerItem: playerItem)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItem else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            print("Status ", status)
            // Switch over the status
            switch status {
                case .readyToPlay: break
                // Player item is ready to play.
                case .failed: break
                // Player item failed. See error.
                case .unknown: break
                    // Player item is not yet ready.
            }
        }
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.player.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    @objc func updateTime() {
        let currentTime = Int(audioPlayer.currentTime)
        let minutes = currentTime / 60
        let seconds = currentTime - minutes * 60
        
        playedTime.text = String(format: "%02d:%02d", minutes, seconds) as String
    }
    
    // Populate the nowPlayingInfo dictionary with as many relevant details about the audio
    @objc func setNowPlayingInfo(title: String, show: String) {
        var nowPlayingInfo = [String: Any]()
        
        // Show title:
        nowPlayingInfo[MPMediaItemPropertyPodcastTitle] = show
        // Individual episode title:
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        // Asynchronously downloaded show artwork:
        if let showArt = UIImage(named: "cover-art") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: showArt.size, requestHandler: { imageSize in
                return showArt
            })
        }
        
        // Get asset duration from AVPlayerItem's AVAsset
        // Warning - Duration is accurate only when AVPlayerItem.status == .readyToPlay.
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem.currentTime().seconds

        print("NOW PLAYING INFO: ", nowPlayingInfo)
        // Assign the dictionary to the MPNowPlayingInfoCenter singleton
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @IBOutlet weak var trackTitle: UILabel!
    
    @IBOutlet weak var playedTime: UILabel!
    
    @IBAction func playOrPauseMusic(_ sender: Any) {
        if isPlaying {
            audioPlayer.pause()
            isPlaying = false
        } else {
            audioPlayer.play()
            isPlaying = true
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }
    
    
    @IBAction func stopMusic(_ sender: Any) {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        isPlaying = false
    }
    
    
    @IBAction func playURL(_ sender: Any) {
        if isPodcastPlaying {
            self.player.pause()
            isPodcastPlaying = false
        } else {
            self.player.play()
            isPodcastPlaying = true
        }
        
    }
}

