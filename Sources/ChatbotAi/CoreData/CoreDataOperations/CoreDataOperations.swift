//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/8/24.
//

import Foundation

public protocol MessagesStorage {
    func fetchMessages(roomId: Int) -> [Choice]
    func saveMessages(_ messages: String, _ roomId: Int, _ senderType: String)
//    func getOrCreateRoom(with rooId: Int64) -> Room
    func fetchRooms() -> [Room]
    func createNewRoom(roomName: String) -> Room
}


public class DefaultMessageStorage: MessagesStorage {
    
    private let coreDataWrapper: CoreDataWrapping
    
    public init(coreDataWrapper: CoreDataWrapping) {
        self.coreDataWrapper = coreDataWrapper
    }
    
    
    public func saveMessages(_ messages: String, _ roomId: Int, _ senderType: String) {
        let room = fetchRoom(with: Int64(roomId)) ?? ensureRoom(with: Int64(roomId), roomName: "")
        let object = coreDataWrapper.createObject(ofType: MessageModel.self)
        object.id = UUID()
        object.content = messages
        object.room = room
        object.timestamp = Date()
        object.senderType = senderType
        coreDataWrapper.saveContext()
    }
    
    public func fetchMessages(roomId: Int) -> [Choice] {
        let predicate = \MessageModel.room.roomId == Int64(roomId)
        let objects = coreDataWrapper.fetchObjects(ofType: MessageModel.self, predicate: predicate)
        return objects.map {
            Choice(
                message: ChatMessage(role: $0.senderType, content: $0.content)
            )
        }
    }
    
//    public func getOrCreateRoom(with roomId: Int64) -> Room {
//        let predicate = NSPredicate(format: "roomId = %d", roomId)
//        let rooms = coreDataWrapper.fetchObjects(ofType: Room.self, predicate: predicate)
//
//        if let existingRoom = rooms.first {
//            print("Found existing room with ID: \(roomId)")
//            return existingRoom
//        } else {
//            print("Creating new room with ID: \(roomId)")
//            let newRoom = coreDataWrapper.createRoom(ofType: Room.self)
//            newRoom.roomId = roomId
//            coreDataWrapper.saveContext()
//            return newRoom
//        }
//    }
    
    public func ensureRoom(with roomId: Int64?, roomName: String?) -> Room {
        if let roomId = roomId, roomId != 0 {
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
        return createNewRoom(roomName: roomName ?? "Default")
    }
    
    public func createNewRoom(roomName: String) -> Room {
        let newRoom = coreDataWrapper.createRoom(ofType: Room.self)
        newRoom.roomId = generateRoomId()
        newRoom.name = roomName
        coreDataWrapper.saveContext()
        return newRoom
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
