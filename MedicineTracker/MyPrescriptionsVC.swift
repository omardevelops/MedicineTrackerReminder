//
//  FirstViewController.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/12/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class MyPrescriptionsVC: UIViewController {
    
    static var cellCount = 7;

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(prescriptionCell.nib(), forCellWithReuseIdentifier: "prescriptionCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        

        // Do any additional setup after loading the view.
    }


}

extension MyPrescriptionsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        print("Tapped")
    }
   
    
}

extension MyPrescriptionsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return MyPrescriptionsVC.cellCount;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "prescriptionCell", for: indexPath) as! prescriptionCell
        
        
        return cell
    }
    
   
    
}

extension MyPrescriptionsVC: UICollectionViewDelegateFlowLayout{
    
}

