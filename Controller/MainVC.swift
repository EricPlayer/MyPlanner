//
//  MainVC.swift
//  MyPlanner
//
//  Created by eric on 5/7/19.
//  Copyright © 2019 Richard. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController {
    
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var projectNewBtn: UIButton!
    @IBOutlet weak var projectTV: UITableView!
    
    var projectResults = [ProjectModel]()
    var curIdx = 0
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        appDel.deleteAllMyData()
        initTableView()
    }
    
    @IBAction func onViewCalendar(_ sender: UIButton) {
        performSegue(withIdentifier: "showCalendarSegue", sender: sender)
    }
    
    @IBAction func onNewProject(_ sender: UIButton) {
        performSegue(withIdentifier: "newProjectSegue", sender: sender)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailProjectSegue" {
            let vc = segue.destination as! DetailVC
            vc.selProjectId = curIdx
        } else if segue.identifier == "editProjectSegue" {
            let vc = segue.destination as! ProjectVC
            vc.selId = curIdx
        }
    }
    
    func initTableView() {
        let projectList: [Any] = appDel.retrieveProjectData()
        projectResults.removeAll()
        for data in projectList as![NSManagedObject] {
            let row = ProjectModel(id: data.value(forKey: "id") as! Int, name: data.value(forKey: "name") as! String, notes: data.value(forKey: "notes") as! String, startdate: data.value(forKey: "startdate") as! Date, enddate: data.value(forKey: "enddate") as! Date, priority: data.value(forKey: "priority") as! Int, toggle: data.value(forKey: "toggle") as! Bool)
            projectResults.append(row)
        }
        projectTV.reloadData()
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = projectResults.count
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTVCellID") as! ProjectTVCell
        cell.pNameLbl.text = projectResults[indexPath.row].getName()
        var priority : String = ""
        if Int(projectResults[indexPath.row].getPriority()) == 0 {
            priority = "Low"
            cell.pPriorityLbl.textColor = UIColor.blue
        } else if Int(projectResults[indexPath.row].getPriority()) == 1 {
            priority = "Medium"
            cell.pPriorityLbl.textColor = UIColor.magenta
        } else {
            priority = "High"
            cell.pPriorityLbl.textColor = UIColor.red
        }
        cell.pPriorityLbl.text = priority
        cell.pNotesLbl.text = projectResults[indexPath.row].getNotes()
        cell.pDuedateLbl.text = "Due: " + getFormatDate(curDate: projectResults[indexPath.row].getStartdate(), dateStyle: .medium) + " ~ " + getFormatDate(curDate: projectResults[indexPath.row].getEnddate(), dateStyle: .medium)
        cell.pToggle.isOn = projectResults[indexPath.row].getToggle()
        cell.pEditBtn.tag = projectResults[indexPath.row].getId()
        cell.pDelBtn.tag = projectResults[indexPath.row].getId()
        cell.pToggle.tag = projectResults[indexPath.row].getId()
        cell.pEditBtn.addTarget(self, action: #selector(self.onEditProject(_:)), for: .touchUpInside)
        cell.pDelBtn.addTarget(self, action: #selector(self.onDeleteProject(_:)), for: .touchUpInside)
        cell.pToggle.addTarget(self, action: #selector(self.onToggleProject(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.curIdx = projectResults[indexPath.row].getId()
        performSegue(withIdentifier: "detailProjectSegue", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func onEditProject(_ sender: UIButton) {
        self.curIdx = sender.tag
        performSegue(withIdentifier: "editProjectSegue", sender: nil)
    }
    
    @objc func onDeleteProject(_ sender: UIButton) {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.appDel.deleteProjectData(id: sender.tag)
            self.initTableView()
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
    
    @objc func onToggleProject(_ sender: UISwitch) {
        self.curIdx = sender.tag
        appDel.toggleProjectData(id: curIdx, toggle: sender.isOn)
    }
}
