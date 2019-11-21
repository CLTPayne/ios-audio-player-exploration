//
//  ViewController.swift
//  IOS-audio-player-exploration
//
//  Created by Charlotte Payne on 20/11/2019.
//  Copyright © 2019 Charlotte Payne. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    var isPlaying = false
    var timer: Timer!
    var player: AVPlayer!

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
    }
    
    @objc func updateTime() {
        let currentTime = Int(audioPlayer.currentTime)
        let minutes = currentTime / 60
        let seconds = currentTime - minutes * 60
        
        playedTime.text = String(format: "%02d:%02d", minutes, seconds) as String
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
        guard let url = URL(string: "https://stitcher.acast.com/livestitches/357679fe-f83a-4a36-9628-a2b49ddd2b29/567af75258700dc4d7db903653df6f12.mp3?aid=357679fe-f83a-4a36-9628-a2b49ddd2b29&chid=8e80ba05-2f15-4479-a6cc-b2f6635a1fe0&ci=dc925dea-16cb-4c5a-9faa-fc3f090af9f2&pf=rss&uid=ec3d110d853b28d2483f893f5d1aaece&Expires=1587339277&Signature=RWEM2fj8OhkWSkcZfcrfFLVOJM1ezjoyUUrk2AClt1kyaYG9JlS7Klp9fXSPsEJzffjGix4yV-iGZmWqq4OsxpmTi3WE3z1Ic6AieZJTIeaohdryS7OeXE5DxXAjvz3P5AHvakLtnUww70HdRv7TjY85FroYRVzqR%7EKwA0nZ8hTbhSR-RwjNhhPLToSD5Wl3tAda1EKUAhBoSrAtOwlREpfdb1KztS6NCX%7Ez4tA%7ENBDPzzN1WKAoEEwT5i6DZk8RCx1x33R5an%7EKcziviyUGPYbJwdvqsKpZoAJ9UiPP4lMPP40EOnMVyFZfQ1-Cg%7EYn7JHvbREACEl4LQe2-Y1uXg__&Key-Pair-Id=APKAJXAFARUOTJQ3BLOQ")
        
        else {
                return
        }
        
        let player = AVPlayer(url: url)
        
        let controller = AVPlayerViewController()
        controller.player = player
    
        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
           player.play()
        }
    }
}

