//
//  customDosageTimeVC.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/26/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class customDosageTimeVC: UIViewController {
    var receivingDate : Date? = nil
    var receivingIndex : Int = 0
    
    var nameTF : String = ""
    var doseTF : String = ""
    var isRepeats : Bool = true
    var startDate : Date = Date()
    var endDate : Date = Date()
    var dailyEnabled : Bool = false
    var weeklyEnabled : Bool = false
    var monthlyEnabled : Bool = false
    var customEnabled : Bool = false
    var dosesPerDayCounter : Int = 0
    var morningChecked : Bool = false
    var afternoonChecked : Bool = false
    var eveningChecked : Bool = false
    var fourthChecked : Bool = false
    var fifthChecked : Bool = false
    var sixthChecked : Bool = false
    var isYellow : Bool = false
    var isOrange : Bool = false
    var isRed : Bool = false
    var isBlue : Bool = false
    var isGreen : Bool = false
    
    var isCanceled : Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        doseLabel.text = getDoseNumberString()
        customTimeOutlet.setDate(receivingDate!, animated: true)
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var customTimeOutlet: UIDatePicker!
    
    @IBOutlet weak var doseLabel: UILabel!
    
    func getDoseNumberString() -> String {
        if receivingIndex == 0 {
            return "First Dose"
        } else if receivingIndex == 1 {
            return "Second Dose"
        } else if receivingIndex == 2 {
            return "Third Dose"
        } else if receivingIndex == 3 {
            return "Fourth Dose"
        } else if receivingIndex == 4 {
            return "Fifth Dose"
        } else {
            return "Sixth Dose"
        }
    }
    @IBAction func setCustomTime(_ sender: UIButton) {
        performSegue(withIdentifier: "backFromSettingDoseSegue", sender: self)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "backFromSettingDoseSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNavVC = segue.destination as! UINavigationController
        let destinationVC = destNavVC.topViewController as! AddPrescriptionVC
        destinationVC.initializeDates()
        if(!isCanceled) {
            destinationVC.allDosageTimes[receivingIndex] = customTimeOutlet.date
        }
        
        
        // Re-set all previous values
        destinationVC.receivingName = nameTF
        destinationVC.receivingDose = doseTF
        destinationVC.isRepeats = isRepeats
        destinationVC.receivingStartDate = startDate
        destinationVC.receivingEndDate = endDate
        destinationVC.dailyEnabled = dailyEnabled
        destinationVC.weeklyEnabled = weeklyEnabled
        destinationVC.monthlyEnabled = monthlyEnabled
        destinationVC.customEnabled = customEnabled
        destinationVC.dosesPerDayCounter = dosesPerDayCounter
        destinationVC.morningChecked = morningChecked
        destinationVC.afternoonChecked = afternoonChecked
        destinationVC.eveningChecked = eveningChecked
        destinationVC.fourthChecked = fourthChecked
        destinationVC.fifthChecked = fifthChecked
        destinationVC.sixthChecked = sixthChecked
        destinationVC.isYellow = isYellow
        destinationVC.isOrange = isOrange
        destinationVC.isRed = isRed
        destinationVC.isBlue = isBlue
        destinationVC.isGreen = isGreen
    }

}
