//
//  DetailVC.swift
//  MyPlanner
//
//  Created by eric on 5/7/19.
//  Copyright © 2019 Richard. All rights reserved.
//

import UIKit
import CoreData
import Charts

class DetailVC: UIViewController {

    @IBOutlet weak var projectNameLbl: UILabel!
    @IBOutlet weak var detailBackBtn: UIButton!
    @IBOutlet weak var taskNewBtn: UIButton!
    @IBOutlet weak var priorityLbl: UILabel!
    @IBOutlet weak var completionChart: PieChartView!
    @IBOutlet weak var timelineChart: PieChartView!
    @IBOutlet weak var taskTV: UITableView!
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    var selProjectId = 0;
    
    var taskResults = [TaskModel]()
    var curIdx = 0
    var completionRate = 0.0
    var timeRate = 0.0
    var timeLeft = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let projectInfo: NSManagedObject = appDel.getCustomProjectItem(id: selProjectId)
        projectNameLbl.text = projectInfo.value(forKey: "name") as? String
        let priority : String = (projectInfo.value(forKey: "priority") as! Int == 0) ? "Low" : ((projectInfo.value(forKey: "priority") as! Int == 1) ? "Medium" : "High")
        priorityLbl.text = "Priority - " + priority
        let dayDiff: Int = Calendar.current.dateComponents([.day], from: Date(), to: projectInfo.value(forKey: "enddate") as! Date).day ?? 0
        timeLeft = String(dayDiff)
        let totalDays: Int = Calendar.current.dateComponents([.day], from: projectInfo.value(forKey: "startdate") as! Date, to: projectInfo.value(forKey: "enddate") as! Date).day ?? 0
        timeRate = ( dayDiff <= 0 || totalDays <= 0 ) ? 0.0 : Double(dayDiff) / Double(totalDays) * 100.0
        
        let taskList: [Any] = appDel.retrieveTaskData(pid: selProjectId)
        taskResults.removeAll()
        var totalProgress = 0
        if taskList.count > 0 {
            for data in taskList as![NSManagedObject] {
                let row = TaskModel(pid: data.value(forKey: "pid") as! Int, id: data.value(forKey: "id") as! Int, name: data.value(forKey: "name") as! String, notes: data.value(forKey: "notes") as! String, enddate: data.value(forKey: "enddate") as! Date, toggle: data.value(forKey: "toggle") as! Bool, progress: data.value(forKey: "progress") as! String)
                taskResults.append(row)
                totalProgress += Int(data.value(forKey: "progress") as! String)!
                //            print(data.value(forKey: "name") as! String)
            }
            completionRate = Double(totalProgress) / Double(taskList.count)
            taskTV.reloadData()
        }
        
        setupPiechart()
    }
    
    @IBAction func onBackToMain(_ sender: UIButton) {
        performSegue(withIdentifier: "DetailToMainSegue", sender: sender)
    }
    
    @IBAction func onNewTask(_ sender: UIButton) {
        performSegue(withIdentifier: "newTaskSegue", sender: sender)
    }
    
    func setupPiechart() {
        completionChart.chartDescription?.enabled = false
        completionChart.drawHoleEnabled = false
        completionChart.rotationAngle = -90
        completionChart.rotationEnabled = false
        completionChart.isUserInteractionEnabled = false
        completionChart.highlightPerTapEnabled = false
        completionChart.usePercentValuesEnabled = false
        completionChart.drawEntryLabelsEnabled = false
        var legend = completionChart.legend
        legend.font = UIFont(name: "Verdana", size: 14.0)!
        var entries1: [PieChartDataEntry] = Array()
        entries1.append(PieChartDataEntry(value: completionRate, label: String(completionRate) + "% complete"))
        entries1.append(PieChartDataEntry(value: 100.0 - completionRate, label: ""))
        let dataSet1 = PieChartDataSet(values: entries1, label: "")
        dataSet1.colors = [NSUIColor.init(red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0), NSUIColor.init(red: 255.0, green: 255.0, blue: 255.0, alpha: 1.0)]
        dataSet1.drawValuesEnabled = false
        completionChart.data = PieChartData(dataSet: dataSet1)
        
        timelineChart.chartDescription?.enabled = false
        timelineChart.drawHoleEnabled = false
        timelineChart.rotationAngle = -90
        timelineChart.rotationEnabled = false
        timelineChart.isUserInteractionEnabled = false
        timelineChart.highlightPerTapEnabled = false
        timelineChart.usePercentValuesEnabled = false
        timelineChart.drawEntryLabelsEnabled = false
        legend = timelineChart.legend
        legend.font = UIFont(name: "Verdana", size: 14.0)!
        var entries2: [PieChartDataEntry] = Array()
        entries2.append(PieChartDataEntry(value: 100.0 - timeRate, label: timeLeft + " days left"))
        entries2.append(PieChartDataEntry(value: timeRate, label: ""))
        let dataSet2 = PieChartDataSet(values: entries2, label: "")
        dataSet2.colors = [NSUIColor.init(red: 0.0, green: 255.0, blue: 0.0, alpha: 1.0), NSUIColor.init(red: 255.0, green: 255.0, blue: 255.0, alpha: 1.0)]
        dataSet2.drawValuesEnabled = false
        timelineChart.data = PieChartData(dataSet: dataSet2)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newTaskSegue" {
            let vc = segue.destination as! TaskVC
            vc.pId = selProjectId
        } else if segue.identifier == "editTaskSegue" {
            let vc = segue.destination as! TaskVC
            vc.pId = selProjectId
            vc.selId = curIdx
        }
    }
}

