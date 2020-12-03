//
//  pCalendarCollectionCell.swift
//  MedicineTracker
//
//  Created by Saeed on 27/11/2020.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import UIKit

class pCalendarCollectionCell: UICollectionViewCell {

    @IBOutlet weak var pDose: UILabel!
    //@IBOutlet weak var editB: UIButton!
    
    //@objc func editCell(_ sender: UIButton) {
    //    print(pCalendarCollectionCell.index(self))
    // /*   MyPrescriptionsVC.performSegueWithIdentifier("showActionPreview", sender: nil)*/
    //}
    @IBOutlet weak var viewO: UIView!
    @IBOutlet weak var pLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with name: String,color: UIColor, dose: String){
        //TODO: Configure Image and Color
        
        pLabel.text = name
        pDose.text = dose
        viewO.backgroundColor = color
        
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "pCalendarCollectionCell", bundle: nil)
    }

}
extension UIColor {
    class var randomV: UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
    }
}

