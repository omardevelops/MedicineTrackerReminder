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

class AddPrescriptionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, customTimeDelegate {
    
    
    // For customTime delegate
    func setCustomTime(time: Date) {
        allDosageTimes[sentIndex] = time
        initializeDates()
        updateDoseTimeButtons()
        print("here in mainView")
    }
    
    
    // MARK: Core Data Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var prescriptionArray : [Prescription]?
    
    var newPrescription : Prescription?
    var myPrescriptions : [Prescription]?
    var prescriptionIndex = 0
    var notificationCount : Int?
    
    var allDosageTimes : [Date] = []
    var checkedDosageTimes : [Date] = [] // What is checked will be added to the prescription array
    
    let initialTimings = ["8:00 AM", "12:00 PM", "06:00 PM", "09:00 PM", "12:00 AM", "03:00 AM"]
    
    var initialDate : Date?
    
    
    func initializeDates() {
        // TIME ZONE IS GMT FOR THIS
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM y"
        let todayDateAsString = formatter.string(from: Date())
        formatter.dateFormat = "hh:mm a, dd MM y"
        

        for j in 0 ..< initialTimings.count {
            allDosageTimes.append(formatter.date(from: initialTimings[j] + ", " + todayDateAsString)!)
        }
        
        if isEditPage {
            print("Editing the dosage times")
            for i in 0 ..< myPrescriptions![prescriptionIndex].doseTimings!.count {
                allDosageTimes[i] = myPrescriptions![prescriptionIndex].doseTimings![i]
                switch(i) {
                case 0:
                    morningChecked = true
                    print("morning")
                    dosesPerDayCounter += 1
                    break;
                case 1:
                    afternoonChecked = true
                    dosesPerDayCounter += 1
                    break;
                case 2:
                    eveningChecked = true
                    dosesPerDayCounter += 1
                    break;
                case 3:
                    fourthChecked = true
                    dosesPerDayCounter += 1
                    break;
                case 4:
                    fifthChecked = true
                    dosesPerDayCounter += 1
                    break;
                case 5:
                    sixthChecked = true
                    dosesPerDayCounter += 1
                    break;
                default:
                    break
                    
                
                }
            }
        }
            
            /*
            let dateTime1 = formatter.date(from: initialTimings[0]+", "+todayDateAsString)
            let dateTime2 = formatter.date(from: initialTimings[1]+", "+todayDateAsString)
            let dateTime3 = formatter.date(from: initialTimings[2]+", "+todayDateAsString)
            let dateTime4 = formatter.date(from: initialTimings[3]+", "+todayDateAsString)
            let dateTime5 = formatter.date(from: initialTimings[4]+", "+todayDateAsString)
            let dateTime6 = formatter.date(from: initialTimings[5]+", "+todayDateAsString)
            /*let dateTime1 = Date(timeIntervalSinceNow: 28800.0) // 8AM
            let dateTime2 = Date(timeIntervalSinceNow: 43200.0) // 12PM
            let dateTime3 = Date(timeIntervalSinceNow: 64800.0) // 6PM
            let dateTime4 = Date(timeIntervalSinceNow: 75600.0) // 9PM
            let dateTime5 = Date(timeIntervalSinceNow: 86400.0) // 12AM
            let dateTime6 = Date(timeIntervalSinceNow: 10800.0) // 3AM*/
            
            allDosageTimes.append(dateTime1!)
            allDosageTimes.append(dateTime2!)
            allDosageTimes.append(dateTime3!)
            allDosageTimes.append(dateTime4!)
            allDosageTimes.append(dateTime5!)
            allDosageTimes.append(dateTime6!)
            
            print(allDosageTimes)*/
        
        
        
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
    
    @IBOutlet weak var navigatorBar: UINavigationItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
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
    var isEditPage : Bool = false
    
    var sentDate : Date? = nil
    var sentIndex : Int = 0
    var receivingName : String = ""
    var receivingDose : String = ""
    var receivingStartDate : Date = Date()
    var receivingEndDate : Date = Date()
    
    var isNotificationsSet : Bool = false
    
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itsEditPage()
    }
    // MARK: Loads Edit Page
    func itsEditPage() {
        if isEditPage {
            navigatorBar.title = "Edit Prescription"
            navigatorBar.rightBarButtonItem?.title = "Edit"
            navigatorBar.rightBarButtonItems = [nextButton, deleteButton]
            deleteButton.isEnabled = true
            deleteButton.tintColor = UIColor.red
            initialDate = startDatePickerOutlet.date
            //navigatorBar.rightBarButtonItem?.title
            nameTF.text = myPrescriptions![prescriptionIndex].name
            amountTF.text = myPrescriptions![prescriptionIndex].dose
            noteTF.text = myPrescriptions![prescriptionIndex].notes
            displayColorButtons()
            updateColorButtons()
            if myPrescriptions![prescriptionIndex].endDate == nil {
                repeatsSwitch.setOn(false, animated: true)
                updateRepeatsSwitchComponents()
            } else {
                repeatsSwitch.setOn(true, animated: true)
            }
            startDatePickerOutlet.date = myPrescriptions![prescriptionIndex].startDate!
            //endDatePickerOutlet.date = myPrescriptions![prescriptionIndex].endDate!, enddate not used anymore
            displayFrequency()
            updateFrequencyButtons()
            updateRepeatsSwitchComponents()
            
            
            //TODO: Choose dosage times from core data
            initializeDates()
            print(allDosageTimes)
            updateDoseTimeButtons()
        } else {
            navigatorBar.title = "Add Prescription"
            navigatorBar.rightBarButtonItem?.title = "Next"
            navigatorBar.rightBarButtonItems = [nextButton, deleteButton]
            deleteButton.isEnabled = false
            deleteButton.tintColor = UIColor.clear
            initialDate = startDatePickerOutlet.date
            initializeDates()
            updateColorButtons() // Initialize the color
            repeatsSwitch.isOn = isRepeats
            nameTF.text = receivingName
            amountTF.text = receivingDose
            startDatePickerOutlet.date = receivingStartDate
            endDatePickerOutlet.date = receivingEndDate

            
            updateRepeatsSwitchComponents()
            updateDoseTimeButtons()
            
            //remind me
            pickerView.delegate = self
            pickerView.dataSource = self
            
            if remindTF != nil {
                remindTF.inputView = pickerView
                remindTF.textAlignment = .center
                remindTF.placeholder = "X minutes before"
            }
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
            if !isEditPage  {
                dailyEnabled = true
            }
            repeatWeeklyButton.backgroundColor = UIColor.systemBlue
            repeatMonthlyButton.backgroundColor = UIColor.systemBlue
            frequencyView.isUserInteractionEnabled = true
            isRepeats = true
            updateFrequencyButtons()
            
        } else {
            endDatePickerOutlet.isEnabled = false
            endDateLabel.isEnabled = false
            frequencyLabel.isEnabled = false
            frequencyInfoButton.isEnabled = false
            dailyEnabled = false
            weeklyEnabled = false
            monthlyEnabled = false
            
            repeatDailyButton.backgroundColor = UIColor.systemGray
            repeatWeeklyButton.backgroundColor = UIColor.systemGray
            repeatMonthlyButton.backgroundColor = UIColor.systemGray
            
            frequencyView.isUserInteractionEnabled = false
            isRepeats = false
            updateFrequencyButtons()
        }
    }
    
