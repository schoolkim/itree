//
//  CoreDataStore.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/06/23.
//

import UIKit
import CoreData

class CoreDataStore {
    static let shared = CoreDataStore()
    
    private init() { }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Todo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createTodo(text: String?, date: Date?) -> Todo {
        let newTodo = Todo(context: persistentContainer.viewContext)
        newTodo.createdAt = Date()
        newTodo.updateAt = Date()
        newTodo.todoAt = date
        newTodo.content = text
        newTodo.completed = false
        newTodo.fix = false
        newTodo.uuid = UUID()
        saveContext()
        return newTodo
    }
    
    func fetchTodo() -> [Todo] {
        do {
            return try persistentContainer.viewContext.fetch(Todo.fetchRequest()).sorted {
                ($0.todoAt ?? Date() < $1.todoAt ?? Date())
            }
        } catch {
            print("error")
        }
        return []
    }
    
    func deleteTodo(object: Todo) {
        persistentContainer.viewContext.delete(object)
        saveContext()
    }
    
    func updateTodo() {
        let list = self.fetchTodo()
        let todoList = list.filter {
            // 완료했거나 날짜가 지난 todo들 중 현재와 todo의 day가 다르고 고정하지 않은 todo를 걸러낸다
            ($0.completed == true || $0.todoAt ?? Date() < Date()) && $0.createdAt?.day ?? 0 != Date().day && !$0.fix
        }
        todoList.forEach { element in
            persistentContainer.viewContext.delete(element)
        }
        list.forEach { element in
            if element.todoAt ?? Date() < Date() , element.createdAt?.day ?? 0 != Date().day {
                if element.fix , element.completed {
                    element.completed.toggle()
                }
            }
        }
        saveContext()
    }
}
