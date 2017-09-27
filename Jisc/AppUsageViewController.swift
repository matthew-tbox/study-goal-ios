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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leftColumnTableView.register(UINib(nibName: "AppUsageCell", bundle: Bundle.main), forCellReuseIdentifier: "AppUsage")
        //loadData() { () in
        let manager = xAPIManager()
        manager.getAppUsage(studentId: dataManager.currentStudent!.id)
            let defaults = UserDefaults.standard
            self.rightColumnArray.removeAll()
            self.rightColumnArray.append(defaults.string(forKey: "AppUsage_targets_met") ?? "null")
            self.rightColumnArray.append(defaults.string(forKey: "AppUsage_targets_failed") ?? "null")
            self.rightColumnArray.append(defaults.string(forKey: "AppUsage_targets_set") ?? "null")
            self.rightColumnArray.append(defaults.string(forKey: "AppUsage_activities") ?? "null")
            self.rightColumnArray.append(defaults.string(forKey: "AppUsage_sessions") ?? "null")

            self.leftColumnTableView.reloadData()
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
    
    func loadData(completed: @escaping () -> ()){
        let manager = xAPIManager()
        manager.getAppUsage(studentId: "13")
    }
}
