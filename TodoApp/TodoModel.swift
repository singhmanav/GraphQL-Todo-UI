//
//  TodoModel.swift
//  TodoApp
//
//  Created by Manav Prakash on 24/09/24.
//

import SwiftUI

class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    @Published var newTaskTitle: String = ""

    private var networkManager: NetworkManager
    
    init() {
      self.networkManager = NetworkManager.shared
        fetchTodos()
    }
    
    // Fetch all tasks using GraphQL query
    func fetchTodos(){
      let query = """
                    query GetAllTodos {
                      todos {
                        id
                        title
                        isCompleted
                      }
                    }
"""
      let payload = Payload<String?>(query: query, variables: nil)
      Task { @MainActor in
        do {
          let response: TodosResponse = try await networkManager.makeAPICall(payload)
          items = response.data.todos
        }
        catch {
          
        }
      }
    }

    // Add new task using GraphQL mutation
    func addNewTask() {
        
    }

    // Toggle completion using GraphQL mutation
    func toggleCompletion(item: TodoItem) {
        
    }

    // Delete task using GraphQL mutation
    func deleteTask(at offsets: IndexSet) {
        
    }
}
