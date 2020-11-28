//
//  EditViewController.swift
//  MedicineTracker
//
//  Created by Ali Alshamsi on 27/11/2020.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class EditPrescriptionVC: UIViewController {
    var myPrescriptions : [Prescription]?
    var prescriptionIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editToPrescriptionsSegue", sender: self)
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editToViewSegue", sender: self)
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
