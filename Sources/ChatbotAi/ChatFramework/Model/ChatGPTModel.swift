//
//  ChatGPTModel.swift
//
//
//  Created by Mohamed Aglan on 5/8/24.
//

import Foundation

public struct ChatGPTModel: Decodable {
    var id: String?
    var object: String?
    var created: TimeInterval?
    var model: String?
    var choices: [Choice]?
    var usage: Usage?
    var systemFingerprint: String?

    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}


public struct Choice: Decodable {
    var index: Int?
    var message: ChatMessage?
    var logprobs: String?
    var finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index, message, logprobs
        case finishReason = "finish_reason"
    }
}

public struct ChatMessage: Decodable {
    var role: String?
    var content: String?
}

public struct Usage: Codable {
    var promptTokens: Int?
    var completionTokens: Int?
    var totalTokens: Int?

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

