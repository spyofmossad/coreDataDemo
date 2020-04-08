//
//  CoreDataManager.swift
//  CoreDataDemo
//
//  Created by Dmitry on 07.04.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager {
    
    static let shared = CoreDataManager()
        
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
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
    
    func retrieveData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            return try self.persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
        
        return []
    }
    
    func createTask(_ taskName: String, with complition: @escaping (Task) -> ()) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: self.persistentContainer.viewContext)
            else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: self.persistentContainer.viewContext) as? Task
            else { return }
        task.name = taskName
        
        do {
            try self.persistentContainer.viewContext.save()
            complition(task)
        } catch let error {
            print(error)
        }
    }
    
    func deleteTask(_ task: Task) {
        self.persistentContainer.viewContext.delete(task)
        saveContext()
    }
    
    func updateTask(_ task: Task, with newValue: String) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name = %@", task.name!)
        do {
            if let result = try persistentContainer.viewContext.fetch(fetchRequest).first {
                result.name = newValue
            }
            saveContext()
            
        } catch let error {
            print(error)
        }
    }
    
}
