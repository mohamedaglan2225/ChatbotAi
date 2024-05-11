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
    func getOrCreateRoom(with roomName: String) -> Room
}


public class DefaultMessageStorage: MessagesStorage {
    
    private let coreDataWrapper: CoreDataWrapping
    
    public init(coreDataWrapper: CoreDataWrapping) {
        self.coreDataWrapper = coreDataWrapper
    }
    
    
    public func saveMessages(_ messages: String, _ roomId: Int){
        let roomPredicate = NSPredicate(format: "roomId == %d", roomId)
        if let room = coreDataWrapper.fetchObjects(ofType: Room.self, predicate: roomPredicate).first {
            let object = coreDataWrapper.createObject(ofType: MessageModel.self)
            object.content = messages
            object.room = room
            coreDataWrapper.saveContext()
        }else {
            print("Room not found for given roomId")
        }
    }
    
    
    public func fetchMessages(roomId: Int) -> [Choice] {
        let int64RoomId = Int64(roomId)
        let predicate = NSPredicate(format: "room.roomId == %d", int64RoomId)
        let objects = coreDataWrapper.fetchObjects(ofType: MessageModel.self)
        return objects.map {
            Choice(
                message: ChatMessage(content: $0.content)
            )
        }
    }
    
    
    public func getOrCreateRoom(with roomName: String) -> Room {
        
        let predicate = NSPredicate(format: "name == %@", roomName)
        let rooms = coreDataWrapper.fetchObjects(ofType: Room.self, predicate: predicate)
        
        if let existingRoom = rooms.first {
            return existingRoom
        } else {
            let newRoom = coreDataWrapper.createRoom(ofType: Room.self)
            newRoom.roomId = generateRoomId()
            newRoom.name = roomName
            coreDataWrapper.saveContext()
            return newRoom
        }
        
        
//        let room = coreDataWrapper.createRoom(ofType: Room.self)
//        room.roomId = generateRoomId()  // Ensure unique roomId is generated here
//        room.name = roomName
//        coreDataWrapper.saveContext()   // Save the new room to CoreData
    }
    
    
    private func generateRoomId() -> Int64 {
        return Int64(Date().timeIntervalSince1970)  // Generates a unique ID based on the current timestamp
    }
    
    
}
