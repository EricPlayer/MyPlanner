//
//  TaskVC.swift
//  MyPlanner
//
//  Created by eric on 5/7/19.
//  Copyright © 2019 Richard. All rights reserved.
//

import UIKit

class TaskVC: UIViewController {

    @IBOutlet weak var taskBackBtn: UIButton!
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var taskNotes: UITextField!
    @IBOutlet weak var taskEndDate: UITextField!
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    @IBOutlet weak var taskNotificationToggle: UISwitch!
    @IBOutlet weak var taskProgress: UITextField!
    @IBOutlet weak var taskProgStepper: UIStepper!
    @IBOutlet weak var taskSaveBtn: UIButton!
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    var toggle = true
    var pId = 0
    var selId = 0
    var curDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        curDate = taskDatePicker.date
        taskEndDate.text = getFormatDate(curDate: taskDatePicker.date, dateStyle: .medium)
        taskDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        if selId > 0 {
            let selTask = appDel.getCustomTaskItem(id: selId)
            taskName.text = selTask.value(forKey: "name") as? String
            taskNotes.text = selTask.value(forKey: "notes") as? String
            taskEndDate.text = getFormatDate(curDate: (selTask.value(forKey: "enddate") as! Date), dateStyle: .medium)
            taskDatePicker.setValue(selTask.value(forKey: "enddate") as? Date, forKey: "date")
            taskNotificationToggle.isOn = selTask.value(forKey: "toggle") as! Bool
            taskProgress.text = selTask.value(forKey: "progress") as? String
            let progress: Double = NSString(string: selTask.value(forKey: "progress") as! String).doubleValue
            taskProgStepper.value = progress
        }
    }
    
    @IBAction func onBackToMain(_ sender: UIButton) {
        performSegue(withIdentifier: "showDetailSegue", sender: sender)
    }
    
    @IBAction func onSaveTask(_ sender: UIButton) {
        if self.validationCheck() {
            let name: String = taskName.text!
            let notes: String = taskNotes.text!
            let progress: String = taskProgress.text!
            if selId > 0 {
                appDel.updateTaskData(id: selId, name: name, notes: notes, enddate: curDate, toggle: toggle, progress: progress)
            } else {
                appDel.saveTaskData(pid: pId, name: name, notes: notes, enddate: curDate, toggle: toggle, progress: progress)
            }
            performSegue(withIdentifier: "showDetailSegue", sender: sender)
        }
    }
    
    @IBAction func onChangeToggle(_ sender: UISwitch) {
        toggle = sender.isOn
    }
    
    @IBAction func onChangeStepper(_ sender: UIStepper) {
        taskProgress.text = String(Int(sender.value))
    }
    
    @objc func dateChanged(picker: UIDatePicker) {
        curDate = picker.date
        taskEndDate.text = getFormatDate(curDate: picker.date, dateStyle: .medium)
    }
    
    func validationCheck() -> Bool {
        if taskName.text == "" {
            taskName.layer.borderColor = UIColor.red.cgColor
            taskName.layer.borderWidth = 1
            return false
        }
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetailSegue" {
            let vc = segue.destination as! DetailVC
            vc.selProjectId = pId
        }
    }
}
