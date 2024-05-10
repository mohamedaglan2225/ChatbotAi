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
    func createRoom(roomId: Int, roomName: String)
}


public class DefaultMessageStorage: MessagesStorage {
    
    private let coreDataWrapper: CoreDataWrapping
    
    public init(coreDataWrapper: CoreDataWrapping) {
        self.coreDataWrapper = coreDataWrapper
    }
    
    
    public func saveMessages(_ messages: String, _ roomId: Int){
        let object = coreDataWrapper.createObject(ofType: MessageModel.self)
        object.content = messages
        object.room.roomId = Int64(roomId)
        coreDataWrapper.saveContext()
    }
    
    public func fetchMessages(roomId: Int) -> [Choice] {
        let objects = coreDataWrapper.fetchObjects(ofType: MessageModel.self, predicate: NSPredicate(format: "room.roomId == %d", roomId))
        return objects.map {
            Choice(
                message: ChatMessage(content: $0.content)
            )
        }
    }
    
    
    public func createRoom(roomId: Int, roomName: String) {
        let object = coreDataWrapper.createRoom(ofType: Room.self)
        object.roomId = generateRoomId()
        object.name = roomName
        
    }
    
    private func generateRoomId() -> Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
    
    
}
