//
//  Prescription+CoreDataProperties.swift
//  MedicineTracker
//
//  Created by Omar Ahmed on 11/25/20.
//  Copyright © 2020 Omar Ahmad. All rights reserved.
//
//

import Foundation
import CoreData


extension Prescription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prescription> {
        return NSFetchRequest<Prescription>(entityName: "Prescription")
    }

    @NSManaged public var color: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var notificationType: Bool
    @NSManaged public var quantity: Int64
    @NSManaged public var startDate: Date?
    @NSManaged public var doseTimings: [Date]?

}

extension Prescription : Identifiable {

}
