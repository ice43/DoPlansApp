//
//  StorageManager.swift
//  DoPlansApp
//
//  Created by Serge Bowski on 2/15/24.
//

import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    // MARK: - Task List
    func fetchTaskList() -> [TaskList] {
        []
    }
    
    func save(_ taskLists: [TaskList]) {
        
    }
    
    func save(_ taskLists: String, completion: (TaskList) -> Void) {
        
    }
    
    func delete(_ taskLists: TaskList) {
        
    }
    
    func edit(_ taskLists: TaskList, newValue: String) {
        
    }
    
    func done(_ taskList: TaskList) {
        
    }
    
    // MARK: - Tasks
    func save(_ task: String, withNote note: String, to taskList: TaskList, completion: (Task) -> Void) {
        
    }
}
