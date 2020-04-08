//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 06.04.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tasks = CoreDataManager.shared.retrieveData()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showAlert(title: "Edit Task", message: "Forgot something?", forCellAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataManager.shared.deleteTask(tasks[indexPath.row])
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        
        // Set large title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            
            let titleTextAttributes: [NSAttributedString.Key : Any] = [.foregroundColor : UIColor.white]
            navBarAppearance.titleTextAttributes = titleTextAttributes
            navBarAppearance.largeTitleTextAttributes = titleTextAttributes
            
            navBarAppearance.backgroundColor = UIColor(
                red: 21/255,
                green: 101/255,
                blue: 192/255,
                alpha: 194/255
            )
            
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New Task", message: "What do you want to do?")
    }
    
    private func showAlert(title: String, message: String, forCellAt indexPath: IndexPath? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty")
                return
            }
            
            if let validPath = indexPath {
                self.update(taskAt: validPath, with: task)
            } else {
                self.save(task)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField() { (textField) in
            if let index = indexPath?.row {
                textField.text = self.tasks[index].name
            }
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - Core Data Methods
extension TaskListViewController {
    private func save(_ taskName: String) {
        
        if (tasks.map{ $0.name }.contains(taskName)) { return }
        
        CoreDataManager.shared.createTask(taskName) { task in
            self.tasks.append(task)
        }
        let cellIndex = IndexPath(row: self.tasks.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func update(taskAt indexPath: IndexPath, with newValue: String) {
        CoreDataManager.shared.updateTask(tasks[indexPath.row], with: newValue)
        
        if let editedCell = tableView.cellForRow(at: indexPath) {
            editedCell.textLabel?.text = tasks[indexPath.row].name
        }
    }
}
