//
//  TaskModel.swift
//  MyPlanner
//
//  Created by eric on 5/8/19.
//  Copyright © 2019 Richard. All rights reserved.
//

import Foundation

class TaskModel {
    
    private var pid = 0
    private var id = 0
    private var name = ""
    private var notes = ""
    private var enddate = Date()
    private var toggle = true
    private var progress = "0"
    
    init() {
        self.pid = 0
        self.id = 0
        self.name = ""
        self.notes = ""
        self.enddate = Date()
        self.toggle = true
        self.progress = "0"
    }
    
    init(pid: Int, id: Int, name: String, notes: String, enddate: Date,toggle: Bool, progress: String) {
        self.pid = pid
        self.id = id
        self.name = name
        self.notes = notes
        self.enddate = enddate
        self.toggle = toggle
        self.progress = progress
    }
    
    public func getPid() -> Int {
        return pid
    }
    
    public func getId() -> Int {
        return id
    }
    
    public func getName() -> String {
        return name
    }
    
    public func getNotes() -> String {
        return notes
    }
    
    public func getEnddate() -> Date {
        return enddate
    }
    
    public func getToggle() -> Bool {
        return toggle
    }
    
    public func getProgress() -> String {
        return progress
    }
}
