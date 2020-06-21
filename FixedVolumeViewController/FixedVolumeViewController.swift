//
//  FixedVolumeViewController.swift
//  FixedVolumeViewController
//
//  Created by r-kojima on 2020/02/10.
//  Copyright © 2020 r-kojima. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class FixedVolumeViewController: UIViewController {
    let volumeView = MPVolumeView(frame: .zero)
    
    let audioSession = AVAudioSession.sharedInstance()

    var audioPlayer: AVAudioPlayer?
    
    var savedVolume: Float = 0
    
    // MARK: - Lifecycle Events
    override func viewDidLoad() {
        super.viewDidLoad()
        settingVolumeView()
    }
    
    // MARK: - User Actions
    @IBAction func onTouchPlayButton(_ sender: UIButton) {
        self.playSound(forResource: "sample", ofType: "mp3", volume: 0.4)
    }
}

// MARK: - Audio Settings
extension FixedVolumeViewController {
    func settingVolumeView() {
        volumeView.setVolumeThumbImage(UIImage(), for: UIControl.State())
        volumeView.isUserInteractionEnabled = false
        volumeView.alpha = 0.0001
        self.view.addSubview(volumeView)
    }
    
    // デバイスの現在の音量を保存し、新しい値に書き換える
    func setVolume(volumeLevel: Float) {
        // 現在の音量を保存
        savedVolume = audioSession.outputVolume
        
        guard let slider = volumeView.subviews.compactMap({ $0 as? UISlider }).first else {
            print("Slider Not Found")
            return
        }
                
        slider.value = volumeLevel
    }
    
    //音量を元に戻す
    func resetVolume() {
        self.setVolume(volumeLevel: savedVolume)
    }
    
    // 音源の再生
    func playSound(forResource resource: String, ofType type: String = "mp3", volume: Float) {
        guard let path = Bundle.main.path(forResource: resource, ofType: type) else {
            print("Path Not Found")
            return
        }
        
        // 音量の設定
        setVolume(volumeLevel: volume)
        
        do {
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            // デリゲートの設定
            audioPlayer!.delegate = self
            // マナーモードでも音を鳴らすようにする
            try audioSession.setCategory(.playAndRecord)
//            // iPhoneのスピーカーから音を鳴らすよう設定（イヤホンをしていてもスピーカーから鳴る）
//            try audioSession.overrideOutputAudioPort(.speaker)
                
        } catch {
            print("Audio Setting Failed.")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.audioPlayer!.play() //再生
        }
    }
}

// MARK: - AVAudioPlayerDelegate プロトコルの実装
extension FixedVolumeViewController: AVAudioPlayerDelegate {
    // 音源の再生が終わった時に呼ばれる
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.resetVolume()
        // 音の出力先の設定を元に戻す
        do {
            try self.audioSession.overrideOutputAudioPort(.none)
        } catch {
            print("Failed to overrude outputAudioPort")
        }
    }
}


