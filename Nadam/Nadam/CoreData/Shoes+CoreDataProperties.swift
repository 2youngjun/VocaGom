//
//  Shoes+CoreDataProperties.swift
//  
//
//  Created by 이영준 on 2022/10/07.
//
//

import Foundation
import CoreData


extension Shoes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shoes> {
        return NSFetchRequest<Shoes>(entityName: "Shoes")
    }

    @NSManaged public var isBought: Bool
    @NSManaged public var imageName: String?

}
