//
//  ProjectVC.swift
//  MyPlanner
//
//  Created by eric on 5/7/19.
//  Copyright © 2019 Richard. All rights reserved.
//

import UIKit

class ProjectVC: UIViewController {

    @IBOutlet weak var projectBackBtn: UIButton!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var projectNotes: UITextField!
    @IBOutlet weak var projectStartDate: UITextField!
    @IBOutlet weak var projectStartPicker: UIDatePicker!
    @IBOutlet weak var projectEndDate: UITextField!
    @IBOutlet weak var projectEndPicker: UIDatePicker!
    @IBOutlet weak var projectLowBtn: UIButton!
    @IBOutlet weak var projectMediumBtn: UIButton!
    @IBOutlet weak var projectHighBtn: UIButton!
    @IBOutlet weak var projectCalToggle: UISwitch!
    @IBOutlet weak var projectSaveBtn: UIButton!
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    var priority = 0
    var toggle = true
    var selId = 0
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        projectSaveBtn.layer.borderColor = UIColor.black.cgColor
        projectLowBtn.layer.borderColor = UIColor.darkGray.cgColor
        projectMediumBtn.layer.borderColor = UIColor.darkGray.cgColor
        projectHighBtn.layer.borderColor = UIColor.darkGray.cgColor
        projectLowBtn.roundedButton1()
        projectHighBtn.roundedButton2()
        startDate = projectStartPicker.date
        endDate = projectEndPicker.date
        projectStartDate.text = getFormatDate(curDate: projectStartPicker.date, dateStyle: .medium)
        projectEndDate.text = getFormatDate(curDate: projectEndPicker.date, dateStyle: .medium)
        projectStartPicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        projectEndPicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        
        if selId > 0 {
            let selProject = appDel.getCustomProjectItem(id: selId)
            projectName.text = selProject.value(forKey: "name") as? String
            projectNotes.text = selProject.value(forKey: "notes") as? String
            projectStartDate.text = getFormatDate(curDate: selProject.value(forKey: "startdate") as! Date, dateStyle: .medium)
            projectEndDate.text = getFormatDate(curDate: selProject.value(forKey: "enddate") as! Date, dateStyle: .medium)
            projectStartPicker.setValue(selProject.value(forKey: "startdate") as? Date, forKey: "date")
            projectEndPicker.setValue(selProject.value(forKey: "enddate") as? Date, forKey: "date")
            startDate = selProject.value(forKey: "startdate") as! Date
            endDate = selProject.value(forKey: "enddate") as! Date
            priority = (selProject.value(forKey: "priority") as? Int)!
            toggle = (selProject.value(forKey: "toggle") as? Bool)!
            projectCalToggle.isOn = toggle
            if priority == 0 {
                projectLowBtn.layer.backgroundColor = UIColor.lightGray.cgColor
                projectLowBtn.setTitleColor(.darkText, for: .normal)
                projectMediumBtn.layer.backgroundColor = UIColor.white.cgColor
                projectHighBtn.layer.backgroundColor = UIColor.white.cgColor
            } else if priority == 1 {
                projectMediumBtn.layer.backgroundColor = UIColor.lightGray.cgColor
                projectMediumBtn.setTitleColor(.darkText, for: .normal)
                projectLowBtn.layer.backgroundColor = UIColor.white.cgColor
                projectHighBtn.layer.backgroundColor = UIColor.white.cgColor
            } else {
                projectHighBtn.layer.backgroundColor = UIColor.lightGray.cgColor
                projectHighBtn.setTitleColor(.darkText, for: .normal)
                projectMediumBtn.layer.backgroundColor = UIColor.white.cgColor
                projectLowBtn.layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
    
    @IBAction func onBackToMain(_ sender: UIButton) {
        performSegue(withIdentifier: "ProjectToMainSegue", sender: sender)
    }

    @IBAction func onSelectLow(_ sender: UIButton) {
        projectLowBtn.layer.backgroundColor = UIColor.lightGray.cgColor
        projectLowBtn.setTitleColor(.darkText, for: .normal)
        projectMediumBtn.layer.backgroundColor = UIColor.white.cgColor
        projectHighBtn.layer.backgroundColor = UIColor.white.cgColor
        priority = 0;
    }
    
    @IBAction func onSelectMedium(_ sender: UIButton) {
        projectMediumBtn.layer.backgroundColor = UIColor.lightGray.cgColor
        projectMediumBtn.setTitleColor(.darkText, for: .normal)
        projectLowBtn.layer.backgroundColor = UIColor.white.cgColor
        projectHighBtn.layer.backgroundColor = UIColor.white.cgColor
        priority = 1;
    }
    
    @IBAction func onSelectHigh(_ sender: UIButton) {
        projectHighBtn.layer.backgroundColor = UIColor.lightGray.cgColor
        projectHighBtn.setTitleColor(.darkText, for: .normal)
        projectMediumBtn.layer.backgroundColor = UIColor.white.cgColor
        projectLowBtn.layer.backgroundColor = UIColor.white.cgColor
        priority = 2;
    }
    
    @IBAction func onChangeToggle(_ sender: UISwitch) {
        toggle = sender.isOn
    }
    
    @IBAction func onSaveProject(_ sender: UIButton) {
        if self.validationCheck() {
            let name: String = projectName.text!
            let notes: String = projectNotes.text!
            if selId > 0 {
                appDel.updateProjectData(id: selId, name: name, notes: notes, startdate: startDate, enddate: endDate, priority: priority, toggle: toggle)
            } else {
                appDel.saveProjectData(name: name, notes: notes, startdate: startDate, enddate: endDate, priority: priority, toggle: toggle)
            }
            performSegue(withIdentifier: "ProjectToMainSegue", sender: sender)
        }
    }
    
    @objc func startDateChanged(picker: UIDatePicker) {
        startDate = picker.date
        projectStartDate.text = getFormatDate(curDate: picker.date, dateStyle: .medium)
    }
    
    @objc func endDateChanged(picker: UIDatePicker) {
        endDate = picker.date
        projectEndDate.text = getFormatDate(curDate: picker.date, dateStyle: .medium)
    }
    
    func validationCheck() -> Bool {
        if projectName.text == "" {
            projectName.layer.borderColor = UIColor.red.cgColor
            projectName.layer.borderWidth = 1
            return false
        }
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

func getFormatDate(curDate: Date, dateStyle: DateFormatter.Style) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.dateStyle = dateStyle
    //        formatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
    let dateString = formatter.string(from: curDate)
    return dateString
}

extension UIButton {
    func roundedButton1() {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft, .bottomLeft],
                                     cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    func roundedButton2() {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topRight, .bottomRight],
                                    cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
