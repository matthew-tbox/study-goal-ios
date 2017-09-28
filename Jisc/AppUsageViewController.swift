//
//  AppUsageViewController.swift
//  Jisc
//
//  Created by Therapy Box on 05/09/2017.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class AppUsageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var leftColumnTableView: UITableView!
    var leftColumnArray:Array = ["Targets Met","Targets Failed to Meet","Targets Set","Hours of Activity Logged","Sessions on App"]
    var rightColumnArray:Array = ["0","0","0","0","0"]
    
    @IBOutlet weak var targetsMet: LocalizableLabel!
    @IBOutlet weak var targetsFailed: LocalizableLabel!
    @IBOutlet weak var targetsSet: LocalizableLabel!
    @IBOutlet weak var activites: LocalizableLabel!
    @IBOutlet weak var sessions: LocalizableLabel!
    
    @IBOutlet weak var startDateField: UITextField!
    var startDatePicker = UIDatePicker()
    
    @IBOutlet weak var endDateField: UITextField!
    var endDatePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        customiseLayout()
    
        loadData()
    }

    @IBAction func openMenu(_ sender: Any) {
        DELEGATE.menuView?.open()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppUsage", for: indexPath) as! AppUsageCell
        cell.leftLabel.text = leftColumnArray[indexPath.row]
        cell.rightLabel.text = rightColumnArray[indexPath.row]
        //cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.leftLabel.font = UIFont(name: "System", size: 12.0)
        cell.rightLabel.font = UIFont(name: "System", size: 12.0)

        return cell

    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppUsage", for: indexPath) as! AppUsageCell
        cell.leftLabel.text = leftColumnArray[indexPath.row]
        cell.rightLabel.text = rightColumnArray[indexPath.row]
        //cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.leftLabel.font = UIFont(name: "System", size: 12.0)
        cell.rightLabel.font = UIFont(name: "System", size: 12.0)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func customiseLayout(){
        startDateField.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        startDateField.layer.borderWidth = 1.5
        startDateField.layer.cornerRadius = 8
        startDateField.layer.masksToBounds = true
   
        startDatePicker.datePickerMode = UIDatePickerMode.date
        let startToolbar = UIToolbar()
        startToolbar.sizeToFit()
        let startDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(startDatePickerDone))
        startToolbar.setItems([startDoneButton], animated: true)
        startDateField.inputAccessoryView = startToolbar
        startDateField.inputView = startDatePicker
        
        endDateField.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        endDateField.layer.borderWidth = 1.5
        endDateField.layer.cornerRadius = 8
        endDateField.layer.masksToBounds = true
        
        endDatePicker.datePickerMode = UIDatePickerMode.date
        let endToolbar = UIToolbar()
        endToolbar.sizeToFit()
        let endDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endDatePickerDone))
        endToolbar.setItems([endDoneButton], animated: true)
        endDateField.inputAccessoryView = endToolbar
        endDateField.inputView = endDatePicker
        
    }
    
    func startDatePickerDone(){
        //TODO format date
        startDateField.text = "\(startDatePicker.date)"
        self.view.endEditing(true)
        if(endDateField.text != "End"){
            loadData()
        }
    }
    
    func endDatePickerDone(){
        //TODO format date
        endDateField.text = "\(endDatePicker.date)"
        self.view.endEditing(true)
        if(startDateField.text != "Start"){
            loadData()
        }
    }
    
    func loadData(){
        let manager = xAPIManager()
        if(startDateField.text != "Start" && endDateField.text != "End") {
            manager.getAppUsage(studentId: dataManager.currentStudent!.id, startDate: startDateField.text!, endDate: endDateField.text!)
        }
        else{
            manager.getAppUsage(studentId: dataManager.currentStudent!.id, startDate: "null", endDate: "null")
        }
        
        let defaults = UserDefaults.standard
        self.targetsMet.text = "Targets met on time: \(defaults.string(forKey: "AppUsage_targets_met") ?? "null"))"
        self.targetsFailed.text = "Targets not met on time: \(defaults.string(forKey: "AppUsage_targets_failed") ?? "null")"
        self.targetsSet.text = "Targets not met on time: \(defaults.string(forKey: "AppUsage_targets_set") ?? "null")"
        self.activites.text = "Hours of activites logged: \(defaults.string(forKey: "AppUsage_activities") ?? "null")"
        self.sessions.text = "Sessions: \(defaults.string(forKey: "AppUsage_sessions") ?? "null")"
    }
}
