//
//  Todo+CoreDataProperties.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/06/23.
//
//

import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updateAt: Date?
    @NSManaged public var todoAt: Date?
    @NSManaged public var completed: Bool
    @NSManaged public var fix: Bool
    @NSManaged public var uuid: UUID?

}

extension Todo : Identifiable {

}
