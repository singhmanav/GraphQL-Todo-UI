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
  func addNewTask(title: String) {
    let query = """
                    mutation createTodo($title: String!) {
                      createTodo(title: $title) {
                        id
                        title
                        isCompleted
                      }
                    }
"""
    struct AddTaskVariable: Encodable {
      let title: String
    }
    let variable = AddTaskVariable(title: title)
    let payload = Payload(query: query, variables: variable)
    Task { @MainActor in
      do {
        let response: CreateTodoResponse = try await networkManager.makeAPICall(payload)
        items.append(response.data.createTodo)
      }
      catch {
        
      }
    }
  }
  
  // Toggle completion using GraphQL mutation
  func toggleCompletion(item: TodoItem) {
    let query = """
                    mutation updateCompletion($id:UUID!, $isCompleted:Boolean!) {
                      updateCompletion(id:$id, isCompleted: $isCompleted)
                    }
"""
    struct ToggleCompletionVariable: Encodable {
      let id: UUID
      let isCompleted: Bool
    }
    var completed: Bool = item.isCompleted
    completed.toggle()
    let payload = Payload(query: query, variables: ToggleCompletionVariable(id: item.id, isCompleted: completed))
    Task { @MainActor in
      do {
        var item = item
        item.isCompleted.toggle()
        let _: ToggleTodoResponse = try await networkManager.makeAPICall(payload)
        if let index = items.firstIndex(where: { $0.id == item.id }) {
          items[index] = item
        }
      }
      catch let e {
        print(e.localizedDescription)
      }
    }
  }
  
  // Delete task using GraphQL mutation
  func deleteTask(at offsets: IndexSet) {
    let query = """
                    mutation deleteTodo($id: UUID!) {
                      deleteTodo(id: $id)
                    }
"""
    struct DeleteTaskVariable: Encodable {
      var id: UUID
    }
    
    let idsToDelete = offsets.map { self.items[$0].id }
    idsToDelete.forEach { value in
      let variable = DeleteTaskVariable(id: value)
      let payload = Payload(query: query, variables: variable)
      Task { @MainActor in
        do {
          let _: DeleteTodoResponse = try await networkManager.makeAPICall(payload)
          items.removeAll(where: {$0.id == value})
        }
        catch {
          
        }
      }
      
    }
  }
}
