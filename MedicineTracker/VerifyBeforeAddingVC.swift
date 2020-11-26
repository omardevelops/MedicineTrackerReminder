//
//  VerifyBeforeAddingVC.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/25/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class VerifyBeforeAddingVC: UIViewController {
    
    var name : String = ""
    var dose : String = ""
    var color : UIColor = UIColor.systemBlue
    var isRepeats : Bool = true
    var frequency : String = ""
    var dosageTimes : [Date] = []
    var notes : String = ""
    var notificationType : Int = 1; // Alarm
    
    @IBOutlet weak var nameLabel: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = name
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
