//
//  TaskList.swift
//  DoPlansApp
//
//  Created by Serge Bowski on 2/15/24.
//

import Foundation

final class TaskList {
    var title = ""
    var date = Date()
    var tasks = [Task]()
}

final class Task {
    var title = ""
    var note = ""
    var date = Date()
    var isComplete = false
}
