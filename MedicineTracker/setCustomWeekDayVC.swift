//
//  setCustomWeekDayVC.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 12/3/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class setCustomWeekDayVC: UIViewController {

    @IBOutlet weak var buttonOutlet1: UIButton!
    @IBOutlet weak var buttonOutlet2: UIButton!
    @IBOutlet weak var buttonOutlet3: UIButton!
    @IBOutlet weak var buttonOutlet4: UIButton!
    @IBOutlet weak var buttonOutlet5: UIButton!
    @IBOutlet weak var buttonOutlet6: UIButton!
    @IBOutlet weak var buttonOutlet7: UIButton!
    
    // Array stores which day is selected. From 0 to 6, in this example, 0 is Saturday and 6 is Friday.
    var isDaySelected : [Bool] = [false, false, false, false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Updates the button views according to whether they're selected or not
    func updateButtonViews() {
        if isDaySelected[0] {
            buttonOutlet1.backgroundColor = UIColor.customLightBlue
        } else {
            buttonOutlet1.backgroundColor = UIColor.systemBlue
        }
        
        if isDaySelected[1] {
            buttonOutlet2.backgroundColor = UIColor.customLightBlue
        } else {
            buttonOutlet2.backgroundColor = UIColor.systemBlue
        }
        
        if isDaySelected[2] {
            buttonOutlet3.backgroundColor = UIColor.customLightBlue
        } else {
            buttonOutlet3.backgroundColor = UIColor.systemBlue
        }
        
        if isDaySelected[3] {
            buttonOutlet4.backgroundColor = UIColor.customLightBlue
        } else {
            buttonOutlet4.backgroundColor = UIColor.systemBlue
        }
        
        if isDaySelected[4] {
            buttonOutlet5.backgroundColor = UIColor.customLightBlue
        } else {
            buttonOutlet5.backgroundColor = UIColor.systemBlue
        }
        
        if isDaySelected[5] {
            buttonOutlet6.backgroundColor = UIColor.customLightBlue
        } else {
            buttonOutlet6.backgroundColor = UIColor.systemBlue
        }
        
        if isDaySelected[6] {
            buttonOutlet7.backgroundColor = UIColor.customLightBlue
        } else {
            buttonOutlet7.backgroundColor = UIColor.systemBlue
        }
    }
    
    
    @IBAction func tapButton1(_ sender: UIButton) {
        if !(isDaySelected[0]) {
            isDaySelected[0] = true
            updateButtonViews()
        } else {
            isDaySelected[0] = false
            updateButtonViews()
        }
    }
    
    @IBAction func tapButton2(_ sender: UIButton) {
        if !(isDaySelected[1]) {
            isDaySelected[1] = true
            updateButtonViews()
        } else {
            isDaySelected[1] = false
            updateButtonViews()
        }
    }
    
    @IBAction func tapButton3(_ sender: UIButton) {
        if !(isDaySelected[2]) {
            isDaySelected[2] = true
            updateButtonViews()
        } else {
            isDaySelected[2] = false
            updateButtonViews()
        }
    }
    
    @IBAction func tapButton4(_ sender: UIButton) {
        if !(isDaySelected[3]) {
            isDaySelected[3] = true
            updateButtonViews()
        } else {
            isDaySelected[3] = false
            updateButtonViews()
        }
    }
    
    @IBAction func tapButton5(_ sender: UIButton) {
        if !(isDaySelected[4]) {
            isDaySelected[4] = true
            updateButtonViews()
        } else {
            isDaySelected[4] = false
            updateButtonViews()
        }
    }
    
    @IBAction func tapButton6(_ sender: UIButton) {
        if !(isDaySelected[5]) {
            isDaySelected[5] = true
            updateButtonViews()
        } else {
            isDaySelected[5] = false
            updateButtonViews()
        }
    }
    
    @IBAction func tapButton7(_ sender: UIButton) {
        if !(isDaySelected[6]) {
            isDaySelected[6] = true
            updateButtonViews()
        } else {
            isDaySelected[6] = false
            updateButtonViews()
        }
    }
    
    @IBAction func setCustomDaysButton(_ sender: UIButton) {
        
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
