//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/8/24.
//

import Foundation

public struct ChatBotAI {
    
    static var apiKey: String = ""
    
    public static func configure(withKey key: String) {
        guard !key.isEmpty else {
            print("ChatBotAI::", "You can't provide an empty key")
            return
        }
        apiKey = key
    }
    
}
