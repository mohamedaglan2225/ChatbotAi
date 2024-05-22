//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/8/24.
//

import Foundation

public protocol MessagesStorage {
    func fetchMessages(roomId: Int) -> [Choice]
    func saveMessages(_ messages: String, _ roomId: Int)
    func getOrCreateRoom(with rooId: Int64) -> Room
    func fetchRooms() -> [Room]
}


public class DefaultMessageStorage: MessagesStorage {
    
    private let coreDataWrapper: CoreDataWrapping
    
    public init(coreDataWrapper: CoreDataWrapping) {
        self.coreDataWrapper = coreDataWrapper
    }
    
    
    public func saveMessages(_ messages: String, _ roomId: Int){
        let room = fetchRoom(with: Int64(roomId)) ?? ensureRoom(with: Int64(roomId))
        let object = coreDataWrapper.createObject(ofType: MessageModel.self)
        object.id = UUID()
        object.content = messages
        object.room = room
        object.timestamp = Date()
        coreDataWrapper.saveContext()
    }
    
    public func fetchMessages(roomId: Int) -> [Choice] {
        let predicate = \MessageModel.room.roomId == Int64(roomId)
        let objects = coreDataWrapper.fetchObjects(ofType: MessageModel.self, predicate: predicate)
        return objects.map {
            Choice(
                message: ChatMessage(content: $0.content)
            )
        }
    }
    
    
//    public func getOrCreateRoom(with roomId: Int64) -> Room {
//        let predicate = NSPredicate(format: "roomId = %d", roomId)
//        let rooms = coreDataWrapper.fetchObjects(ofType: Room.self, predicate: predicate)
//        
//        if let existingRoom = rooms.first {
//            return existingRoom
//        } else {
//            let newRoom = coreDataWrapper.createRoom(ofType: Room.self)
//            newRoom.roomId = roomId
//            coreDataWrapper.saveContext()
//            return newRoom
//        }
//    }
    
    
    public func getOrCreateRoom(with roomId: Int64) -> Room {
        let predicate = NSPredicate(format: "roomId = %d", roomId)  // Ensure the format specifier is correct
        let rooms = coreDataWrapper.fetchObjects(ofType: Room.self, predicate: predicate)

        if let existingRoom = rooms.first {
            print("Found existing room with ID: \(roomId)")
            return existingRoom
        } else {
            print("Creating new room with ID: \(roomId)")
            let newRoom = coreDataWrapper.createRoom(ofType: Room.self)
            newRoom.roomId = roomId
            coreDataWrapper.saveContext()
            return newRoom
        }
    }
    
    public func ensureRoom(with roomId: Int64?) -> Room {
        if let roomId = roomId {
            // Attempt to fetch the existing room
            let predicate = NSPredicate(format: "roomId = %lld", roomId)
            let rooms = coreDataWrapper.fetchObjects(ofType: Room.self, predicate: predicate)
            if let existingRoom = rooms.first {
                print("Using existing room with ID: \(roomId)")
                return existingRoom
            }
        }
        // If roomId is nil or no room found, create a new one
        print("No existing room found, creating new room.")
        return createNewRoom()
    }
    
    private func createNewRoom() -> Room {
        let newRoom = coreDataWrapper.createRoom(ofType: Room.self)
        newRoom.roomId = generateRoomId()
        coreDataWrapper.saveContext()
        return newRoom
    }

    
    public func createRoomId() -> Int {
        let newRoom = self.getOrCreateRoom(with: generateRoomId())
        coreDataWrapper.saveContext()
        return Int(newRoom.roomId)
    }
    
    
    private func fetchRoom(with roomId: Int64) -> Room? {
        let predicate = NSPredicate(format: "roomId = %d", roomId)
        let rooms = coreDataWrapper.fetchObjects(ofType: Room.self, predicate: predicate)
        return rooms.first
    }
    
    
    public func fetchRooms() -> [Room] {
        let objects = coreDataWrapper.fetchObjects(ofType: Room.self)
        return objects
    }
    
    
    private func generateRoomId() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
  
    
    
}
