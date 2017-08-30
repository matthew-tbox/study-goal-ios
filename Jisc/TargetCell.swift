//
//  TargetCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/28/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

var kButtonsWidth:CGFloat = 240.0
let kTargetCellNibName = "TargetCell"
let kTargetCellIdentifier = "TargetCellIdentifier"
let kAnotherTargetCellOpenedOptions = "kAnotherTargetCellOpenedOptions"
let kChangeTargetCellSelectedStyleOn = "kChangeTargetCellSelectedStyleOn"
let kChangeTargetCellSelectedStyleOff = "kChangeTargetCellSelectedStyleOff"
let greenTargetColor = UIColor(red: 0.1, green: 0.69, blue: 0.12, alpha: 1.0)
let orangeTargetColor = UIColor(red: 0.99, green: 0.51, blue: 0.23, alpha: 1.0)
let redTargetColor = UIColor(red: 0.99, green: 0.24, blue: 0.26, alpha: 1.0)

class TargetCell: UITableViewCell, UIAlertViewDelegate {
	
	@IBOutlet weak var targetTypeIcon:UIImageView!
	@IBOutlet weak var completionColorView:UIView!
	@IBOutlet weak var titleLabel:UILabel!
	var indexPath:IndexPath?
	weak var tableView:UITableView?
	weak var navigationController:UINavigationController?
	@IBOutlet weak var optionsButtonsWidth:NSLayoutConstraint!
	@IBOutlet weak var optionsButtonsView:UIView!
	var optionsState:kOptionsState = .closed
	var panStartPoint:CGPoint = CGPoint.zero
	@IBOutlet weak var separator:UIView!
	weak var parent:TargetVC?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(TargetCell.panAction(_:)))
		panGesture.delegate = self
		addGestureRecognizer(panGesture)
		NotificationCenter.default.addObserver(self, selector: #selector(TargetCell.anotherCellOpenedOptions(_:)), name: NSNotification.Name(rawValue: kAnotherTargetCellOpenedOptions), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(TargetCell.changeSelectedStyleOn), name: NSNotification.Name(rawValue: kChangeTargetCellSelectedStyleOn), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(TargetCell.changeSelectedStyleOff), name: NSNotification.Name(rawValue: kChangeTargetCellSelectedStyleOff), object: nil)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		if (selected) {
			self.setSelected(false, animated: animated)
		}
	}
	
	func anotherCellOpenedOptions(_ notification:Notification) {
		let senderCell = notification.object as? TargetCell
		if (senderCell != nil) {
			if (self != senderCell!) {
				closeCellOptions()
			}
		}
	}
	
	func changeSelectedStyleOn() {
		selectionStyle = .gray
	}
	
	func changeSelectedStyleOff() {
		selectionStyle = .none
	}
	
	override func prepareForReuse() {
		titleLabel.text = ""
		closeCellOptions()
		separator.alpha = 1.0
		targetTypeIcon.image = nil
		completionColorView.backgroundColor = redTargetColor
		indexPath = nil
		tableView = nil
	}
	
	func loadTarget(_ target:Target, isLast:Bool) {
		titleLabel.text = target.textForDisplay()
		if (isLast) {
			separator.alpha = 0.0
		}
		let imageName = target.activity.iconName(big: true)
		targetTypeIcon.image = UIImage(named: imageName)
		let progress = target.calculateProgress(false)
		if (progress.completionPercentage >= 1.0) {
			completionColorView.backgroundColor = greenTargetColor
		} else if (progress.completionPercentage >= 0.8) {
			completionColorView.backgroundColor = orangeTargetColor
		} else {
			completionColorView.backgroundColor = redTargetColor
		}
	}
    @IBAction func markAsDoneAction(_ sender: Any) {
//        let alert = UIAlertController(title: "", message: "Marking this Target as done", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
//        navigationController?.present(alert, animated: true, completion: nil)
        let defaults = UserDefaults.standard
        
        var samTest = defaults.object(forKey: "AllTheSingleTargets") as! [[String:Any]]
        
        let singleDictionary = samTest[(indexPath?.row)!]
        
        var dictionaryfordis = [String:String]()
        dictionaryfordis.updateValue("1", forKey: "is_accepted")
        dictionaryfordis.updateValue("1", forKey: "is_completed")
        dictionaryfordis.updateValue(String(describing: singleDictionary["student_id"]!), forKey: "student_id")
        dictionaryfordis.updateValue(String(describing: singleDictionary["id"]!), forKey: "record_id")
        dictionaryfordis.updateValue(singleDictionary["module"] as! String, forKey: "module")
        dictionaryfordis.updateValue(singleDictionary["from_tutor"] as! String, forKey: "from_tutor")
        
        dictionaryfordis.updateValue(singleDictionary["description"] as! String, forKey: "description")
        dictionaryfordis.updateValue(singleDictionary["end_date"] as! String, forKey: "end_date")
        dictionaryfordis.updateValue("en", forKey: "language")
        if currentUserType() == .social {
            dictionaryfordis.updateValue("yes", forKey: "is_social")
            
        } else {
            dictionaryfordis.updateValue("no", forKey: "is_social")
            
        }
        
        DownloadManager().editToDo(dictionary:dictionaryfordis)
        
        let alert = UIAlertController(title: "", message: "Congratulations on completeing your task!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "getToDoList"), object: self)
        self.tableView?.reloadData()

        
    }
	
	@IBAction func editTarget(_ sender:UIButton) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_edittarget"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
        } else {
            if(kButtonsWidth > 200){
                if (indexPath != nil) {
                    print("indy\(String(describing: indexPath?.row))")
                    let defaults = UserDefaults.standard

                    var samTest = defaults.object(forKey: "AllTheSingleTargets") as! [[String:Any]]
                    
                    let singleDictionary = samTest[(indexPath?.row)!]

                    let id = singleDictionary["id"] as! Int
                    let describe = singleDictionary["description"] as! String
                    let endDate = singleDictionary["end_date"] as! String
                    let module = singleDictionary["module"] as! String
                    let reason = singleDictionary["reason"] as! String
                    
                    defaults.set(id, forKey: "EditedID") //Setting ID
                    defaults.set(reason, forKey: "EditedReason") //My goal text
                    defaults.set(describe, forKey: "EditedDescribe") //Because
                    defaults.set(endDate, forKey: "EditedDateObject") // end_date as Date
                    defaults.set(module, forKey: "EditedModule") //Module
                    NotificationCenter.default.post(name: Notification.Name(rawValue: myNotificationKey), object: self)

                } else {
                    print("waffles")
                }
            }else{
			closeCellOptions()
                if (indexPath != nil) {
                    let target = dataManager.targets()[(indexPath! as NSIndexPath).row]
                    let vc = NewTargetVC(target: target)
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
		}
	}
	@IBAction func deleteTarget(_ sender:UIButton) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_deletetarget"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		} else {
            if(kButtonsWidth > 200){
                if (indexPath != nil) {
                    let defaults = UserDefaults.standard
                    
                    var samTest = defaults.object(forKey: "AllTheSingleTargets") as! [[String:Any]]
                    
                    let singleDictionary = samTest[(indexPath?.row)!]
                    
                    let id = singleDictionary["id"] as! Int
                    let describe = singleDictionary["description"] as! String
                    let endDate = singleDictionary["end_date"] as! String
                    let module = singleDictionary["module"] as! String
                    let reason = singleDictionary["reason"] as! String
                    
                    defaults.set(id, forKey: "EditedID") //Setting ID
                    defaults.set(reason, forKey: "EditedReason") //My goal text
                    defaults.set(describe, forKey: "EditedDescribe") //Because
                    defaults.set(endDate, forKey: "EditedDateObject") // end_date as Date
                    defaults.set(module, forKey: "EditedModule") //Module

                    UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_target"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
                    print("indy\(String(describing: indexPath?.row))")
                    
                } else {
                    print("no indexPath")
                }
            }else{
                closeCellOptions()
                if (indexPath != nil) {
                    UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_target"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
                }
            }

//			if (indexPath != nil) {
//				UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_target"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
//			}
		}
	}
	
	//MARK: UIGestureRecognizer Delegate
	
	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		var shouldBegin = true
		let panGesture = gestureRecognizer as? UIPanGestureRecognizer
		if (panGesture != nil) {
			let horizontalVelocity = abs(panGesture!.velocity(in: self).x)
			let verticalVelocity = abs(panGesture!.velocity(in: self).y)
			if (verticalVelocity > horizontalVelocity) {
				shouldBegin = false
			}
		}
		return shouldBegin
	}
	
	func panAction(_ sender:UIPanGestureRecognizer) {
		switch (sender.state) {
		case .began:
			panStartPoint = sender.location(in: self)
		case .ended:
			let velocity = sender.velocity(in: self).x
			if (velocity < 0) {
				openCellOptions()
			} else {
				closeCellOptions()
			}
		case .changed:
			let currentPoint = sender.location(in: self)
			var difference = panStartPoint.x - currentPoint.x
			if (optionsState == .open) {
				difference += kButtonsWidth
			}
			if (difference < 0.0) {
				difference = 0.0
			} else if (difference > kButtonsWidth) {
				difference = kButtonsWidth
			}
			optionsButtonsWidth.constant = difference
			optionsButtonsView.setNeedsLayout()
			layoutIfNeeded()
		default:break
		}
	}
	
	func openCellOptions() {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kAnotherTargetCellOpenedOptions), object: self)
		optionsState = .open
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.optionsButtonsWidth.constant = kButtonsWidth
			self.optionsButtonsView.setNeedsLayout()
			self.layoutIfNeeded()
			}, completion: { (done) -> Void in
				NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeTargetCellSelectedStyleOff), object: nil)
				self.parent?.aCellIsOpen = true
                print("opening cell here")
		}) 
	}
	
	func closeCellOptions() {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeTargetCellSelectedStyleOn), object: nil)
		parent?.aCellIsOpen = false
		optionsState = .closed
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.optionsButtonsWidth.constant = 0.0
			self.optionsButtonsView.setNeedsLayout()
			self.layoutIfNeeded()
		}) 
	}
	
	//MARK: UIAlertView Delegate
	
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		closeCellOptions()
        if(kButtonsWidth > 200 && buttonIndex > 0){
            //Get the record Id for the selected target from the user defaults.
            let defaults = UserDefaults.standard
            let id = defaults.object(forKey: "EditedID") as! Int
            
            let urlStringCall = "http://stuapp.analytics.alpha.jisc.ac.uk/fn_delete_todo_task?student_id=13&language=en&is_social=no&record_id=\(id)"
            //let bodyString = "student_id=13&language=en&is_social=no&record_id=24"
            var request:URLRequest?
            if let urlString = urlStringCall.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: urlString) {
                    request = URLRequest(url: url)
                }
            }
            if var request = request {
                if let token = xAPIToken() {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    request.httpMethod = "DELETE"
                    //request.httpBody = bodyString.data(using: .utf8)
                }
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {                                                 // check for fundamental networking error
                        print("error=\(error!)")
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response!)")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("Should have successfully deleted the object")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "getToDoList"), object: self)
                    print("responseString = \(responseString!)")
                }
                task.resume()
            }
           // self.tableView?.deleteRows(at: [self.indexPath!], with: UITableViewRowAnimation.automatic)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "getToDoList"), object: self)
            self.tableView?.reloadData()

            
        } else if (buttonIndex > 0) {
			let target = dataManager.targets()[(indexPath! as NSIndexPath).row]
			dataManager.deleteTarget(target) { (success, failureReason) -> Void in
				if success {
					dataManager.deleteObject(target)
					AlertView.showAlert(true, message: localized("target_deleted_successfully"), completion: nil)
					self.tableView?.deleteRows(at: [self.indexPath!], with: UITableViewRowAnimation.automatic)
					self.tableView?.reloadData()
				} else {
					AlertView.showAlert(false, message: failureReason, completion: nil)
				}
			}

        }

	}
}
