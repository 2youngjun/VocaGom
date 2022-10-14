//
//  Shirt+CoreDataProperties.swift
//  
//
//  Created by 이영준 on 2022/10/07.
//
//

import Foundation
import CoreData


extension Shirt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shirt> {
        return NSFetchRequest<Shirt>(entityName: "Shirt")
    }

    @NSManaged public var isBought: Bool
    @NSManaged public var imageName: String?

}