extension DetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = taskResults.count
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTVCellID") as! TaskTVCell
        cell.tNameLbl.text = taskResults[indexPath.row].getName()
        cell.tNotesLbl.text = taskResults[indexPath.row].getNotes()
        cell.tEnddateLbl.text = "- Due: " + getFormatDate(curDate: taskResults[indexPath.row].getEnddate(), dateStyle: .medium)
        let progress: Double = NSString(string: taskResults[indexPath.row].getProgress()).doubleValue
        cell.tProgress.setValue(progress / 100, forKey: "progress")
        cell.tProgressLbl.text = taskResults[indexPath.row].getProgress() + "%"
        cell.tToggle.isOn = taskResults[indexPath.row].getToggle()
        cell.tEditBtn.tag = taskResults[indexPath.row].getId()
        cell.tDelBtn.tag = taskResults[indexPath.row].getId()
        cell.tToggle.tag = taskResults[indexPath.row].getId()
        cell.tEditBtn.addTarget(self, action: #selector(self.onEditTask(_:)), for: .touchUpInside)
        cell.tDelBtn.addTarget(self, action: #selector(self.onDeleteTask(_:)), for: .touchUpInside)
        cell.tToggle.addTarget(self, action: #selector(self.onToggleTask(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.curIdx = taskResults[indexPath.row].getId()
//        performSegue(withIdentifier: "detailProjectSegue", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func onEditTask(_ sender: UIButton) {
        self.curIdx = sender.tag
        performSegue(withIdentifier: "editTaskSegue", sender: nil)
    }
    
    @objc func onDeleteTask(_ sender: UIButton) {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.appDel.deleteTaskData(id: sender.tag)
            
            let taskList: [Any] = self.appDel.retrieveTaskData(pid: self.selProjectId)
            self.taskResults.removeAll()
            var totalProgress = 0
            if taskList.count > 0 {
                for data in taskList as![NSManagedObject] {
                    let row = TaskModel(pid: data.value(forKey: "pid") as! Int, id: data.value(forKey: "id") as! Int, name: data.value(forKey: "name") as! String, notes: data.value(forKey: "notes") as! String, enddate: data.value(forKey: "enddate") as! Date, toggle: data.value(forKey: "toggle") as! Bool, progress: data.value(forKey: "progress") as! String)
                    self.taskResults.append(row)
                    totalProgress += Int(data.value(forKey: "progress") as! String)!
                }
                self.completionRate = Double(totalProgress) / Double(taskList.count)
                self.taskTV.reloadData()
            }
            
            self.setupPiechart()
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    @objc func onToggleTask(_ sender: UISwitch) {
        self.curIdx = sender.tag
        appDel.toggleTaskData(id: curIdx, toggle: sender.isOn)
    }
}
