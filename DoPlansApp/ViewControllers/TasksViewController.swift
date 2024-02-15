//
//  TasksViewController.swift
//  DoPlansApp
//
//  Created by Serge Bowski on 2/15/24.
//

import UIKit

final class TasksViewController: UITableViewController {
    
    var taskList: TaskList!
    
    private var currentTasks: [Task] = []
    private var completedTasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = taskList.title
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
}

// MARK: - UITableViewDataSource
extension TasksViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        content.text = task.title
        content.secondaryText = task.note
        
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - AlertController
extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: task != nil ? "Edit Task" : "New Task",
            message: "What do you want to do?"
        )
        
        alertBuilder
            .setTextField(withPlaceholder: "Task Title", andText: task?.title)
            .setTextField(withPlaceholder: "Note Title", andText: task?.note)
            .addAction(
                title: task != nil ? "Update Task" : "Save Task",
                style: .default) { [unowned self] taskTitle, taskNote in
                    if let task, let completion {
                        return
                    }
                    createTask(withTitle: taskTitle, andNote: taskNote)
                }
                .addAction(title: "Cancel", style: .destructive)
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
    }
    
    private func createTask(withTitle: String, andNote: String) {
        
    }
}
