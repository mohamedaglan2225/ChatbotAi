//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/6/24.
//

import Foundation

public enum ServiceLocator {
    static let storage: CoreDataWrapping = CoreDataWrapper(modelName: "ChatBotAI")
}
