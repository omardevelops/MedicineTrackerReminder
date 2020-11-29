//
//  EditViewController.swift
//  MedicineTracker
//
//  Created by Ali Alshamsi on 27/11/2020.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class EditPrescriptionVC: UIViewController {
    @IBOutlet weak var nameTF: UITextField!    
    @IBOutlet weak var doseTF: UITextField!
    @IBOutlet weak var yellowBG: UIButton!
    @IBOutlet weak var orangeBG: UIButton!    
    @IBOutlet weak var redBG: UIButton!
    @IBOutlet weak var blueBG: UIButton!
    @IBOutlet weak var greenBG: UIButton!
    @IBOutlet weak var repeatSwitch: UISwitch!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    
    @IBOutlet weak var repeatDailyButton: UIButton!
    @IBOutlet weak var repeatWeeklyButton: UIButton!
    @IBOutlet weak var repeatMonthlyButton: UIButton!
  
    @IBOutlet weak var frequencyInfoButton: UIButton!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var frequencyView: UIScrollView!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var dosePerDayLabel: UILabel!
    @IBOutlet weak var preset1Button: UIButton!
    @IBOutlet weak var preset2Button: UIButton!
    @IBOutlet weak var preset3Button: UIButton!
    @IBOutlet weak var preset4Button: UIButton!
    @IBOutlet weak var preset5Button: UIButton!
    @IBOutlet weak var preset6Button: UIButton!
    
    @IBOutlet weak var notesTF: UITextField!
    @IBOutlet weak var notificationsButton: UIButton!
    
    // MARK: View Variables
    private var startDatePicker : UIDatePicker?
    private var endDatePicker : UIDatePicker?
    var pillEnabled : Bool = false
    var drugEnabled : Bool = false
    var isRepeats : Bool = true
    var dailyEnabled : Bool = true
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
    
    var sentDate : Date? = nil
    var sentIndex : Int = 0
    var receivingName : String = ""
    var receivingDose : String = ""
    var receivingStartDate : Date = Date()
    var receivingEndDate : Date = Date()
    
    var isNotificationsSet : Bool = false
    var myPrescriptions : [Prescription]?
    var prescriptionIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTF.text = myPrescriptions![prescriptionIndex].name
        doseTF.text = myPrescriptions![prescriptionIndex].dose
        displayColorButtons()
        updateColorButtons()
        if myPrescriptions![prescriptionIndex].endDate == nil {
            repeatSwitch.setOn(false, animated: true)
        } else {
            repeatSwitch.setOn(true, animated: true)
        }
        //TODO: set start date and end date from core data
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editToPrescriptionsSegue", sender: self)
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editToViewSegue", sender: self)
    }
    
    
    @IBAction func yellowBG(_ sender: UIButton) {
        if isYellow {
            //isYellow = false
        } else {
            isYellow = true
            isOrange = false
            isRed = false
            isBlue = false
            isGreen = false
        }
        updateColorButtons()
    }
    @IBAction func orangeBG(_ sender: UIButton) {
        if isOrange {
            //isOrange = false
        } else {
            isOrange = true
            isYellow = false
            isRed = false
            isBlue = false
            isGreen = false
        }
        updateColorButtons()
    }
    @IBAction func redBG(_ sender: UIButton) {
        if(isRed) {
            //isRed = false
        } else {
            isRed = true
            isOrange = false
            isYellow = false
            isBlue = false
            isGreen = false
        }
        updateColorButtons()
    }
    @IBAction func blueBG(_ sender: UIButton) {
        if(isBlue) {
            //isBlue = false
        } else {
            isBlue = true
            isOrange = false
            isRed = false
            isYellow = false
            isGreen = false
        }
        updateColorButtons()
    }
    @IBAction func greenBG(_ sender: UIButton) {
        if(isGreen) {
            //isGreen = false
        } else {
            isGreen = true
            isOrange = false
            isRed = false
            isBlue = false
            isYellow = false
        }
        updateColorButtons()
    }

    @IBAction func repeatDailyButton(_ sender: UIButton) {
        if !dailyEnabled {
            dailyEnabled = true
            weeklyEnabled = false
            monthlyEnabled = false
        }
        updateFrequencyButtons()
    }
    
    @IBAction func repeatWeeklyButton(_ sender: UIButton) {
        if !weeklyEnabled {
            weeklyEnabled = true
            dailyEnabled = false
            monthlyEnabled = false
        }
        updateFrequencyButtons()
        
    }
    
    @IBAction func repeatMonthlyButton(_ sender: UIButton) {
        if !monthlyEnabled {
            monthlyEnabled = true
            dailyEnabled = false
            weeklyEnabled = false
        }
        updateFrequencyButtons()
    }
    
    
    @IBAction func repeatSwitch(_ sender: UISwitch) {
        if(sender.isOn) {
            endDate.isEnabled = true
            endDateLabel.isEnabled = true
            frequencyLabel.isEnabled = true
            frequencyInfoButton.isEnabled = true
            dailyEnabled = true
            updateFrequencyButtons()
            repeatWeeklyButton.backgroundColor = UIColor.systemBlue
            repeatMonthlyButton.backgroundColor = UIColor.systemBlue
            frequencyView.isUserInteractionEnabled = true
            isRepeats = true
            
        } else {
            endDate.isEnabled = false
            endDateLabel.isEnabled = false
            frequencyLabel.isEnabled = false
            frequencyInfoButton.isEnabled = false
            dailyEnabled = false
            weeklyEnabled = false
            monthlyEnabled = false
            updateFrequencyButtons()
            repeatDailyButton.backgroundColor = UIColor.systemGray
            repeatWeeklyButton.backgroundColor = UIColor.systemGray
            repeatMonthlyButton.backgroundColor = UIColor.systemGray
            
            frequencyView.isUserInteractionEnabled = false
            isRepeats = false
            
        }
    }
    
    func updateRepeatsSwitchComponents() {
        if(repeatSwitch.isOn) {
            endDate.isEnabled = true
            endDateLabel.isEnabled = true
            frequencyLabel.isEnabled = true
            frequencyInfoButton.isEnabled = true
            dailyEnabled = true
            updateFrequencyButtons()
            repeatWeeklyButton.backgroundColor = UIColor.systemBlue
            repeatMonthlyButton.backgroundColor = UIColor.systemBlue
            frequencyView.isUserInteractionEnabled = true
            isRepeats = true
            
        } else {
            endDate.isEnabled = false
            endDateLabel.isEnabled = false
            frequencyLabel.isEnabled = false
            frequencyInfoButton.isEnabled = false
            dailyEnabled = false
            weeklyEnabled = false
            monthlyEnabled = false
            updateFrequencyButtons()
            repeatDailyButton.backgroundColor = UIColor.systemGray
            repeatWeeklyButton.backgroundColor = UIColor.systemGray
            repeatMonthlyButton.backgroundColor = UIColor.systemGray
            
            frequencyView.isUserInteractionEnabled = false
            isRepeats = false
            
        }
    }
    
    func updateFrequencyButtons() {
        if dailyEnabled {
            repeatDailyButton.backgroundColor = UIColor.customLightBlue
            repeatDailyButton.setTitle("Daily ✓", for: .normal)
        } else {
            repeatDailyButton.backgroundColor = UIColor.systemBlue
            repeatDailyButton.setTitle("Daily", for: .normal)
        }
        
        if weeklyEnabled {
            repeatWeeklyButton.backgroundColor = UIColor.customLightBlue
            repeatWeeklyButton.setTitle("Weekly ✓", for: .normal)
        } else {
            repeatWeeklyButton.backgroundColor = UIColor.systemBlue
            repeatWeeklyButton.setTitle("Weekly", for: .normal)
        }
        
        if monthlyEnabled {
            repeatMonthlyButton.backgroundColor = UIColor.customLightBlue
            repeatMonthlyButton.setTitle("Monthly ✓", for: .normal)
        } else {
            repeatMonthlyButton.backgroundColor = UIColor.systemBlue
            repeatMonthlyButton.setTitle("Monthly", for: .normal)
        }
    }
    
    func displayColorButtons(){
        if myPrescriptions![prescriptionIndex].color == yellowBG.backgroundColor ?? UIColor.systemBlue {
            isYellow = true
        } else if myPrescriptions![prescriptionIndex].color == orangeBG.backgroundColor ?? UIColor.systemBlue {
            isOrange = true
        } else if myPrescriptions![prescriptionIndex].color == redBG.backgroundColor ?? UIColor.systemBlue {
            isRed = true
        } else if myPrescriptions![prescriptionIndex].color == blueBG.backgroundColor ?? UIColor.systemBlue {
            isBlue = true
        } else if myPrescriptions![prescriptionIndex].color == greenBG.backgroundColor ?? UIColor.systemBlue {
            isGreen = true
        }
    }
    
    func updateColorButtons() {
        if isYellow {
            yellowBG.setTitle("✓", for: .normal)
        } else {
            yellowBG.setTitle("", for: .normal)
            
        }
        
        if isOrange {
            orangeBG.setTitle("✓", for: .normal)
        } else {
            orangeBG.setTitle("", for: .normal)
        }
        
        if isRed {
            redBG.setTitle("✓", for: .normal)
        } else {
            redBG.setTitle("", for: .normal)
        }
        
        if isBlue {
            blueBG.setTitle("✓", for: .normal)
        } else {
            blueBG.setTitle("", for: .normal)
        }
        
        if isGreen {
            greenBG.setTitle("✓", for: .normal)
            
            
        } else {
            greenBG.setTitle("", for: .normal)
            
        }
    }
    
    func isColorPicked() -> Bool {
        if(isYellow || isOrange || isRed || isBlue || isGreen) {
            return true
        } else {
            return false
        }
    }
    
    func getSelectedColor() -> UIColor {
        if(isYellow) {
            return yellowBG.backgroundColor ?? UIColor.systemBlue
        } else if (isRed) {
            return redBG.backgroundColor ?? UIColor.systemBlue
        } else if (isOrange) {
            return orangeBG.backgroundColor ?? UIColor.systemBlue
        } else if (isBlue) {
            return blueBG.backgroundColor ?? UIColor.systemBlue
        } else {
            return greenBG.backgroundColor ?? UIColor.systemBlue
        }
    }
    
    func getSelectedFrequency() -> String {
        if dailyEnabled {
            return "Daily"
        } else if weeklyEnabled {
            return "Weekly"
        } else {
            return "Monthly"
        }
    }
    
    func isTimePicked() -> Bool {
        if(morningChecked || afternoonChecked || eveningChecked || fourthChecked || fifthChecked || sixthChecked) {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editToViewSegue" {
            let destinationVC = segue.destination as! ViewPrescriptionVC
            destinationVC.prescriptionIndex = self.prescriptionIndex
            destinationVC.myPrescriptions = self.myPrescriptions
            
        }
    }
    

}
