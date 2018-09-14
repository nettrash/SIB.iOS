//
//  PersistentContainer.swift
//  todayExtension
//
//  Created by Иван Алексеев on 13.01.2018.
//  Copyright © 2018 NETTRASH. All rights reserved.
//

import Foundation
import CoreData

class PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL{
		return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ru.nettrash.sibcoinwallet")!
    }
}
