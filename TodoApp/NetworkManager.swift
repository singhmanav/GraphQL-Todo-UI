//
//  NetworkManager.swift
//  TodoApp
//
//  Created by Manav Prakash on 24/09/24.
//

import Foundation

class NetworkManager {
  static let shared = NetworkManager()
  
  private init() {}
  
  func makeAPICall<Input, Output:Decodable>(_ payload: Payload<Input>) async throws -> Output {
    let url = URL(string: "http://127.0.0.1:8080/graphql")
    var urlRequest = URLRequest(url: url!)
    urlRequest.httpBody = try! JSONEncoder().encode(payload)
    urlRequest.httpMethod = "POST"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    do {
      let (data,_) = try await URLSession.shared.data(for: urlRequest)
      return try JSONDecoder().decode(Output.self, from: data)
    }
    catch let e {
      throw e
    }
  }
}


struct Payload<Input: Encodable>: Encodable {
    let query: String
    let variables: Input?
    
    private enum CodingKeys: String, CodingKey {
        case query, variables
    }

    init(query: String, variables: Input?) {
        self.query = query
        self.variables = variables
    }
}
