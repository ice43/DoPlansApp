//
//  TaskListViewController.swift
//  DoPlansApp
//
//  Created by Serge Bowski on 2/15/24.
//

import UIKit
import RealmSwift

final class TaskListViewController: UITableViewController {
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    private var taskLists: Results<TaskList>!
    private let storageManager = StorageManager.shared
    private let dataManager = DataManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGraySpecial
        
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.black],
            for: .selected
        )
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = editButtonItem
        
        createTempData()
        taskLists = storageManager.fetchData(TaskList.self)
        setBlurredNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction private func sortingList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
            ? taskLists.sorted(byKeyPath: "date")
            : taskLists.sorted(byKeyPath: "title")
        tableView.reloadData()
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    private func createTempData() {
        if !UserDefaults.standard.bool(forKey: "done") {
            dataManager.createTempData { [unowned self] in
                UserDefaults.standard.setValue(true, forKey: "done")
                tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let taskList = taskLists[indexPath.row]
        
        cell.configure(with: taskList)
        cell.backgroundColor = .systemGraySpecial
        return  cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
            storageManager.done(taskList)
        
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark

            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - Navigation
extension TaskListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let tasksVC = segue.destination as? TasksViewController else { return }
        let taskList = taskLists[indexPath.row]
        tasksVC.taskList = taskList
    }
}

// MARK: - AlertController
extension TaskListViewController {
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: taskList != nil ? "Edit List" : "New List",
            message: "Please set title for new task list"
        )
        
        alertBuilder
            .setTextField(withPlaceholder: "List Title", andText: taskList?.title)
            .addAction(title: taskList != nil ? "Update List" : "Save List", style: .default) {
                [unowned self] newValue, _ in
                if let taskList, let completion {
                    storageManager.edit(taskList, newValue: newValue)
                    completion()
                    return
                }
                createTaskList(withTitle: newValue)
            }
            .addAction(title: "Cancel", style: .destructive)
            .setBlurView()
        
        let alertController = alertBuilder.build()

        present(alertController, animated: true)
    }
    
    private func createTaskList(withTitle title: String) {
        storageManager.save(title) { taskList in
            let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}

// MARK: - UI Improvements
extension TaskListViewController {
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



