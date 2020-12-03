//
//  FirstViewController.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/12/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class MyPrescriptionsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Core Data Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var myPrescriptions : [Prescription]?
    
    var prescriptionIndex = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Used to initialize the default dosage timings
    //let initialTimings : [String]?
    
    // MARK: Edit Cell
    // NEEDS FIXING
    //@objc func editCell() {
     //   performSegue(withIdentifier: "goToEdit", sender: self)
     //
   // }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let defaultTimingsArray = defaults.array(forKey: "Default dosage times")
        if defaultTimingsArray == nil {
            // These default initial timings will be initialized on the first run of the app and can be modified by the user in Settings
            let initialTimings = ["8:00 AM", "12:00 PM", "06:00 PM", "09:00 PM", "12:00 AM", "03:00 AM"]
            defaults.setValue(initialTimings, forKey: "Default dosage times")
            
            // Set name pop-up menu
            let alert = UIAlertController(title: "Your Name", message: "Welcome! What is your name?", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textfield) in
                textfield.placeholder = "Enter Your Name"
            })
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
                let textfield = alert.textFields![0]
                let defaults = UserDefaults.standard
                defaults.setValue(textfield.text, forKey: "username")
            }))
            present(alert, animated: true)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(prescriptionCell.nib(), forCellWithReuseIdentifier: "prescriptionCell")
        fetchPrescriptions()
        requestNotificationAuthorization()
        
    }
    
    @IBAction func addPrescription(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "addDetailSegue", sender: self)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        prescriptionIndex = indexPath.row
        performSegue(withIdentifier: "viewPrescriptionSegue", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        
        CalendarVC.count.CountForReal =  myPrescriptions?.count ?? 0
        return myPrescriptions?.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "prescriptionCell", for: indexPath) as! prescriptionCell
        
          // cell.editB.tag = indexPath.row
          // cell.editB.addTarget(self, action: #selector(editCell), for: .touchUpInside)
        
        let prescription = myPrescriptions![indexPath.row]
        cell.configure(with: prescription.name ?? "null",color: prescription.color ?? UIColor.white, dose: prescription.dose ?? " ")
        return cell
    }
    
    // MARK: Fetch Prescriptions
    func fetchPrescriptions() {
        do {
            self.myPrescriptions = try self.context.fetch(Prescription.fetchRequest())
            
            DispatchQueue.main.async {
                // Reload CollectionView
                self.collectionView.reloadData()
            }
        }
        catch {
            // TODO: Handle Error Here
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addDetailSegue") {
            let destinationNavVC = segue.destination as! UINavigationController
            let destinationVC = destinationNavVC.topViewController as! AddPrescriptionVC
            destinationVC.prescriptionArray = myPrescriptions
            
        } else if segue.identifier == "viewPrescriptionSegue" {
            let destinationVC = segue.destination as! ViewPrescriptionVC
            destinationVC.prescriptionIndex = self.prescriptionIndex
            destinationVC.myPrescriptions = self.myPrescriptions
            
        } else if segue.identifier == "goToEdit" {
            let destinationVC = segue.destination as! AddPrescriptionVC
            destinationVC.prescriptionIndex = self.prescriptionIndex
            destinationVC.isEditPage = true
        }
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if success {
                // schedule notifications
                print("Success notification auth")
            } else if error != nil {
                print("Notification auth ERROR")
                
            } else {
                print("Notifications not authorized")
                
            }
        })
    }


}

