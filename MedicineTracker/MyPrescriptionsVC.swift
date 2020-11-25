//
//  FirstViewController.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/12/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class MyPrescriptionsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Core Data Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var myPrescriptions : [Prescription]?
    static var cellCount = 11

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(prescriptionCell.nib(), forCellWithReuseIdentifier: "prescriptionCell")
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        print("Tapped Cell #", indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        //return myPrescriptions?.count ?? 0
        return MyPrescriptionsVC.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "prescriptionCell", for: indexPath) as! prescriptionCell
        
        
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


}

/* MARK: Not needed
extension MyPrescriptionsVC: UICollectionViewDelegate {
    
    
   
    
}

extension MyPrescriptionsVC: UICollectionViewDataSource {
    
    
    
   
    
}


extension MyPrescriptionsVC: UICollectionViewDelegateFlowLayout{
    
}*/

