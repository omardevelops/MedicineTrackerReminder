//
//  Prescription+CoreDataProperties.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/27/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension Prescription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prescription> {
        return NSFetchRequest<Prescription>(entityName: "Prescription")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var dose: String?
    @NSManaged public var doseTimings: [Date]?
    @NSManaged public var endDate: Date?
    @NSManaged public var frequency: String?
    @NSManaged public var identifier: [String]?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var notificationType: Bool
    @NSManaged public var startDate: Date?
    @NSManaged public var whatDay: Int16

}

extension Prescription : Identifiable {

}
