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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //go to edit view func
    @objc func editCell() {
        performSegue(withIdentifier: "goToEdit", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        // No need for this as we can use a prototype cell instead
        collectionView.register(prescriptionCell.nib(), forCellWithReuseIdentifier: "prescriptionCell")
        fetchPrescriptions()
        
    }
    
    @IBAction func addPrescription(_ sender: UIBarButtonItem) {
       /* let alert = UIAlertController(title: "Add Prescription", message: "", preferredStyle: .alert)
        
        alert.addTextField()
        
        let action = UIAlertAction(title: "Add Person", style: .default, handler: {action in
            
            // Get textfield for alert
            let textfield = alert.textFields![0]
            
            // Create a prescription object
            let newPrescription = Prescription(context: self.context)
            newPrescription.name = textfield.text
            
            // Save data
            do {
                try self.context.save()
            }
            catch {
                // TODO: Handle error
            }
            
            // Re-fetch data
            self.fetchPrescriptions()
        })
        
        alert.addAction(action)
        present(alert, animated: true)*/
        
        // Changed by me, Omar
        performSegue(withIdentifier: "addDetailSegue", sender: self)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        //DELETE CELL
        let ps = myPrescriptions![indexPath.row]
        context.delete(ps)
        self.fetchPrescriptions()
        
        print("Tapped Cell #", indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return myPrescriptions?.count ?? 0
        //return MyPrescriptionsVC.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "prescriptionCell", for: indexPath) as! prescriptionCell
        
           cell.editB.tag = indexPath.row
           cell.editB.addTarget(self, action: #selector(editCell), for: .touchUpInside)
        
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
            
        }
    }


}

