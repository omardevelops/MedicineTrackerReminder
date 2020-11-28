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
    
    var eachPreCell: [Prescription] = []
    var testCount = 4
    var today:Bool = false
    var tmrw:Bool = false
    var tableViewLabels:[String] = []
    var labelDatesStartIndex:Int = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var myPrescriptions : [Prescription]?
    var startDatesUnsorted: [Date] = []
    var sortedDates:[Date] = []
    struct cellA{
        static var cellArray = [[Prescription]]()
    }

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        fetchPrescriptions()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(calendarCell.nib(), forCellReuseIdentifier: "calendarCell")
        
        startDatesUnsorted.removeAll()
        tableViewLabels.removeAll()
        labelDatesStartIndex = 0
        sortedDates.removeAll()
        today = false
        tmrw = false
        if myPrescriptions?.count != nil {
            
        
            
            //let dates:[Date] = []
            if myPrescriptions!.count > 0 {
                
                let calendar = Calendar.current
                let date = Date()
                let tomrw = date.addingTimeInterval(86400)
                let week = date.addingTimeInterval(604800)
                
                for i in 0...myPrescriptions!.count-1 {
                
                if (calendar.component(.day, from: date) == (calendar.component(.day, from: myPrescriptions![i].startDate!))){
                    // is today
                    myPrescriptions![i].whatDay = 0
                }else if(calendar.component(.day, from: myPrescriptions![i].startDate!) == (calendar.component(.day, from: tomrw))){
                        //is tmrw
                    myPrescriptions![i].whatDay = 1
                }else if(calendar.component(.day, from: myPrescriptions![i].startDate!)) < (calendar.component(.day, from: week)){
                        // is later this week
                    myPrescriptions![i].whatDay = 2
                }else{
                    // LATER
                    myPrescriptions![i].whatDay = 3
            
                }
                }
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
                        labelDatesStartIndex = 2
                    }else if !(today) && (tmrw){
                        tableViewLabels.append("Tommorow")
                        labelDatesStartIndex = 1
                    }else if (today) && !(tmrw){
                        tableViewLabels.append("Today")
                        labelDatesStartIndex = 1
                    }else{
                        labelDatesStartIndex = 0
                    }
               
            for i in 0...(myPrescriptions!.count-1) {
                
                startDatesUnsorted.append(myPrescriptions![i].startDate!)
                
            }
                startDatesUnsorted.sort()
                /*
                 
                for i in 0...(myPrescriptions!.count-1){
                    var small:Int = i
                    var x = i
                    for y in x...myPrescriptions!.count-1{
                        if (startDatesUnsorted[y] < startDatesUnsorted[small]){
                           small = y
                        }
                    }
                    startDatesUnsorted[i] = startDatesUnsorted[small]
                    startDatesUnsorted[small] = startDatesUnsorted[i]
                }
                sortedDates = startDatesUnsorted
            */
            for i in labelDatesStartIndex...(startDatesUnsorted.count-1){
                /*var smallest:Date = startDatesUnsorted[i]
                for y in i...startDatesUnsorted.count-1{
                    if (startDatesUnsorted[y] < smallest){
                    smallest = startDatesUnsorted[y]
                    }
                }*/
                let dateA = startDatesUnsorted[i]
                let dateF = DateFormatter()
                dateF.dateFormat = "MMM d, yyyy"
                //print((calendar.component(.day, from: smallest)))
                //if ((calendar.component(.day, from: smallest)) != calendar.component(.day, from: date)) && ((calendar.component(.day, from: smallest)) != calendar.component(.day, from: tomrw)) {
                if !(i == 0) && !(labelDatesStartIndex == 0){
                
                    
                    if ((tableViewLabels[tableViewLabels.count-1]) != (dateF.string(from: dateA))) {
                        //&& ((calendar.component(.day, from: smallest)) != calendar.component(.day, from: date)) && ((calendar.component(.day, from: smallest)) != calendar.component(.day, from: tmrw))
                
                    tableViewLabels.append(dateF.string(from: dateA))
                }
                }else{
                    tableViewLabels.append(dateF.string(from: dateA))

                }
                
                
            }
            
            }
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
        
        
        
        cell.configure(datalabel: tableViewLabels[indexPath.row], indexOfTableCell: indexPath.row)
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

