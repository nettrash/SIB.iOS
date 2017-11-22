//
//  Address+CoreDataProperties.swift
//  sib-lite
//
//  Created by Иван Алексеев on 11.10.2017.
//  Copyright © 2017 NETTRASH. All rights reserved.
//
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var address: String
	@NSManaged public var type: Int16
	
}
