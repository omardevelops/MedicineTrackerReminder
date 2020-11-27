//
//  SecondViewController.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/12/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var testCount = 4
    
    var testArr = ["Cell 1", "Cell 2", "Cell 3", "Cell 4", "Cell 5"]

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var myPrescriptions : [Prescription]?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(calendarCell.nib(), forCellReuseIdentifier: "calendarCell")
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as! calendarCell
        //cell.textLabel?.text = name[indexPath.row]
        return cell
    }
    
 /*   func tableView(_ tableView: UITableView, heightForRowAt indexpath: IndexPath) -> CGFloat {
        
        return 250
    }
*/

}

