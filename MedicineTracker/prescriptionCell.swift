//
//  prescriptionCell.swift
//  MedicineTracker
//
//  Created by Saeed on 19/11/2020.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class prescriptionCell: UICollectionViewCell {

    @IBAction func edit(_ sender: Any) {
          
     /*   MyPrescriptionsVC.performSegueWithIdentifier("showActionPreview", sender: nil)*/
    }
    @IBOutlet weak var pLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with name: String){
        //TODO: Configure Image and Color
        
        pLabel.text = name
        
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "prescriptionCell", bundle: nil)
    }

}
