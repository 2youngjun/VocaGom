//
//  Accessory+CoreDataProperties.swift
//  
//
//  Created by 이영준 on 2022/10/07.
//
//

import Foundation
import CoreData


extension Accessory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Accessory> {
        return NSFetchRequest<Accessory>(entityName: "Accessory")
    }

    @NSManaged public var imageName: String?
    @NSManaged public var isBought: Bool

}
