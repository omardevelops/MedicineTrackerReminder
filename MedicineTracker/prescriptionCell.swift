//
//  prescriptionCell.swift
//  MedicineTracker
//
//  Created by Saeed on 19/11/2020.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class prescriptionCell: UICollectionViewCell {

    @IBOutlet weak var pDose: UILabel!
    @IBOutlet weak var editB: UIButton!
    
    @objc func editCell(_ sender: UIButton) {
        print("edit")
     /*   MyPrescriptionsVC.performSegueWithIdentifier("showActionPreview", sender: nil)*/
    }
    @IBOutlet weak var pLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with name: String,color: UIColor, dose: String){
        //TODO: Configure Image and Color
        
        pLabel.text = name
        pDose.text = dose
        self.backgroundColor = color
        
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "prescriptionCell", bundle: nil)
    }

}
extension UIColor {
    class var random: UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
    }
}
