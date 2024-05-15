//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/7/24.
//

import Foundation
import CoreData


@objc(MessageModel)
public final class MessageModel: NSManagedObject, Object {
    @NSManaged public var content: String
    @NSManaged public var timestamp: Date
    @NSManaged public var room: Room

    public static func fetchRequest() -> NSFetchRequest<MessageModel> {
        return NSFetchRequest<MessageModel>(entityName: "MessageModel")
    }
}

@objc(Room)
public final class Room: NSManagedObject, Object {
    @NSManaged public var name: String?
    @NSManaged public var messages: Set<MessageModel>?
    @NSManaged public var roomId: Int64

    public static func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }
}

extension Room {
    @objc(addMessagesObject:)
    public func addToMessages(_ value: MessageModel) {
        self.willChangeValue(forKey: "messages")
        var tempSet: NSMutableSet
        if let existingMessages = self.mutableSetValue(forKey: "messages") as? NSMutableSet {
            tempSet = existingMessages
        } else {
            tempSet = NSMutableSet()
        }
        tempSet.add(value)
        self.setPrimitiveValue(tempSet, forKey: "messages")
        self.didChangeValue(forKey: "messages")
    }
}
