//
//  Pants+CoreDataProperties.swift
//  
//
//  Created by 이영준 on 2022/10/07.
//
//

import Foundation
import CoreData


extension Pants {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pants> {
        return NSFetchRequest<Pants>(entityName: "Pants")
    }

    @NSManaged public var isBought: Bool
    @NSManaged public var imageName: String?

}
