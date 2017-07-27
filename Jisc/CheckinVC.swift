//
//  CheckinVC.swift
//  Jisc
//
//  Created by Paul on 2/23/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class CheckinVC: BaseViewController {
	
	@IBOutlet weak var entryField:UILabel!
	var currentPin = ""

    override func viewDidLoad() {
        super.viewDidLoad()
		entryField.adjustsFontSizeToFitWidth = true
		entryField.text = currentPin
    }

	@IBAction func digit(_ sender:UIButton) {
		currentPin = currentPin + "\(sender.tag)"
		entryField.text = currentPin
		view.layoutIfNeeded()
	}
	
    @IBAction func backButton(_ sender: Any) {
        DELEGATE.menuView?.open()

    }
	@IBAction func backspace(_ sender:UIButton?) {
		if !currentPin.isEmpty {
			currentPin = currentPin.substring(to: currentPin.characters.index(before: currentPin.characters.endIndex))
			entryField.text = currentPin
			view.layoutIfNeeded()
		}
	}
	
	@IBAction func sendPin(_ sender:UIButton?) {
		if staff() {
			let alert = UIAlertController(title: "", message: localized("checkin_staff_message"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		} else {
			if currentPin.isEmpty {
				let alert = UIAlertController(title: "", message: localized("enter_pin"), preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
				navigationController?.present(alert, animated: true, completion: nil)
			} else {
				let dateFormatter = DateFormatter()
				dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
				let date = Date()
				dateFormatter.dateFormat = "yyyy-MM-dd"
				let part1 = dateFormatter.string(from: date)
				dateFormatter.dateFormat = "HH:mm:ss"
				let part2 = dateFormatter.string(from: date)
				let timestamp = "\(part1)T\(part2)Z"
				xAPIManager().checkIn(pin: currentPin, location: "LOCATION", timestamp: timestamp, completion: { (success, dictionary, array, error) in
					if array != nil {
						let alert = UIAlertController(title: "", message: localized("alert_valid_pin"), preferredStyle: .alert)
						alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
						self.navigationController?.present(alert, animated: true, completion: nil)
					} else {
						let alert = UIAlertController(title: "", message: localized("alert_invalid_pin"), preferredStyle: .alert)
						alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
						self.navigationController?.present(alert, animated: true, completion: nil)
					}
					/*
					{
					"APPSHIB_ID:" = "alice@test.ukfederation.org.uk";
					error = "not found";
					"lrw_id " = 58af0b3338d0b9d145758c85;
					"register_id" = "2017-03-09-8888";
					}
					*/
					
					
					/*
					{
					"APPSHIB_ID" = "alice@test.ukfederation.org.uk";
					ATTENDED = 1;
					"FIRST_NAME" = Alice;
					"GEO_TAG" = LOCATION;
					"LAST_NAME" = Scott;
					"STUDENT_ID" = 50002;
					TIMESTAMP = "2017-03-09T14:52:14Z";
					createdAt = "2017-03-09T14:51:52.224Z";
					id = 58c16c08342979cb4ba0d9ff;
					"lrw_id" = 58af0b3338d0b9d145758c85;
					"register_id" = "2017-03-09-5559";
					updatedAt = "2017-03-09T14:52:14.582Z";
					}
					*/
				})
			}
		}
	}
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
}