    func displayFrequency() {
        print("Frequency=", myPrescriptions![prescriptionIndex].frequency)
        dailyEnabled = false
        if myPrescriptions![prescriptionIndex].frequency == "Daily" {
            dailyEnabled = true
        } else if myPrescriptions![prescriptionIndex].frequency == "Weekly" {
            weeklyEnabled = true
        } else if myPrescriptions![prescriptionIndex].frequency == "Monthly" {
            monthlyEnabled = true
        }
        
        print(dailyEnabled)
        print(weeklyEnabled)
        print(monthlyEnabled)
    }
    
    func displayColorButtons(){
        isYellow = false
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
        if sender.state == .began {
            sentIndex = 0
            sentDate = allDosageTimes[sentIndex]
            performSegue(withIdentifier: "customDosageTimeSegue", sender: self)
        }
    }
    
    @IBAction func secondLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            sentIndex = 1
            sentDate = allDosageTimes[sentIndex]
            performSegue(withIdentifier: "customDosageTimeSegue", sender: self)
        }
    }
    
    @IBAction func thirdLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            sentIndex = 2
            sentDate = allDosageTimes[sentIndex]
            performSegue(withIdentifier: "customDosageTimeSegue", sender: self)
        }
    }
    
    @IBAction func fourthLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            sentIndex = 3
            sentDate = allDosageTimes[sentIndex]
            performSegue(withIdentifier: "customDosageTimeSegue", sender: self)
        }
    }
    
    @IBAction func fifthLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            sentIndex = 4
            sentDate = allDosageTimes[sentIndex]
            performSegue(withIdentifier: "customDosageTimeSegue", sender: self)
        }
        
    }
    
    
    @IBAction func sixthLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            sentIndex = 5
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
    
    
    
    // MARK: Set Notifications
    // This function fires off the notifications based on the date and dosage times, and enddate and frequency if it is a repeating reminder
    func setNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if success {
                // schedule notifications
                print("Success notification auth")
                self.scheduleNotifications()
            } else if error != nil {
                print("Notification auth ERROR")
                
            } else {
                print("Notifications not authorized")
                
            }
        })
        
        
    }
    
    func scheduleNotifications() {
        // Initialize identifiers array
        newPrescription!.identifier = []
        let frequency = newPrescription!.frequency
        
        let key = "notificationIdentifierCounter"
        notificationCount = UserDefaults.standard.integer(forKey: key)
        var identifier = String(notificationCount!)
        
        print("I am in scheduleNotifications()")
        let content = UNMutableNotificationContent()
        content.title = "Prescription: "+newPrescription!.name!
        content.sound = .default
        content.body = identifier
        
        //let targetDate = Date().addingTimeInterval(20)
        
        if frequency == "Daily" {
            for dosageTime in checkedDosageTimes {
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: dosageTime), repeats: true)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("Adding notification error")
                        self.isNotificationsSet = false
                    }
                })
                
                content.body = identifier
                
                newPrescription!.identifier!.append(identifier)
                
                notificationCount! += 1
                identifier = String(notificationCount!)
                
                
            } // End of loop
            
        } else if frequency == "Weekly" {
            for dosageTime in checkedDosageTimes {
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.weekday, .hour, .minute], from: dosageTime), repeats: true)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("Adding notification error")
                        self.isNotificationsSet = false
                    }
                })
                
                content.body = identifier
                
                newPrescription!.identifier!.append(identifier)
                
                notificationCount! += 1
                identifier = String(notificationCount!)
                

            } // End of loop
            
        } else if frequency == "Monthly" {
            for dosageTime in checkedDosageTimes {
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .hour, .minute], from: dosageTime), repeats: true)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("Adding notification error")
                        self.isNotificationsSet = false
                    }
                })
                
                content.body = identifier
                
                newPrescription!.identifier!.append(identifier)
                
                notificationCount! += 1
                identifier = String(notificationCount!)
                

            } // End of loop
            
        } else if (!isRepeats) {
            for dosageTime in checkedDosageTimes {
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dosageTime), repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("Adding notification error")
                        self.isNotificationsSet = false
                    }
                })
                
                content.body = identifier
                
                newPrescription!.identifier!.append(identifier)
                
                notificationCount! += 1
                identifier = String(notificationCount!)
        }
        }
        
        // Sets the new notificationCount for the next prescription to have unique identifiers
        UserDefaults.standard.setValue(notificationCount!, forKey: key)
        
        // Prints out pending notification requests
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
        for request in requests {
            print(request)
        }
    })
        
        
    
        //UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["notif"])
        
        
        
        
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
        let endDate : Date = endDatePickerOutlet.date
        let intervalFromToday : TimeInterval
        let intervalFromEndDate : TimeInterval
        if(nameTF.hasText && amountTF.hasText && isColorPicked() && isTimePicked()) {
            intervalFromToday = startDate.timeIntervalSince(initialDate!)
            intervalFromEndDate = startDate.timeIntervalSince(endDate)
            if intervalFromToday > -80000 && intervalFromEndDate < -1 {
                    return true
                } else {
                    let alert = UIAlertController(title: String("Date Error"), message: String("Start Date cannot be in the past. End Date cannot be before Start Date."), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return false
                }
        } else {
            let alert = UIAlertController(title: String("Incomplete Form"), message: String("Please check for missing information. Example: Make sure you have at least one dosage time selected."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
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
    
    func fetchPrescriptions() {
        do {
            self.myPrescriptions = try self.context.fetch(Prescription.fetchRequest())
        }
        catch {
            // TODO: Handle Error Here
        }
    }
    
    // MARK: - Navigation
    
    
    @IBAction func deleteButton(_ sender: UIBarButtonItem) {
        let removePrescription = self.myPrescriptions![prescriptionIndex]
        self.context.delete(removePrescription) //removes the swiped shop
        do {
            try self.context.save()
        }catch{
            
        }
        self.fetchPrescriptions()
        performSegue(withIdentifier: "backToPrescriptionsSegue", sender: true)
    }
    
    @IBAction func nextButton(_ sender: UIBarButtonItem) {
        if isEditPage {
            if isFormValid() {
                let prescription = self.myPrescriptions![prescriptionIndex]
                
               prescription.name = nameTF.text
               prescription.dose = amountTF.text
               prescription.notes = noteTF.text
               addDoseTimesToArray() // Adds what is checked to checkedDosageTimes
               prescription.doseTimings = checkedDosageTimes
               print(checkedDosageTimes)
               prescription.color = getSelectedColor()
               prescription.startDate = startDatePickerOutlet.date
               //TODO: Modify the notifications
               if(repeatsSwitch.isOn) {
                   prescription.endDate = endDatePickerOutlet.date
                   prescription.frequency = getSelectedFrequency()
               }
               //TODO: edit dosage times
               
               
               
               
               do {
                   try self.context.save()
               } catch {
                        
               }
               
               self.fetchPrescriptions()

               performSegue(withIdentifier: "editToViewSegue", sender: true)
                
            } else {
                let alert = UIAlertController(title: "Something is Missing", message: "Please make sure all the fields are filled out.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
            }
             
        } else {
        if(isFormValid()) {
            // Add Prescription to Core Data
            newPrescription = Prescription(context: self.context)
            addDoseTimesToArray() // Adds what is checked to checkedDosageTimes
            print(checkedDosageTimes)
            newPrescription!.name = nameTF.text
            newPrescription!.dose = amountTF.text!
            newPrescription!.notes = noteTF.text
            newPrescription!.doseTimings = checkedDosageTimes
            newPrescription!.color = getSelectedColor()
            newPrescription!.startDate = startDatePickerOutlet.date
            newPrescription!.notificationType = false // Not alarm
            /*
            let calendar = Calendar.current
            let date = Date()
            let tmrw = date.addingTimeInterval(86400)
            let week = date.addingTimeInterval(604800)
            if (calendar.component(.day, from: date) == (calendar.component(.day, from: newPrescription!.startDate!))){
                // is today
                newPrescription!.whatDay = 0
            }else if(calendar.component(.day, from: newPrescription!.startDate!) == (calendar.component(.day, from: tmrw))){
                    //is tmrw
                newPrescription!.whatDay = 1
            }else if(calendar.component(.day, from: newPrescription!.startDate!)) < (calendar.component(.day, from: week)){
                    // is later this week
                newPrescription!.whatDay = 2
            }else{
                // LATER
                newPrescription!.whatDay = 3
        
            }*/
            
            if(repeatsSwitch.isOn) {
                newPrescription!.endDate = endDatePickerOutlet.date
                newPrescription!.frequency = getSelectedFrequency()
            }
            
            // Adds startDate to the doseTimings array in the prescription
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MM y"
            let startDateAsString = formatter.string(from: startDatePickerOutlet.date)
            
            for i in 0 ..< checkedDosageTimes.count {
                formatter.dateFormat = "hh:mm a"
                let doseTimingAsString = formatter.string(from: checkedDosageTimes[i])
                formatter.dateFormat = "hh:mm a, dd MM y"
                
                checkedDosageTimes[i] = formatter.date(from: doseTimingAsString+", "+startDateAsString)!
            }
            
            
            print(checkedDosageTimes)
            
                prescriptionArray!.append(newPrescription!)
                // Save data
                do {
                    try self.context.save()
                }
                catch {
                    // TODO: Handle error
                }
            
            setNotifications()
            
            
                performSegue(withIdentifier: "backToPrescriptionsSegue", sender: self)
            
            
        } else {
            let alert = UIAlertController(title: "Something is Missing", message: "Please make sure all the fields are filled out.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
        }
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        if isEditPage {
            // return to previous viewcontroller
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
            print("just returned")
            //performSegue(withIdentifier: "editToViewSegue", sender: self)
        } else {
            // return to previous viewcontroller
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
            print("just returned")
            //performSegue(withIdentifier: "backToPrescriptionsSegue", sender: self)
        }
    }
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToPrescriptionsSegue" {
            let destTabVC = segue.destination as! UITabBarController
            let destNavVC = destTabVC.viewControllers![0] as! UINavigationController
            let destinationVC = destNavVC.topViewController as! MyPrescriptionsVC
            
            destinationVC.myPrescriptions = prescriptionArray
            
        } else if segue.identifier == "customDosageTimeSegue" {
            let destinationVC = segue.destination as! customDosageTimeVC
            destinationVC.receivingDate = sentDate
            destinationVC.receivingIndex = sentIndex
            destinationVC.startDate = startDatePickerOutlet.date
            
            destinationVC.delegate = self // To use customTime protocol to pass values between views
            
            
        } else if segue.identifier == "editToViewSegue" {
            let destTabVC = segue.destination as! UITabBarController
            let destNavVC = destTabVC.viewControllers![0] as! UINavigationController
            let destinationVC = destNavVC.topViewController as! MyPrescriptionsVC
            
            destinationVC.prescriptionIndex = self.prescriptionIndex
            destinationVC.myPrescriptions = self.myPrescriptions
        }
    }
    
    

}
