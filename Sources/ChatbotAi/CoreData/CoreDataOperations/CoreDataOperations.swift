//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/8/24.
//

import Foundation

public protocol MessagesStorage {
    func fetchMessages() -> [Choice]
    func saveMessages(_ messages: String)
}


public class DefaultMessageStorage: MessagesStorage {
    
    private let coreDataWrapper: CoreDataWrapping
    
    public init(coreDataWrapper: CoreDataWrapping) {
        self.coreDataWrapper = coreDataWrapper
    }
    
    
    public func saveMessages(_ messages: String){
        let object = coreDataWrapper.createObject(ofType: MessageModel.self)
        object.content = messages
        coreDataWrapper.saveContext()
    }
    
    public func fetchMessages() -> [Choice] {
        let objects = coreDataWrapper.fetchObjects(ofType: MessageModel.self)
        return objects.map {
            Choice(
                message: ChatMessage(content: $0.content)
            )
        }
    }
    
}
