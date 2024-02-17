//
//  TasksViewController.swift
//  DoPlansApp
//
//  Created by Serge Bowski on 2/15/24.
//

import UIKit
import RealmSwift

final class TasksViewController: UITableViewController {
    
    var taskList: TaskList!
    
    private let storageManager = StorageManager.shared
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGraySpecial
        title = taskList.title
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
        
        setBlurredNavBar()
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
        content.textProperties.color = .white
        content.secondaryText = task.note
        content.secondaryTextProperties.color = .white
        
        cell.backgroundColor = .systemGraySpecial
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TasksViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var task = taskList.tasks[indexPath.row]
        
        if indexPath.section == 0 {
            task = currentTasks[indexPath.row]
        } else {
            task = completedTasks[indexPath.row]
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
            storageManager.done(task, withNewState: !task.isComplete)
            tableView.reloadData()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        if !task.isComplete {
            doneAction.title = "Done"
        } else {
            doneAction.title = "Undone"
        }
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showAlert(with: taskList.tasks[indexPath.row]) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        let attributedString = NSAttributedString(
            string: header.textLabel?.text ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        header.textLabel?.attributedText = attributedString
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
                        storageManager.edit(task, newTitle: taskTitle, newNote: taskNote)
                        completion()
                        return
                    }
                    createTask(withTitle: taskTitle, andNote: taskNote)
                }
                .addAction(title: "Cancel", style: .destructive)
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
    }
    
    private func createTask(withTitle title: String, andNote note: String) {
        storageManager.save(title, withNote: note, to: taskList) { task in
            let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}

// MARK: - UI Improvements
extension TasksViewController {
    private func setBlurredNavBar() {
        let appearance = UINavigationBarAppearance()

        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}
