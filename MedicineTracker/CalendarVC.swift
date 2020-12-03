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
    var daily:Bool = false
    var dailyArr: [Date] = []
    var weeklyArr: [Date] = []
    var monthlyArr: [Date] = []
    var weekly:Bool = false
    var monthly:Bool = false
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
                
               // let calendar = Calendar.current
                let date = Date()
                let tomrw = date.addingTimeInterval(86400)
                //let week = date.addingTimeInterval(604800)
                
                for i in 0...myPrescriptions!.count-1 {
                
                if (Calendar.current.isDateInToday(myPrescriptions![i].startDate!)){
                    // is today
                    myPrescriptions![i].whatDay = 0
                }else if(Calendar.current.isDateInTomorrow(myPrescriptions![i].startDate!)){
                        //is tmrw
                    myPrescriptions![i].whatDay = 1
                
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
                        tableViewLabels.append("Tomorrow")
                        labelDatesStartIndex = 2
                    }else if !(today) && (tmrw){
                        tableViewLabels.append("Tomorrow")
                        labelDatesStartIndex = 1
                    }else if (today) && !(tmrw){
                        tableViewLabels.append("Today")
                        labelDatesStartIndex = 1
                    }else{
                        labelDatesStartIndex = 0
                    }
               
            for i in 0...(myPrescriptions!.count-1) {
                if (myPrescriptions![i].frequency == "Daily"){
                    daily = true
                    dailyArr.append(myPrescriptions![i].startDate!)
                }
                if (myPrescriptions![i].frequency == "Weekly"){
                    weekly = true
                    weeklyArr.append(myPrescriptions![i].startDate!)
                }
                if (myPrescriptions![i].frequency == "Monthly"){
                    monthly = true
                    monthlyArr.append(myPrescriptions![i].startDate!)
                }
                startDatesUnsorted.append(myPrescriptions![i].startDate!)
                
            }
                if (daily){
                    dailyArr.sort()
                    var dailyDate = dailyArr[0]
                    for _ in 0...50{
                        dailyDate.addTimeInterval(86400)
                        startDatesUnsorted.append(dailyDate)
                    }
                }
                if (weekly){
                    weeklyArr.sort()
                    var weeklyDate = weeklyArr[0]
                    for _ in 0...8{
                        weeklyDate.addTimeInterval(604800)
                        startDatesUnsorted.append(weeklyDate)
                    }
                }/*
                if (monthly){
                    monthlyArr.sort()
                    var monthlyDate = monthlyArr[0]
                    for _ in 0...2{
                        monthlyDate.addTimeInterval(2419200)
                        startDatesUnsorted.append(monthlyDate)
                    }
                }*/
                
                
                
                
                
                
                
                startDatesUnsorted.sort()//NOW ITS SORTED
                print(startDatesUnsorted)
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
            for i in 0...(startDatesUnsorted.count-1){
                
                /*var smallest:Date = startDatesUnsorted[i]
                for y in i...startDatesUnsorted.count-1{
                    if (startDatesUnsorted[y] < smallest){
                    smallest = startDatesUnsorted[y]
                    }
                }*/
                let dateA = startDatesUnsorted[i]
                //let calendar = Calendar.current
                //let date = Date()
                //let tomrw = date.addingTimeInterval(86400)
                let dateF = DateFormatter()
                dateF.dateFormat = "MMM d, yyyy"
                //print((calendar.component(.day, from: smallest)))
                //if ((calendar.component(.day, from: smallest)) != calendar.component(.day, from: date)) && ((calendar.component(.day, from: smallest)) != calendar.component(.day, from: tomrw)) {
                if (Calendar.current.isDateInToday(startDatesUnsorted[i])){
                    
                    
                    
                }else if ((Calendar.current.isDateInTomorrow(startDatesUnsorted[i]))){
                    
                    
                }else if !(i == 0){
                    if(dateA>tomrw){
                    if (dateF.string(from: startDatesUnsorted[i-1])) != (dateF.string(from: startDatesUnsorted[i])){
                        
                        tableViewLabels.append(dateF.string(from: dateA))
                    }
                    }
                    
                }else{
                    if(dateA>tomrw){
                        tableViewLabels.append(dateF.string(from: dateA))

                    }
                    
                }
                
                
                
                
                /*
                if !(i == 0) && !(labelDatesStartIndex == 0){
                
                    
                    if ((tableViewLabels[tableViewLabels.count-1]) != (dateF.string(from: dateA))) {
                        //&& ((calendar.component(.day, from: smallest)) != calendar.component(.day, from: date)) && ((calendar.component(.day, from: smallest)) != calendar.component(.day, from: tmrw))
                
                    tableViewLabels.append(dateF.string(from: dateA))
                }
                }else{
                    tableViewLabels.append(dateF.string(from: dateA))

                }
                */
                
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
        if myPrescriptions != nil {
            if myPrescriptions!.count < 5 {
                return myPrescriptions!.count
            } else if myPrescriptions!.count >= 5 {
                return 5
            } else {
                return 0
            }
        } else {
            return 0
        }
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
        print(tableViewLabels)
        cell.prepareForReuse()
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

