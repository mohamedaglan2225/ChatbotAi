//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/8/24.
//

import Foundation

public class Networking {
    
    public func sendChatRequest(prompt: String, apiKey: String, completion: @escaping (Result<ChatGPTModel, Error>) -> Void) {
        
        let headers = [
            "Authorization": "Bearer \(ChatBotAI.apiKey)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo-0125",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        guard let requestData = try? JSONSerialization.data(withJSONObject: parameters) else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize JSON"])
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = requestData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if let error = error {
                    print("Error: \(error)")
                    completion(.failure(error))
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                }
                return
            }
            do {
                printApiResponse(data)
                let decoder = JSONDecoder()
                let response = try decoder.decode(ChatGPTModel.self, from: data)
                completion(.success(response))
            } catch {
                print("Error decoding response: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func sendAudioFileToOpenAI(audioData:Data, model: String, apiKey: String, completion: @escaping (Result<TranscriptionResponse, Error>) -> Void) {
        // Prepare the request URL
        let urlString = "https://api.openai.com/v1/audio/transcriptions"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set authorization header
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: ChatBotAI.apiKey)
        
//        -H "Authorization: Bearer $OPENAI_API_KEY" \
//          -H "Content-Type: multipart/form-data" \
//          -F file="@/path/to/file/audio.mp3" \
//          -F model="whisper-1"
        
        // Prepare parameters
        let parameters = ["model": model]
        
        // Create the boundary for multipart form data
        let boundary = UUID().uuidString
        
        // Set content type with boundary
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Create the body of the request
        var body = ""
        
        // Add audio file data
        body += "--\(boundary)\r\n"
        body += "Content-Disposition: form-data; name=\"file\"; filename=\"file\"\r\n"
        body += "Content-Type: audio/wav\r\n\r\n"
        
        body += String(data: audioData, encoding: .utf8) ?? ""
        
        // Add other parameters
        for (key, value) in parameters {
            body += "\r\n--\(boundary)\r\n"
            body += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
            body += "\(value)"
        }
        
        body += "\r\n--\(boundary)--\r\n"
        
        // Set the request body
        request.httpBody = body.data(using: .utf8)
        
        // Create URLSessionDataTask to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            print("data is \(data)")
//            print("response is \(response)")
//            print("error is \(error)")
            guard let data = data, let _ = response as? HTTPURLResponse, error == nil else {
                completion(.failure(error ?? NetworkError.unknown))
                return
            }
            
//            guard (200...299).contains(response.statusCode) else {
//                completion(.failure(NetworkError.statusCode(response.statusCode)))
//                return
//            }
            
            do {
                // Decode the response data
                let decoder = JSONDecoder()
                let transcriptionResponse = try decoder.decode(TranscriptionResponse.self, from: data)
                completion(.success(transcriptionResponse))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
        
        // Start the data task
        task.resume()
    }
    
    
}

private func printApiResponse(_ responseData: Data?) {
    guard let responseData = responseData else {
        print("\n\n====================================\n⚡️⚡️RESPONSE IS::\n" ,responseData as Any, "\n====================================\n\n")
        return
    }
    
    if let object = try? JSONSerialization.jsonObject(with: responseData, options: []),
       let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]), let JSONString = String(data: data, encoding: String.Encoding.utf8) {
        print("\n\n====================================\n⚡️⚡️RESPONSE IS::\n" ,JSONString, "\n====================================\n\n")
        return
    }
    print("\n\n====================================\n⚡️⚡️RESPONSE IS::\n" ,responseData, "\n====================================\n\n")
}


// Define a struct for TranscriptionResponse if not already defined
struct TranscriptionResponse: Codable {
    // Define properties based on the response structure
    let text: String
}

// Define custom error types if needed
enum NetworkError: Error {
    case invalidURL
    case invalidFile
    case statusCode(Int)
    case unknown
}
