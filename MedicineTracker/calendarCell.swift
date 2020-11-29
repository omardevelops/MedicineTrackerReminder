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

    var eachPreCell = [Prescription]()
    var IndexForCell:Int = 0
    var cellArray = [[Prescription]]()
    var count:Int = 0
    var IndexArr:[Int] = []
    

    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pCalendarCollectionView: UICollectionView!
    

    
    public func configure(datalabel: String,  indexOfTableCell: Int){
        //TODO: Configure Image and Color
        
        let theCell = datalabel
        let date = Date()
        let dateF = DateFormatter()
        let tomrw = date.addingTimeInterval(86400)
        let calendar = Calendar.current
        dateF.dateFormat = "MMM d, yyyy"
        
        for i in 0...myPrescriptions!.count-1{
            
            if (theCell == "Today") && (calendar.isDateInToday(myPrescriptions![i].startDate!)){
                eachPreCell.append(myPrescriptions![i])
                
            }else if (theCell == "Tomorrow") && (calendar.isDateInTomorrow(myPrescriptions![i].startDate!)){
                eachPreCell.append(myPrescriptions![i])

            }else if (dateF.string(from: myPrescriptions![i].startDate!)) == (theCell){
                eachPreCell.append(myPrescriptions![i])
            }
            
            
            
            /*
            
           
            if (( dateF.string(from: myPrescriptions![i].startDate!)) == dateF.string(from: date)) && (theCell == "Today") {
                eachPreCell.append(myPrescriptions![i])
                print("hi")
                
            }else if ( dateF.string(from: myPrescriptions![i].startDate!)) == dateF.string(from: tomrw) && (theCell == "Tomorow") {
                eachPreCell.append(myPrescriptions![i])
            }else if (dateF.string(from: myPrescriptions![i].startDate!)) == (theCell){
                eachPreCell.append(myPrescriptions![i])
            }
    */
        }
        print(eachPreCell)
        cellArray.append(eachPreCell)
        print(cellArray)
        dateLabel.text = datalabel
        IndexArr.append(indexOfTableCell)
        
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
        return cellArray[(0)].count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pCalendarCollectionCell", for: indexPath) as! pCalendarCollectionCell
        
           //cell.editB.tag = indexPath.row
           //cell.editB.addTarget(self, action: #selector(editCell), for: .touchUpInside)
        let prescription = cellArray[(0)][indexPath.row]
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
