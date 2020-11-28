//
//  calendarCell.swift
//  MedicineTracker
//
//  Created by Saeed on 27/11/2020.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class calendarCell: UITableViewCell,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var myPrescriptions : [Prescription]?
    

    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pCalendarCollectionView: UICollectionView!
    

    
    public func configure(datalabel: String){
        //TODO: Configure Image and Color
        
        dateLabel.text = datalabel
        
    }
    
    
    /*edit Cell
     
 @objc func editCell() {
     performSegue(withIdentifier: "goToEdit", sender: self)
 }*/
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pCalendarCollectionView.delegate = self
        pCalendarCollectionView.dataSource = self
        pCalendarCollectionView.register(pCalendarCollectionCell.nib(), forCellWithReuseIdentifier: "pCalendarCollectionCell")
        // Initialization code
        fetchPrescriptions()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    static func nib() -> UINib {
        return UINib(nibName: "calendarCell", bundle: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPrescriptions?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pCalendarCollectionCell", for: indexPath) as! pCalendarCollectionCell
        
           //cell.editB.tag = indexPath.row
           //cell.editB.addTarget(self, action: #selector(editCell), for: .touchUpInside)
        
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
                self.pCalendarCollectionView.reloadData()
            }
        }
        catch {
            // TODO: Handle Error Here
        }
    }

    
    
}
