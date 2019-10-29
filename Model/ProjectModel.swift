//
//  ProjectModel.swift
//  MyPlanner
//
//  Created by eric on 5/8/19.
//  Copyright © 2019 Richard. All rights reserved.
//

import Foundation

class ProjectModel {
    
    private var id = 0
    private var name = ""
    private var notes = ""
    private var startdate = Date()
    private var enddate = Date()
    private var priority = 0
    private var toggle = true
    
    init() {
        self.id = 0
        self.name = ""
        self.notes = ""
        self.startdate = Date()
        self.enddate = Date()
        self.priority = 0
        self.toggle = true
    }
    
    init(id: Int, name: String, notes: String, startdate: Date, enddate: Date, priority: Int, toggle: Bool) {
        self.id = id
        self.name = name
        self.notes = notes
        self.startdate = startdate
        self.enddate = enddate
        self.priority = priority
        self.toggle = toggle
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
    
    public func getStartdate() -> Date {
        return startdate
    }
    
    public func getEnddate() -> Date {
        return enddate
    }
    
    public func getPriority() -> Int {
        return priority
    }
    
    public func getToggle() -> Bool {
        return toggle
    }
}

