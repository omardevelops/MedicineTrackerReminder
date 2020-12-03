//
//  SettingsVC.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/12/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, customTimeDelegate {
    
    // For customTime delegate
    func setCustomTime(time: Date) {
        let defaults = UserDefaults.standard
        defaultTimes![sentIndex!] = getTimeAsStringAMPM(date: time)
        defaults.setValue(defaultTimes, forKey: "Default dosage times")
        print("here in mainView")
    }

    // MARK: Outlets
    @IBOutlet weak var yourNameTF: UITextField!
    @IBOutlet weak var presetTime1: UIButton!
    @IBOutlet weak var presetTime2: UIButton!
    @IBOutlet weak var presetTime3: UIButton!
    @IBOutlet weak var presetTime4: UIButton!
    @IBOutlet weak var presetTime5: UIButton!
    @IBOutlet weak var presetTime6: UIButton!
    
    var defaultTimes : [String]? // Stores the default times and fetches them from NSUserDefaults
    
    var sentIndex : Int?
    var sentDate : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Fetch default timings from UserDefaults
        let defaults = UserDefaults.standard
        defaultTimes = defaults.array(forKey: "Default dosage times") as? [String]
        
        // Set name to the textfield
        yourNameTF.text = defaults.string(forKey: "username")
        
        // Set default timings to Views
        presetTime1.setTitle(defaultTimes![0], for: .normal)
        presetTime2.setTitle(defaultTimes![1], for: .normal)
        presetTime3.setTitle(defaultTimes![2], for: .normal)
        presetTime4.setTitle(defaultTimes![3], for: .normal)
        presetTime5.setTitle(defaultTimes![4], for: .normal)
        presetTime6.setTitle(defaultTimes![5], for: .normal)
    }
    
    
    
    @IBAction func changedNameTF(_ sender: UITextField) {
        let defaults = UserDefaults.standard
        defaults.setValue(yourNameTF.text, forKey: "username")
    }
    
    
    // MARK: Buttons Actions
    @IBAction func tapPresetTime1(_ sender: UIButton) {
        sentIndex = 0
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        print(defaultTimes![sentIndex!])
        let sentDateAsTiming = formatter.date(from: defaultTimes![sentIndex!])
        sentDate = sentDateAsTiming
        print(sentDate)
        performSegue(withIdentifier: "FromSettingsToSetTimeSegue", sender: self)
    }
    
    @IBAction func tapPresetTime2(_ sender: UIButton) {
        sentIndex = 1
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        print(defaultTimes![sentIndex!])
        let sentDateAsTiming = formatter.date(from: defaultTimes![sentIndex!])
        sentDate = sentDateAsTiming
        print(sentDate)
        performSegue(withIdentifier: "FromSettingsToSetTimeSegue", sender: self)
    }
    
    @IBAction func tapPresetTime3(_ sender: UIButton) {
        sentIndex = 2
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        print(defaultTimes![sentIndex!])
        let sentDateAsTiming = formatter.date(from: defaultTimes![sentIndex!])
        sentDate = sentDateAsTiming
        print(sentDate)
        performSegue(withIdentifier: "FromSettingsToSetTimeSegue", sender: self)
    }
    
    @IBAction func tapPresetTime4(_ sender: UIButton) {
        sentIndex = 3
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        print(defaultTimes![sentIndex!])
        let sentDateAsTiming = formatter.date(from: defaultTimes![sentIndex!])
        sentDate = sentDateAsTiming
        print(sentDate)
        performSegue(withIdentifier: "FromSettingsToSetTimeSegue", sender: self)
    }
    
    @IBAction func tapPresetTime5(_ sender: UIButton) {
        sentIndex = 4
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        print(defaultTimes![sentIndex!])
        let sentDateAsTiming = formatter.date(from: defaultTimes![sentIndex!])
        sentDate = sentDateAsTiming
        print(sentDate)
        performSegue(withIdentifier: "FromSettingsToSetTimeSegue", sender: self)
    }
    
    @IBAction func tapPresetTime6(_ sender: UIButton) {
        sentIndex = 5
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        print(defaultTimes![sentIndex!])
        let sentDateAsTiming = formatter.date(from: defaultTimes![sentIndex!])
        sentDate = sentDateAsTiming
        print(sentDate)
        performSegue(withIdentifier: "FromSettingsToSetTimeSegue", sender: self)
    }
    
    // MARK: Get Time As String
    func getTimeAsStringAMPM(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let hourString = formatter.string(from: date)
        
        return hourString
        // For example, 12:00 PM
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FromSettingsToSetTimeSegue" {
            let destinationVC = segue.destination as! customDosageTimeVC
            destinationVC.receivingDate = sentDate
            destinationVC.receivingIndex = sentIndex!
            destinationVC.delegate = self // To use customTime protocol to pass values between views
        }
    }

}
