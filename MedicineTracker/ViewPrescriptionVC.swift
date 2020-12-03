//
//  ViewPrescriptionVC.swift
//  MedicineTracker
//
//  Created by Ali Alshamsi on 27/11/2020.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class ViewPrescriptionVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    @IBOutlet weak var dosageTimingsLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    
    var myPrescriptions : [Prescription]?
    var prescriptionIndex = 0
    var isEditPage = true
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = myPrescriptions![prescriptionIndex].name
        dosageLabel.text = myPrescriptions![prescriptionIndex].dose
        noteLabel.text = myPrescriptions![prescriptionIndex].notes
        let myPrescription = myPrescriptions![prescriptionIndex]
        if myPrescription.isRepeats {
            frequencyLabel.text = myPrescription.frequency
        } else {
            frequencyLabel.text = "Non-repeating Prescription"
        }
        
        let dosageTimings = myPrescriptions![prescriptionIndex].doseTimings
        let timingFormatter = DateFormatter()
        timingFormatter.dateFormat = "hh:mm a"
        var timingsText : String = ""
        for timing in dosageTimings! {
            timingsText += timingFormatter.string(from: timing)
            timingsText += "\n"
            print(timing)
        }
        dosageTimingsLabel.text = timingsText
        //TODO: next dose
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMd")
        //dateFormatter.dateFormat = "MM/dd"
        startDateLabel.text = dateFormatter.string(from: myPrescriptions![prescriptionIndex].startDate!)
        //endDateLabel.text = dateFormatter.string(from: myPrescriptions![prescriptionIndex].endDate ?? myPrescriptions![prescriptionIndex].startDate!)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "viewToEditSegue", sender: self)
    }
        
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        // return to previous viewcontroller
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        print("just returned")
        //performSegue(withIdentifier: "viewToPrescriptionsSegue", sender: self)
    }
    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewToEditSegue" {
            let destinationNavVC = segue.destination as! UINavigationController
            let destinationVC = destinationNavVC.topViewController as! AddPrescriptionVC
            destinationVC.prescriptionIndex = self.prescriptionIndex
            destinationVC.myPrescriptions = self.myPrescriptions
            destinationVC.isEditPage = self.isEditPage
        }
    }
}
