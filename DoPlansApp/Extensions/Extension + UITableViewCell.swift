//
//  Extension + UITableViewCell.swift
//  DoPlansApp
//
//  Created by Serge Bowski on 2/19/24.
//

import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTasks = taskList.tasks.filter("isComplete = false")
        var content = defaultContentConfiguration()
        
        content.text = taskList.title
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .white
        
        if taskList.tasks.isEmpty {
            content.secondaryText = "0"
            accessoryType = .none
        } else if currentTasks.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            content.secondaryText = currentTasks.count.formatted()
            accessoryType = .none
        }
        
        contentConfiguration = content
    }
}
