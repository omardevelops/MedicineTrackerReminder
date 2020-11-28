//
//  SecondViewController.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/12/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    struct count {
        static var CountForReal:Int = 0
    }
    
    
    var testCount = 4
    var today = false
    var tmrw = false
    var tableViewLabels:[String] = []

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var myPrescriptions : [Prescription]?
    var startDatesUnsorted: [Date] = []
    var sortedIndexOfDates:[Int] = []

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPrescriptions()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(calendarCell.nib(), forCellReuseIdentifier: "calendarCell")
       
        if myPrescriptions?.count != nil {
            
        for index in 0 ..< myPrescriptions!.count{
            if (today == false) && (myPrescriptions![index].whatDay == 0){
                today = true
            }
            if (tmrw == false) && (myPrescriptions![index].whatDay == 1){
                tmrw = true
            }
            
        }
            print(today.description)
            print(tmrw.description)

            if (today) && (tmrw) {
                tableViewLabels.append("Today")
                tableViewLabels.append("Tommorow")
            }else if !(today) && (tmrw){
                tableViewLabels.append("Tommorow")
            }else if (today) && !(tmrw){
                tableViewLabels.append("Today")
            }
            
            //let dates:[Date] = []
            
            for i in 1...(myPrescriptions!.count-1) {
                
                startDatesUnsorted.append(myPrescriptions![i].startDate!)
                
            }
            
            for i in 1...(startDatesUnsorted.count-1){
                var smallest:Date = startDatesUnsorted[i]
                for y in i...startDatesUnsorted.count-1{
                    if (startDatesUnsorted[y] < smallest){
                    smallest = startDatesUnsorted[y]
                    }
                }
                let dateA = smallest
                let dateF = DateFormatter()
                dateF.dateFormat = "MMM d, yyyy"
                
                
                if (tableViewLabels.last) != (dateF.string(from: dateA)){
                    tableViewLabels.append(dateF.string(from: dateA))
                }
                
                
            }
            print(tableViewLabels)
            /*
            
            let pre:Int = myPrescriptions!.count
            
            // putting start dates in array
            for pre in 1...pre{
                startDatesUnsorted[pre] = prescription.startDate!
            }
            // sort array by date (save index in new array)
            for index in 1...myPrescriptions!.count{
                var smallest = index
                for x in index+1...(myPrescriptions!.count-1){
               
                if (startDatesUnsorted[x]) < (startDatesUnsorted[smallest]){
                   
                    smallest = x
                
                    }
                    
                    
                }
                sortedIndexOfDates[index] = smallest

            }
                
             */
        }
    }
        
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as! calendarCell
        /*
        let prescription = myPrescriptions![indexPath.row]
        var text = ""
        switch prescription.whatDay {
        case 0:
            text = "Today"
        case 1:
            text = "Tommorow"
        case 2:
            text = "Later This Week"
        default:
            text = "Later on"
        }*/
        
        
        
        cell.configure(datalabel: tableViewLabels[indexPath.row])
        //cell.textLabel?.text = name[indexPath.row]
        return cell
    }
    
 /*   func tableView(_ tableView: UITableView, heightForRowAt indexpath: IndexPath) -> CGFloat {
        
        return 250
    }
*/

    
    
    // MARK: Fetch Prescriptions
    func fetchPrescriptions() {
        do {
            self.myPrescriptions = try self.context.fetch(Prescription.fetchRequest())
            
            DispatchQueue.main.async {
                // Reload CollectionView
                self.tableView.reloadData()
            }
        }
        catch {
            // TODO: Handle Error Here
        }
    }
}

