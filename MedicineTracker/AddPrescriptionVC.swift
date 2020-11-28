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
        // TIME ZONE IS GMT FOR THIS
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
    @IBOutlet weak var repeatDailyButton: UIButton!
    @IBOutlet weak var repeatWeeklyButton: UIButton!
    @IBOutlet weak var repeatMonthlyButton: UIButton!
    
    
    @IBOutlet weak var dosesPerDayLabel: UILabel!
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
    var isYellow : Bool = true
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
    
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //start date
        initializeDates()
        updateColorButtons() // Initialize the color
        repeatsSwitch.isOn = isRepeats
        nameTF.text = receivingName
        amountTF.text = receivingDose
        startDatePickerOutlet.date = receivingStartDate
        endDatePickerOutlet.date = receivingEndDate

        
        updateRepeatsSwitchComponents()
        updateDoseTimeButtons()
        
        
        /* TODO: Remove the below
         
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
        } */
        
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
    
    func updateRepeatsSwitchComponents() {
        if(repeatsSwitch.isOn) {
            endDatePickerOutlet.isEnabled = true
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
            endDatePickerOutlet.isEnabled = false
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
    
    // MARK: Repeats Switch
    @IBAction func pressRepeatsSwitch(_ sender: UISwitch) {
        if(sender.isOn) {
            endDatePickerOutlet.isEnabled = true
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
            endDatePickerOutlet.isEnabled = false
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
    
    @IBAction func notificationButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "add2notification", sender: self)
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
    
    @IBAction func morningTimeButton(_ sender: UIButton) {
        if(morningChecked) {
            morningChecked = false
            dosesPerDayCounter -= 1
        } else {
            morningChecked = true
            dosesPerDayCounter += 1
        }
        updateDoseTimeButtons()
    }
    
    
    @IBAction func afternoonTimeButton(_ sender: UIButton) {
        if(afternoonChecked) {
            afternoonChecked = false
            dosesPerDayCounter -= 1
        } else {
            afternoonChecked = true
            dosesPerDayCounter += 1
        }
        updateDoseTimeButtons()
    }
    
    
    @IBAction func eveningTimeButton(_ sender: UIButton) {
        if(eveningChecked) {
            eveningChecked = false
            dosesPerDayCounter -= 1
        } else {
            eveningChecked = true
            dosesPerDayCounter += 1
            
        }
        updateDoseTimeButtons()
    }
    
    
    @IBAction func fourthTimeButton(_ sender: UIButton) {
        if(fourthChecked) {
            fourthChecked = false
            dosesPerDayCounter -= 1
        } else {
            fourthChecked = true
            dosesPerDayCounter += 1
        }
        updateDoseTimeButtons()
        
    }
    
    @IBAction func fifthTimeButton(_ sender: UIButton) {
        if(fifthChecked) {
            fifthChecked = false
            dosesPerDayCounter -= 1
        } else {
            fifthChecked = true
            dosesPerDayCounter += 1
        }
        updateDoseTimeButtons()
        
    }
    
    
    @IBAction func sixthTimeButton(_ sender: UIButton) {
        if(sixthChecked) {
            sixthChecked = false
            dosesPerDayCounter -= 1
        } else {
            sixthChecked = true
            dosesPerDayCounter += 1
        }
        updateDoseTimeButtons()
        
    }
    
    // MARK: updateDoseTimeButtons
    func updateDoseTimeButtons() { // Changes the colors and text of the buttons depending on selected/checked value
        let times : [String] = [
            getTimeAsStringAMPM(date: allDosageTimes[0]),
            getTimeAsStringAMPM(date: allDosageTimes[1]),
            getTimeAsStringAMPM(date: allDosageTimes[2]),
            getTimeAsStringAMPM(date: allDosageTimes[3]),
            getTimeAsStringAMPM(date: allDosageTimes[4]),
            getTimeAsStringAMPM(date: allDosageTimes[5]),
        
        ]
        
        if(morningChecked) {
            morningTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            morningTimeButtonOutlet.setTitle(times[0]+" ✓", for: .normal)
            
            
        } else {
            morningTimeButtonOutlet.backgroundColor = UIColor.systemBlue
            morningTimeButtonOutlet.setTitle(times[0], for: .normal)
            
        }
        
        if(afternoonChecked) {
            afternoonTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            afternoonTimeButtonOutlet.setTitle(times[1]+" ✓", for: .normal)
            
        } else {
            afternoonTimeButtonOutlet.backgroundColor = UIColor.systemBlue
            afternoonTimeButtonOutlet.setTitle(times[1], for: .normal)
        }
        
        if(eveningChecked) {
            eveningTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            eveningTimeButtonOutlet.setTitle(times[2]+" ✓", for: .normal)
            
        } else {
            eveningTimeButtonOutlet.backgroundColor = UIColor.systemBlue
            eveningTimeButtonOutlet.setTitle(times[2], for: .normal)
            
        }
        
        if(fourthChecked) {
            fourthTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            fourthTimeButtonOutlet.setTitle(times[3]+" ✓", for: .normal)
            
        } else {
            fourthTimeButtonOutlet.backgroundColor = UIColor.systemBlue
            fourthTimeButtonOutlet.setTitle(times[3], for: .normal)
            
        }
        
        if(fifthChecked) {
            fifthTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            fifthTimeButtonOutlet.setTitle(times[4]+" ✓", for: .normal)
            
        } else {
            fifthTimeButtonOutlet.backgroundColor = UIColor.systemBlue
            fifthTimeButtonOutlet.setTitle(times[4], for: .normal)
            
        }
        
        if(sixthChecked) {
            sixthTimeButtonOutlet.backgroundColor = UIColor.customLightBlue
            sixthTimeButtonOutlet.setTitle(times[5]+" ✓", for: .normal)
            
        } else {
            sixthTimeButtonOutlet.backgroundColor = UIColor.systemBlue
            sixthTimeButtonOutlet.setTitle(times[5], for: .normal)
            
        }
        
        dosesPerDayLabel.text = String(dosesPerDayCounter) + " Doses per Day"
        
    }
    
    // MARK: Long Press Gestures
    @IBAction func firstLongPress(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            sentIndex = 0
            sentDate = allDosageTimes[sentIndex]
            performSegue(withIdentifier: "customDosageTimeSegue", sender: self)
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
            newPrescription.color = getSelectedColor()
            newPrescription.startDate = startDatePickerOutlet.date
            newPrescription.notificationType = false // Not alarm
            
            let calendar = Calendar.current
            let date = Date()
            let tmrw = date.addingTimeInterval(86400)
            let week = date.addingTimeInterval(604800)
            if (calendar.component(.day, from: date) == (calendar.component(.day, from: newPrescription.startDate!))){
                // is today
                newPrescription.whatDay = 0
            }else if(calendar.component(.day, from: newPrescription.startDate!) == (calendar.component(.day, from: tmrw))){
                    //is tmrw
                    newPrescription.whatDay = 1
            }else if(calendar.component(.day, from: newPrescription.startDate!)) < (calendar.component(.day, from: week)){
                    // is later this week
                        newPrescription.whatDay = 2
            }else{
                // LATER
                        newPrescription.whatDay = 3
        
            }
            
            if(repeatsSwitch.isOn) {
                newPrescription.endDate = endDatePickerOutlet.date
                newPrescription.frequency = getSelectedFrequency()
            }
            
            prescriptionArray!.append(newPrescription)
            // Save data
            do {
                try self.context.save()
            }
            catch {
                // TODO: Handle error
            }
            
            performSegue(withIdentifier: "backToPrescriptionsSegue", sender: self)
        } else {
            print("Form is not complete")
        }
        
    }
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verificationSegue" { //TODO: Remove this?
            let destinationVC = segue.destination as! VerifyBeforeAddingVC
            
            // Move data to the verification view in order to add it to the Prescriptions NS Context Object
            destinationVC.name = nameTF.text ?? "Prescription"
            //destinationVC.color =
            destinationVC.isRepeats = isRepeats
            //destinationVC.frequency =
            //destinationVC.dosageTimes =
            destinationVC.notes = noteTF.text ?? ""
            //destinationVC.notificationType =
            
        } else if segue.identifier == "backToPrescriptionsSegue" {
            let destTabVC = segue.destination as! UITabBarController
            let destNavVC = destTabVC.viewControllers![0] as! UINavigationController
            let destinationVC = destNavVC.topViewController as! MyPrescriptionsVC
            
            destinationVC.myPrescriptions = prescriptionArray
            
        } else if segue.identifier == "customDosageTimeSegue" {
            let destinationVC = segue.destination as! customDosageTimeVC
            destinationVC.receivingDate = sentDate
            destinationVC.receivingIndex = sentIndex
            
            destinationVC.nameTF = nameTF.text ?? ""
            destinationVC.doseTF = amountTF.text ?? ""
            destinationVC.isRepeats = isRepeats
            destinationVC.startDate = startDatePickerOutlet.date
            destinationVC.endDate = endDatePickerOutlet.date
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
    
    

}
