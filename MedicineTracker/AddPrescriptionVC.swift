//
//  AddPrescriptionVC.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/12/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

extension UIColor {
    class var customLightBlue : UIColor {
        let x = 0x00C9FF
        return UIColor.rgb(fromHex: x)
    }
    class var customBlue : UIColor {
        let x = 0x008FFF
        return UIColor.rgb(fromHex: x)
    }
    
    class func rgb(fromHex: Int) -> UIColor {

        let red =   CGFloat((fromHex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((fromHex & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(fromHex & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

class AddPrescriptionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Core Data Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var prescriptionArray : [Prescription]?
    
    
    
    var allDosageTimes : [Date] = []
    var checkedDosageTimes : [Date] = [] // What is checked will be added to the prescription array
    
    func initializeDates() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateTime1 = Date(timeIntervalSinceReferenceDate: 28800.0) // 8AM
        let dateTime2 = Date(timeIntervalSinceReferenceDate: 43200.0) // 12PM
        let dateTime3 = Date(timeIntervalSinceReferenceDate: 64800.0) // 6PM
        let dateTime4 = Date(timeIntervalSinceReferenceDate: 75600.0) // 9PM
        let dateTime5 = Date(timeIntervalSinceReferenceDate: 86400.0) // 12AM
        let dateTime6 = Date(timeIntervalSinceReferenceDate: 10800.0) // 3AM
        
        allDosageTimes.append(dateTime1)
        allDosageTimes.append(dateTime2)
        allDosageTimes.append(dateTime3)
        allDosageTimes.append(dateTime4)
        allDosageTimes.append(dateTime5)
        allDosageTimes.append(dateTime6)
        
        print(allDosageTimes)
        
    }
    

    // MARK: Outlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var startDateTF: UITextField!
    @IBOutlet weak var endDateTF: UITextField!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePickerOutlet: UIDatePicker!
    @IBOutlet weak var startDatePickerOutlet: UIDatePicker!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var frequencyInfoButton: UIButton!
    @IBOutlet weak var frequencyView: UIView! // WARNING: This is also connected to its child ScrollView, be warned when editing this
    //@IBOutlet weak var categoryPillButton: UIButton!
    //@IBOutlet weak var categoryDrugButton: UIButton!
    @IBOutlet weak var repeatDailyButton: UIButton!
    @IBOutlet weak var repeatWeeklyButton: UIButton!
    @IBOutlet weak var repeatMonthlyButton: UIButton!
    @IBOutlet weak var morningTimeButtonOutlet: UIButton!
    @IBOutlet weak var afternoonTimeButtonOutlet: UIButton!
    @IBOutlet weak var eveningTimeButtonOutlet: UIButton!
    @IBOutlet weak var fourthTimeButtonOutlet: UIButton!
    @IBOutlet weak var fifthTimeButtonOutlet: UIButton!
    @IBOutlet weak var sixthTimeButtonOutlet: UIButton!
    
    @IBOutlet weak var repeatsSwitch: UISwitch!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var noteTF: UITextField!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var remindTF: UITextField!
    
    @IBOutlet weak var yellowBG: UIButton!
    @IBOutlet weak var blueBG: UIButton!
    @IBOutlet weak var greenBG: UIButton!
    @IBOutlet weak var redBG: UIButton!
    @IBOutlet weak var orangeBG: UIButton!
    
    // MARK: View Variables
    private var startDatePicker : UIDatePicker?
    private var endDatePicker : UIDatePicker?
    var pillEnabled : Bool = false
    var drugEnabled : Bool = false
    var isRepeats : Bool = true
    var dailyEnabled : Bool = false
    var weeklyEnabled : Bool = false
    var monthlyEnabled : Bool = false
    var customEnabled : Bool = false
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
    
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //start date
        initializeDates()
        
        startDatePicker = UIDatePicker()
        startDatePicker?.datePickerMode = .date
        startDatePicker?.addTarget(self, action: #selector(AddPrescriptionVC.startDateChanged(datePicker:)), for: .valueChanged)
        //end date
        endDatePicker = UIDatePicker()
        endDatePicker?.datePickerMode = .date
        endDatePicker?.addTarget(self, action: #selector(AddPrescriptionVC.endDateChanged(datePicker:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddPrescriptionVC.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        
        if startDateTF != nil {
           startDateTF.inputView = startDatePicker
        }
        if endDateTF != nil {
            endDateTF.inputView = endDatePicker
        }
        //remind me
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if remindTF != nil {
            remindTF.inputView = pickerView
            remindTF.textAlignment = .center
            remindTF.placeholder = "X minutes before"
        }
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func startDateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DD/MM/YYYY"
        startDateTF.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    @objc func endDateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DD/MM/YYYY"
        endDateTF.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    // MARK: Buttons Actions
    
    @IBAction func yellowBG(_ sender: UIButton) {
        if isYellow {
            isYellow = false
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
            isOrange = false
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
            isRed = false
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
            isBlue = false
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
            isGreen = false
        } else {
            isGreen = true
            isOrange = false
            isRed = false
            isBlue = false
            isYellow = false
        }
        updateColorButtons()
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
    
    @IBAction func pressRepeatsSwitch(_ sender: UISwitch) {
        if(sender.isOn) {
            endDatePickerOutlet.isEnabled = true
            endDateLabel.isEnabled = true
            frequencyLabel.isEnabled = true
            frequencyInfoButton.isEnabled = true
            frequencyView.isUserInteractionEnabled = true
            
            isRepeats = true
            
        } else {
            endDatePickerOutlet.isEnabled = false
            endDateLabel.isEnabled = false
            frequencyLabel.isEnabled = false
            frequencyInfoButton.isEnabled = false
            frequencyView.isUserInteractionEnabled = false
            
            isRepeats = false
            
        }
    }
    
    @IBAction func notificationButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "add2notification", sender: self)
    }
    
    /*
    @IBAction func categoryPillButton(_ sender: UIButton) {
        if pillEnabled == false{
            categoryPillButton.backgroundColor = UIColor.customLightBlue
            categoryPillButton.setTitle("Pill", for: .normal)
            pillEnabled = true
            categoryDrugButton.backgroundColor = UIColor.customBlue
            categoryDrugButton.setTitle("Drug ✓", for: .normal)
            drugEnabled = false
        }else {
            categoryPillButton.backgroundColor = UIColor.customBlue
            categoryPillButton.setTitle("Pill ✓", for: .normal)
            pillEnabled = false
            categoryDrugButton.backgroundColor = UIColor.customLightBlue
            categoryDrugButton.setTitle("Drug", for: .normal)
            drugEnabled = true
        }
    }
    
    @IBAction func categoryDrugButton(_ sender: UIButton) {
        if drugEnabled == false {
            categoryDrugButton.backgroundColor = UIColor.customLightBlue
            categoryDrugButton.setTitle("Drug", for: .normal)
            drugEnabled = true
            categoryPillButton.backgroundColor = UIColor.customBlue
            categoryPillButton.setTitle("Pill ✓", for: .normal)
            pillEnabled = false
        }else {
            categoryDrugButton.backgroundColor = UIColor.customBlue
            categoryDrugButton.setTitle("Drug ✓", for: .normal)
            drugEnabled = false
            categoryPillButton.backgroundColor = UIColor.customLightBlue
            categoryPillButton.setTitle("Pill", for: .normal)
            pillEnabled = true
        }
    }*/
    //repeat
    
    @IBAction func repeatDailyButton(_ sender: UIButton) {
        if dailyEnabled == false {
            repeatDailyButton.backgroundColor = UIColor.customLightBlue
            repeatDailyButton.setTitle("Daily", for: .normal)
            dailyEnabled = true
        }
    }
    @IBAction func repeatWeeklyButton(_ sender: UIButton) {
    }
    @IBAction func repeatMonthlyButton(_ sender: UIButton) {
    }
    
    @IBAction func morningTimeButton(_ sender: UIButton) {
        if(morningChecked) {
            morningChecked = false
        } else {
            morningChecked = true
        }
        updateDoseTimeButtons()
    }
    
    
    @IBAction func afternoonTimeButton(_ sender: UIButton) {
        if(afternoonChecked) {
            afternoonChecked = false
        } else {
            afternoonChecked = true
        }
        updateDoseTimeButtons()
    }
    
    
    @IBAction func eveningTimeButton(_ sender: UIButton) {
        if(eveningChecked) {
            eveningChecked = false
        } else {
            eveningChecked = true
        }
        updateDoseTimeButtons()
    }
    
    
    @IBAction func fourthTimeButton(_ sender: UIButton) {
        if(fourthChecked) {
            fourthChecked = false
        } else {
            fourthChecked = true
        }
        updateDoseTimeButtons()
        
    }
    
    @IBAction func fifthTimeButton(_ sender: UIButton) {
        if(fifthChecked) {
            fifthChecked = false
        } else {
            fifthChecked = true
        }
        updateDoseTimeButtons()
        
    }
    
    
    @IBAction func sixthTimeButton(_ sender: UIButton) {
        if(sixthChecked) {
            sixthChecked = false
        } else {
            sixthChecked = true
        }
        updateDoseTimeButtons()
        
    }
    
    // MARK: updateDoseTimeButtons
    func updateDoseTimeButtons() { // Changes the colors and text of the buttons depending on selected/checked value
        
        if(morningChecked) {
            morningTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            morningTimeButtonOutlet.setTitle("Morning ✓", for: .normal)
            
            
        } else {
            morningTimeButtonOutlet.backgroundColor = UIColor.customBlue
            morningTimeButtonOutlet.setTitle("Morning", for: .normal)
            
        }
        
        if(afternoonChecked) {
            afternoonTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            afternoonTimeButtonOutlet.setTitle("Afternoon ✓", for: .normal)
            
        } else {
            afternoonTimeButtonOutlet.backgroundColor = UIColor.customBlue
            afternoonTimeButtonOutlet.setTitle("Afternoon", for: .normal)
        }
        
        if(eveningChecked) {
            eveningTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            eveningTimeButtonOutlet.setTitle("Evening ✓", for: .normal)
            
        } else {
            eveningTimeButtonOutlet.backgroundColor = UIColor.customBlue
            eveningTimeButtonOutlet.setTitle("Evening", for: .normal)
            
        }
        
        if(fourthChecked) {
            fourthTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            fourthTimeButtonOutlet.setTitle("Evening ✓", for: .normal)
            
        } else {
            fourthTimeButtonOutlet.backgroundColor = UIColor.customBlue
            fourthTimeButtonOutlet.setTitle("Evening", for: .normal)
            
        }
        
        if(fifthChecked) {
            fifthTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            fifthTimeButtonOutlet.setTitle("Evening ✓", for: .normal)
            
        } else {
            fifthTimeButtonOutlet.backgroundColor = UIColor.customBlue
            fifthTimeButtonOutlet.setTitle("Evening", for: .normal)
            
        }
        
        if(sixthChecked) {
            sixthTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            sixthTimeButtonOutlet.setTitle("Evening ✓", for: .normal)
            
        } else {
            sixthTimeButtonOutlet.backgroundColor = UIColor.customBlue
            sixthTimeButtonOutlet.setTitle("Evening", for: .normal)
            
        }
        
    }
    
    
    
    // MARK: Notification View
    //remind me
    let remind = ["1 minute before","2 minutes before","3 minutes before","4 minutes before","5 minutes before","6 minutes before","7 minutes before","8 minutes before","9 minutes before","10 minutes before","11 minutes before","12 minutes before","13 minutes before","14 minutes before","15 minutes before",]
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return remind.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return remind[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        remindTF.text = remind[row]
        remindTF.resignFirstResponder()
    }
    
    func isColorPicked() -> Bool {
        if(isYellow || isOrange || isRed || isBlue || isGreen) {
            return true
        } else {
            return false
        }
    }
    
    func isTimePicked() -> Bool {
        if(morningChecked || afternoonChecked || eveningChecked || fourthChecked || fifthChecked || sixthChecked) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Check Form
    // Checks if form is valid and ready to be used as a Prescription object. Checks if required fields are empty or not.
    func isFormValid() -> Bool {
        let startDate : Date = startDatePickerOutlet.date
        let endDate : Date
        let interval : TimeInterval
        if(nameTF.hasText && amountTF.hasText && isColorPicked() && isTimePicked()) {
            if(endDatePickerOutlet.isEnabled) {
                endDate = endDatePickerOutlet.date
                interval = endDate.timeIntervalSince(startDate)
                if(interval > 1) {
                    //TODO: Put alert to tell user that end date is before start date or same day
                    
                    return true
                } else {
                    print("End date invalid")
                    return false
                }
            } else {
                return true
            }
        } else {
            return false
        }
        
    }
    // latest push

    func addDoseTimesToArray() {
        if(morningChecked) {
            checkedDosageTimes.append(allDosageTimes[0])
        }
        
        if(afternoonChecked) {
            checkedDosageTimes.append(allDosageTimes[1])
        }
        
        if(eveningChecked) {
            checkedDosageTimes.append(allDosageTimes[2])
        }
        
        if(fourthChecked) {
            checkedDosageTimes.append(allDosageTimes[3])
        }
        
        if(fifthChecked) {
            checkedDosageTimes.append(allDosageTimes[4])
        }
        
        if(sixthChecked) {
            checkedDosageTimes.append(allDosageTimes[5])
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func nextButton(_ sender: UIBarButtonItem) {
        if(isFormValid()) {
            // Add Prescription to Core Data
            let newPrescription = Prescription(context: self.context)
            addDoseTimesToArray() // Adds what is checked to checkedDosageTimes
            print(checkedDosageTimes)
            newPrescription.name = nameTF.text
            newPrescription.dose = amountTF.text!
            newPrescription.notes = noteTF.text
            newPrescription.doseTimings = checkedDosageTimes
            performSegue(withIdentifier: "verificationSegue", sender: self)
        } else {
            print("Nope")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "verificationSegue") {
            let destinationVC = segue.destination as! VerifyBeforeAddingVC
            
            // Move data to the verification view in order to add it to the Prescriptions NS Context Object
            destinationVC.name = nameTF.text ?? "Prescription"
            //destinationVC.color =
            destinationVC.isRepeats = isRepeats
            //destinationVC.frequency =
            //destinationVC.dosageTimes =
            destinationVC.notes = noteTF.text ?? ""
            //destinationVC.notificationType =
            
        }
    }
    

}
