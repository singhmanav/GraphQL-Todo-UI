//
//  ContentView.swift
//  TodoApp
//
//  Created by Manav Prakash on 24/09/24.
//

import SwiftUI

import SwiftUI

// Model for To-Do items
struct TodoItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

struct TodosResponse: Codable {
    let data: TodosData
}

struct TodosData: Codable {
    let todos: [TodoItem]
}

// Main ContentView
struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // New Task Input
                HStack {
                    TextField("Enter new task", text: $viewModel.newTaskTitle)
                        .padding(.horizontal)
                        .frame(height: 45)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    Button(action: {
                        viewModel.addNewTask()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.trailing)
                    }
                }
                .padding(.top)

                // Task List
                List {
                    ForEach(viewModel.items) { item in
                        HStack {
                            Button(action: {
                                viewModel.toggleCompletion(item: item)
                            }) {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isCompleted ? .green : .gray)
                                    .animation(.easeIn)
                            }

                            Text(item.title)
                                .strikethrough(item.isCompleted)
                                .foregroundColor(item.isCompleted ? .gray : .primary)
                                .animation(.easeIn)
                        }
                        .padding(.vertical, 10)
                    }
                    .onDelete(perform: viewModel.deleteTask)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("To-Do List")
            .navigationBarItems(trailing: refreshButton) // Edit button for deleting tasks
        }
    }
  
  var refreshButton: some View {
    return Button {
      viewModel.fetchTodos()
    } label: {
      Image(systemName: "arrow.clockwise")
    }

  }
}

// Preview for SwiftUI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
