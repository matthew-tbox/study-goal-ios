//
//  MyFriendsVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/22/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

class MyFriendsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var friendsTableView:UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		friendsTableView.register(UINib(nibName: kOneFriendCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kOneFriendCellIdentifier)
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	//MARK: UITableView Datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataManager.friends().count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var theCell = tableView.dequeueReusableCell(withIdentifier: kOneFriendCellIdentifier)
		if (theCell == nil) {
			theCell = UITableViewCell()
		}
		return theCell!
	}
	
	//MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60.0
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let theCell:OneFriendCell? = cell as? OneFriendCell
		if (theCell != nil) {
			theCell!.tableView = tableView
			theCell!.loadFriend(dataManager.friends()[indexPath.row])
		}
	}
}
