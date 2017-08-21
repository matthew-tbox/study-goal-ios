//
//  SingleTargetVC.swift
//  Jisc
//
//  Created by Therapy Box on 18/08/2017.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

let emptySingleTargetPageMessage = localized("empty_target_page_message")

class SingleTargetVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var singleTargetTableView: UITableView!
    var aSingleCellIsOpen:Bool = false
    var arrayOfResponses: [[String:Any]] = []
    @IBOutlet weak var singleTargetSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleTargetTableView.register(UINib(nibName: kTargetCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kTargetCellIdentifier)
        singleTargetTableView.contentInset = UIEdgeInsetsMake(20.0, 0, 20.0, 0)
        singleTargetTableView.delegate = self
        singleTargetTableView.dataSource = self
        singleTargetTableView.reloadData()
        //London Developer July 24,2017
        let urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-main&contentName=MainTargetsPage"
        xAPIManager().checkMod(testUrl:urlString)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getTodoListData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        singleTargetTableView.reloadData()
    }

    @IBAction func openMenuAction(_ sender: Any) {
        DELEGATE.menuView?.open()
    }

    @IBAction func newTargetAction(_ sender: Any) {
        if demo() {
            let alert = UIAlertController(title: "", message: localized("demo_mode_addtarget"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)
        } else {
            let vc = NewTargetVC()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func singelTargetSegmentAction(_ sender: Any) {
        if (singleTargetSegmentControl.selectedSegmentIndex == 0){
            let vc = SingleTargetVC()
            navigationController?.pushViewController(vc, animated: false)
            
        } else {
            let vc = TargetVC()
            navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    
    private func getTodoListData(){
        let urlStringCall = "http://stuapp.analytics.alpha.jisc.ac.uk/fn_get_todo_list?student_id=13&language=en&is_social=no"
        var request:URLRequest?
        if let urlString = urlStringCall.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
        }
        if var request = request {
            if let token = xAPIToken() {
                request.addValue("\(token)", forHTTPHeaderField: "Authorization")
            }
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
                            for item in json {
                                let object = item as? [String:Any]
                                self.arrayOfResponses.append(object!)
                                print("OMG AHMED OBJECT RETURNED!!!", object!)
                                print("OMG AHMED END_DATE WHOOO!!", object!["end_date"]!)
                            }
                        self.singleTargetTableView.reloadData()
                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
            }
            //startConnectionWithRequest(request)
        } else {
            // completionBlock?(false, nil, nil, "Error creating the url request")
        }
    }
    
    //MARK: UITableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let nrRows = dataManager.targets().count
//        if (nrRows == 0) {
//            emptyScreenMessageView.alpha = 1.0
//        } else {
//            emptyScreenMessageView.alpha = 0.0
//        }
        print("OMG AHMED ARRAY COUNT IN THE HOUSE", arrayOfResponses.count)
        return arrayOfResponses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let theCell = tableView.dequeueReusableCell(withIdentifier: kTargetCellIdentifier) as! TargetCell
        let singleDictionary = arrayOfResponses[indexPath.row] 
        let describe = singleDictionary["description"] as! String
        let endDate = singleDictionary["end_date"] as! String
        let module = singleDictionary["module"] as! String
        let reason = singleDictionary["reason"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        let dateObj = dateFormatter.date(from: endDate)
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let finalDate = dateFormatter.string(from: dateObj!)
        //print("Dateobj: \(dateFormatter.string(from: dateObj!))")
        
        var finalText = ""
        if (module.isEmpty){
            finalText = "\(describe) by \(finalDate) because \(reason)"
        } else if (reason.isEmpty){
            finalText = "\(describe) for \(module) by \(finalDate)"
        } else {
            finalText = "\(describe) by \(finalDate) because \(reason)"
        }
        
        //theCell.textLabel?.adjustsFontSizeToFitWidth = true
        theCell.textLabel?.numberOfLines = 6
        theCell.completionColorView.isHidden = true
        theCell.targetTypeIcon.image = UIImage(named: "activity_icon_\(arc4random_uniform(17)+1)")
        theCell.titleLabel.text = finalText
        
//        if (theCell == nil) {
//            theCell = UITableViewCell()
//        }
        return theCell
    }
    
    //MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //let theCell:TargetCell? = cell as? TargetCell
//        if (theCell != nil) {
//            theCell!.parent = self
//            theCell!.loadTarget(dataManager.targets()[indexPath.row], isLast:(indexPath.row == (dataManager.targets().count - 1)))
//            theCell!.indexPath = indexPath
//            theCell!.tableView = tableView
//            theCell!.navigationController = navigationController
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (aSingleCellIsOpen) {
//            tableView.reloadData()
//        } else {
//            let target = dataManager.targets()[indexPath.row]
//            let vc = TargetDetailsVC(target: target, index: indexPath.row)
//            navigationController?.pushViewController(vc, animated: true)
//            
//        }
    }

}
