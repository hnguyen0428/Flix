//
//  SettingsViewController.swift
//  Flix
//
//  Created by Hoang on 2/12/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var adultContentSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
    }
    
    func loadSettings() {
        let includeAdult = UserDefaults.standard.object(forKey: "include_adult") as? String
        if let str = includeAdult {
            if str == "true" {
                adultContentSwitch.isOn = true
            }
            else {
                adultContentSwitch.isOn = false
            }
        }
    }
    
    
    @IBAction func toggledSwitch(_ sender: UISwitch) {
        let switchState = sender.isOn ? "true" : "false"
        UserDefaults.standard.set(switchState, forKey: "include_adult")
        UserDefaults.standard.synchronize()
    }
    
}
