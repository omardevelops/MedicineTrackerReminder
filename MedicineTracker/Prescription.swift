//
//  Prescription.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/12/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//

import Foundation
import UIKit

class Prescription {
    var name : String
    var photo : UIImage
    var category : String
    var color : UIColor
    var startDate : Date
    var endDate : Date
    var quantity : Int
    var notes : String
    
    init(name : String,
     photo : UIImage,
     category : String,
     color : UIColor,
     startDate : Date,
     endDate : Date,
     quantity : Int,
     notes : String) {
        self.name = name
        self.photo = photo
        self.category = category
        self.color = color
        self.startDate = startDate
        self.endDate = endDate
        self.quantity = quantity
        self.notes = notes
    }
}

