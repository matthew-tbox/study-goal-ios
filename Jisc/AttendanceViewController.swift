//
//  AttendanceViewController.swift
//  Jisc
//
//  Created by therapy box on 12/10/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class EventsAttendedObject {
    var date:String
    var time:String
    var activity:String
    var module:String
    
    init(date:String,time:String,activity:String,module:String){
        self.date = date
        self.time = time
        self.activity = activity
        self.module = module
    }
}

class AttendanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentControl:UISegmentedControl!
    @IBOutlet weak var attendanceAllView:UIView!
    @IBOutlet weak var attendanceSummaryView:UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var noDataWebViewLabel:UILabel!
    
    @IBOutlet weak var startDateFieldSummary:UITextField!
    @IBOutlet weak var endDateFieldSummary:UITextField!
    @IBOutlet weak var startDateFieldAll:UITextField!
    @IBOutlet weak var endDateFieldAll:UITextField!
    
    var attendanceData = [EventsAttendedObject]()
    var attendanceDataUnique = [EventsAttendedObject]()
    var limit = 20
    
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "dd/MM/yyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    let databaseDateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set localization for segment controller
        segmentControl.setTitle(localized("summary"), forSegmentAt: 0)
        segmentControl.setTitle(localized("all"), forSegmentAt: 1)
        
        customizeLayout()
        setupDatePickers()
        
        //set up table view
        let eventsRefreshControl = UIRefreshControl()
        eventsRefreshControl.addTarget(self, action: #selector(refreshAttendanceData(_:)), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(eventsRefreshControl)
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        tableView.register(EventsAttendedCell.self, forCellReuseIdentifier: kEventsAttendedCellIdentifier)
        tableView.register(UINib(nibName: kEventsAttendedCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kEventsAttendedCellIdentifier)
        
        self.attendanceData.removeAll()
        getAttendance {
            print("requested events attended")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func openMenu(_ sender:UIButton?) {
        DELEGATE.menuView?.open()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            attendanceAllView.isHidden = true
            attendanceSummaryView.isHidden = false
        case 1:
            attendanceAllView.isHidden = false
            attendanceSummaryView.isHidden = true
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "EventsAttendedCell", for: indexPath)
            
        if let attendanceCell = cell as? EventsAttendedCell {
            if demo(){
                //attainmentCell.nameLabel.text = attainmentDemoArray[indexPath.row]
                //attainmentCell.positionLabel.text = String(arc4random_uniform(50))
            } else if indexPath.row < attendanceData.count {
                attendanceCell.loadEvents(events: attendanceData[indexPath.row])
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if let attendanceCell = cell as? EventsAttendedCell {
            if demo(){
                //attainmentCell.nameLabel.text = attainmentDemoArray[indexPath.row]
                //attainmentCell.positionLabel.text = String(arc4random_uniform(50))
            }
            if indexPath.row < attendanceData.count {
                attendanceCell.loadEvents(events: attendanceData[indexPath.row])
            }
        }
    }
    
    func refreshAttendanceData(_ sender:UIRefreshControl) {
        self.limit = 20
        getAttendance {
            sender.endRefreshing()
        }
    }
    
    func getAttendance(completion:@escaping (() -> Void)){
        attendanceData.removeAll()
        attendanceDataUnique.removeAll()
        let xMGR = xAPIManager()
        xMGR.silent = true
        xMGR.getEventsAttended(skip: 0, limit: self.limit) { (success, result, results, error) in
            if (results != nil){
                print("receiving data")
                for event in results! {
                    var date:String?
                    var time:String?
                    var activity:String?
                    var module:String?
                    
                    if let object = event as? [String:Any] {
                        if let statement = object["statement"] as? [String:Any]{
                            if let object2 = statement["object"] as? [String:Any] {
                                if let definition = object2["definition"] as? [String:Any] {
                                    if let name = definition["name"] as? [String:Any]{
                                        if let en = name["en"] as? String {
                                            var separatedArray = en.components(separatedBy: " ")
                                            date = separatedArray.popLast()
                                            time = separatedArray.popLast()
                                            module = separatedArray.joined(separator: " ")
                                        }
                                    }
                                }
                            }
                            if let context = statement["context"] as? [String:Any]{
                                if let extensions = context["extensions"] as? [String:Any]{
                                    activity = extensions["http://xapi.jisc.ac.uk/activity_type_id"] as? String
                                }
                            }
                        }
                    }
                }
            } else {
                print("results is nil")
            }
            
            print("events array")
            print(self.attendanceData)
            
            
            print("here is the sorted array ", self.attendanceData.sort(by: { $0.date.compare($1.date) == .orderedDescending}))
            
            print(self.attendanceData.count)
            self.tableView.reloadData()
            
            //set null message
            if(self.attendanceData.count == 0){
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                noDataLabel.text = localized("no_data_available")
                noDataLabel.textColor = UIColor.black
                noDataLabel.textAlignment = .center
                self.tableView.backgroundView = noDataLabel
                self.tableView.separatorStyle = .none
                
                self.noDataWebViewLabel.isHidden = false
            } else {
                self.noDataWebViewLabel.isHidden = true
            }

            completion()
        }
    }
    
    func customizeLayout(){
        startDateFieldSummary.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        startDateFieldSummary.layer.borderWidth = 1
        startDateFieldSummary.layer.cornerRadius = 4
        startDateFieldSummary.layer.masksToBounds = true
        
        endDateFieldSummary.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        endDateFieldSummary.layer.borderWidth = 1
        endDateFieldSummary.layer.cornerRadius = 4
        endDateFieldSummary.layer.masksToBounds = true
        
        startDateFieldAll.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        startDateFieldAll.layer.borderWidth = 1
        startDateFieldAll.layer.cornerRadius = 4
        startDateFieldAll.layer.masksToBounds = true
        
        endDateFieldAll.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        endDateFieldAll.layer.borderWidth = 1
        endDateFieldAll.layer.cornerRadius = 4
        endDateFieldAll.layer.masksToBounds = true
    }
    
    func setupDatePickers(){
        startDatePicker.datePickerMode = UIDatePickerMode.date
        startDatePicker.maximumDate = Date()
        let startToolbar = UIToolbar()
        startToolbar.sizeToFit()
        let startDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(startDatePickerDone))
        startToolbar.setItems([startDoneButton], animated: true)
        startDateFieldSummary.inputAccessoryView = startToolbar
        startDateFieldSummary.inputView = startDatePicker
        startDateFieldAll.inputAccessoryView = startToolbar
        startDateFieldAll.inputView = startDatePicker
        
        endDatePicker.datePickerMode = UIDatePickerMode.date
        endDatePicker.maximumDate = Date()
        let endToolbar = UIToolbar()
        endToolbar.sizeToFit()
        let endDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endDatePickerDone))
        endToolbar.setItems([endDoneButton], animated: true)
        endDateFieldSummary.inputAccessoryView = endToolbar
        endDateFieldSummary.inputView = endDatePicker
        endDateFieldAll.inputAccessoryView = endToolbar
        endDateFieldAll.inputView = endDatePicker
    }
    
    func startDatePickerDone(){
        if(endDateFieldSummary.text != localized("end") && startDatePicker.date > endDatePicker.date) {
            //TODO nice message
            self.view.endEditing(true)
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = gbDateFormat
        let gbDate = formatter.string(from: startDatePicker.date)
        startDateFieldSummary.text = "\(gbDate)"
        startDateFieldAll.text = "\(gbDate)"
        self.view.endEditing(true)
        if(endDateFieldSummary.text != localized("end")){
            getAttendance {
                
            }
        }
    }
    
    func endDatePickerDone(){
        if(startDateFieldSummary.text != localized("start") && endDatePicker.date < startDatePicker.date) {
            //TODO nice message
            self.view.endEditing(true)
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = gbDateFormat
        let gbDate = formatter.string(from: endDatePicker.date)
        endDateFieldSummary.text = "\(gbDate)"
        endDateFieldAll.text = "\(gbDate)"
        self.view.endEditing(true)
        if(startDateFieldSummary.text != localized("start")){
            getAttendance {
                
            }
        }
    }

}
