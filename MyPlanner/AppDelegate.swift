//
//  AppDelegate.swift
//  MyPlanner
//
//  Created by eric on 5/5/19.
//  Copyright © 2019 Richard. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge,.alert,.sound])
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Requesting for Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) {(success, error) in
            if error != nil {
                print("Authorization Unsuccessful")
            } else {
                
                
                let managedContext = self.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
                let predicateIsToggle = NSPredicate(format: "toggle == %@", NSNumber(value: true))
                let predicateDate = NSPredicate(format: "enddate <= %@ ", Date() as NSDate)
                let predicateProgress = NSPredicate(format: "progress <> \(100)")
                let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateIsToggle, predicateDate, predicateProgress])
               
                fetchRequest.predicate = andPredicate
                
                do {
                    let result = try managedContext.fetch(fetchRequest)
                    for data in result as! [NSManagedObject] {
                        let notificationContent = UNMutableNotificationContent()
                        notificationContent.title = "Task was not completed yet."
                        notificationContent.body = "Task Name: " + (data.value(forKey: "name") as! String) + "Task Progress: " + (data.value(forKey: "progress") as! String) + "%"
                        notificationContent.sound = UNNotificationSound.default
                        
                        let date = data.value(forKey: "enddate") as! Date
//                        let triggerDateTime: Date = Calendar.current.date(bySettingHour: 8, minute: 00, second: 0, of: date)!
                        let triggerDate = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                        //                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
                        
                        let request = UNNotificationRequest(identifier: "identifier", content: notificationContent, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request) {(error) in
                            print(error as Any)
                        }
                    }
                } catch let error as NSError {
                    print("Could not retrieve. \(error), \(error.userInfo)")
                }
            }
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MyPlanner")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveProjectData(name: String, notes: String, startdate: Date, enddate: Date, priority: Int, toggle: Bool) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let projectEntity = NSEntityDescription.entity(forEntityName: "Projects", in: managedContext)!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        var lastId = 0
        do {
            let allElementsCount = try managedContext.count(for: fetchRequest)
            if allElementsCount > 0 {
                fetchRequest.fetchLimit = 1
                fetchRequest.fetchOffset = allElementsCount - 1
                fetchRequest.returnsObjectsAsFaults = false
                let result = try managedContext.fetch(fetchRequest)
                let data = result[0] as! NSManagedObject
                lastId = data.value(forKey: "id") as! Int
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        let project = NSManagedObject(entity: projectEntity, insertInto: managedContext)
        project.setValue(lastId+1, forKeyPath: "id")
        project.setValue(name, forKeyPath: "name")
        project.setValue(notes, forKeyPath: "notes")
        project.setValue(startdate, forKeyPath: "startdate")
        project.setValue(enddate, forKeyPath: "enddate")
        project.setValue(priority, forKeyPath: "priority")
        project.setValue(toggle, forKeyPath: "toggle")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        let result = self.retrieveProjectData()
        for data in result as! [NSManagedObject] {
            let enddate: Date = data.value(forKey: "enddate") as! Date
            print("project name: " + getFormatDate(curDate: enddate, dateStyle: .full))
        }
    }
    
    func retrieveProjectData() -> [Any] {
        var result = [Any]()
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        do {
            result = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return result
    }
    
    func getCustomProjectItem(id: Int) -> NSManagedObject {
        var result: NSManagedObject? = nil
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            result = data[0] as? NSManagedObject
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return result!
    }
    
    func updateProjectData(id: Int, name: String, notes: String, startdate: Date, enddate: Date, priority: Int, toggle: Bool) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let updateObj = result[0] as? NSManagedObject
            updateObj?.setValue(name, forKey: "name")
            updateObj?.setValue(notes, forKey: "notes")
            updateObj?.setValue(startdate, forKey: "startdate")
            updateObj?.setValue(enddate, forKey: "enddate")
            updateObj?.setValue(priority, forKey: "priority")
            updateObj?.setValue(toggle, forKey: "toggle")
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not update. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
    }
    
    func deleteProjectData(id: Int) {
        
        let managedContext = self.persistentContainer.viewContext
        
        var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let deleteObj = result[0] as! NSManagedObject
            managedContext.delete(deleteObj)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
        
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "pid = %i", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if result.count > 0 {
                let deleteObj = result[0] as! NSManagedObject
                managedContext.delete(deleteObj)
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not delete. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func toggleProjectData(id: Int, toggle: Bool) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let updateObj = result[0] as? NSManagedObject
            updateObj?.setValue(toggle, forKey: "toggle")
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveTaskData(pid: Int, name: String, notes: String, enddate: Date, toggle: Bool, progress: String) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let taskEntity = NSEntityDescription.entity(forEntityName: "Tasks", in: managedContext)!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        
        var lastId = 0
        do {
            let allElementsCount = try managedContext.count(for: fetchRequest)
            if allElementsCount > 0 {
                fetchRequest.fetchLimit = 1
                fetchRequest.fetchOffset = allElementsCount - 1
                fetchRequest.returnsObjectsAsFaults = false
                let result = try managedContext.fetch(fetchRequest)
                let data = result[0] as! NSManagedObject
                lastId = data.value(forKey: "id") as! Int
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        let task = NSManagedObject(entity: taskEntity, insertInto: managedContext)
        task.setValue(lastId+1, forKeyPath: "id")
        task.setValue(pid, forKeyPath: "pid")
        task.setValue(name, forKeyPath: "name")
        task.setValue(notes, forKeyPath: "notes")
        task.setValue(enddate, forKeyPath: "enddate")
        task.setValue(toggle, forKeyPath: "toggle")
        task.setValue(progress, forKeyPath: "progress")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveTaskData(pid: Int) -> [Any] {
        var result = [Any]()
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "pid = %i", pid)
        
        do {
            result = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return result
    }
    
    func getCustomTaskItem(id: Int) -> NSManagedObject {
        var result: NSManagedObject? = nil
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            result = data[0] as? NSManagedObject
        } catch let error as NSError {
            print("Could not get. \(error), \(error.userInfo)")
        }
        return result!
    }
    
    func updateTaskData(id: Int, name: String, notes: String, enddate: Date, toggle: Bool, progress: String) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let updateObj = result[0] as? NSManagedObject
            updateObj?.setValue(name, forKey: "name")
            updateObj?.setValue(notes, forKey: "notes")
            updateObj?.setValue(enddate, forKey: "enddate")
            updateObj?.setValue(toggle, forKey: "toggle")
            updateObj?.setValue(progress, forKeyPath: "progress")
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not update. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
    }
    
    func toggleTaskData(id: Int, toggle: Bool) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let updateObj = result[0] as? NSManagedObject
            updateObj?.setValue(toggle, forKey: "toggle")
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteTaskData(id: Int) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let deleteObj = result[0] as! NSManagedObject
            managedContext.delete(deleteObj)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllMyData() {
        
        let managedContext = self.persistentContainer.viewContext
        
        var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        var DelAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
        
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        
        DelAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
    }
    
    func retrieveToggledProjects() -> [Any] {
        var result = [Any]()
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        fetchRequest.predicate = NSPredicate(format: "toggle == %@", NSNumber(value: true))
        
        do {
            result = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return result
    }
}

