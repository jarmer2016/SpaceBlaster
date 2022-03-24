//
//  StartMenuViewController.swift
//  Space Blaster
//
//  Created by James Armer on 25/10/2020.
//

import Foundation
import UIKit
import AVFoundation


class StartMenuVC: UIViewController {

    let buttonSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "RestartButtonClickSound", ofType: "m4a")!)   //assigning sound effect path to buttonSound
    var audioPlayer = AVAudioPlayer()           //assigning AV Foundations Audio Player to audioPlayer
    
    @IBOutlet weak var PlayGameButton: UIButton!                //created an Interface Builder Outlet so that we can adjust the play game button
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
        PlayGameButton.layer.cornerRadius = 10
        PlayGameButton.layer.borderWidth = 1
        PlayGameButton.layer.borderColor = UIColor.white.cgColor
    
    }
    
    
    
    @IBAction func PlayGameButtonTap(_ sender: Any) {           //created an Interface Builder Action so that we can run code when the button is tapped
        
        
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: buttonSound as URL)          //try to play buttonClickSound
                 audioPlayer.play()
            }
            catch{
                print("Failed to play button sound on main menu")                       //print this is failed to play sound
                
                
    }
    
}
}
