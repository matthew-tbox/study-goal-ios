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
    var leftColumnArray:Array = ["Sessions on App", "Hours of Activity Logged","Targets Set","Targets Met","Targets Failed to Meet"]
    var rightColumnArray:Array = ["200","1000","50","25","1"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leftColumnTableView.register(UINib(nibName: "AppUsageCell", bundle: Bundle.main), forCellReuseIdentifier: "AppUsage")

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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
