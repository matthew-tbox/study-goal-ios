////
////  LoginVC.swift
////  Jisc
////
////  Created by Therapy Box on 10/19/15.
////  Copyright © 2015 Therapy Box. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//enum LoginFieldsPosition {
//	case up
//	case down
//}
//
//class LoginVC2: BaseViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
//	
//	@IBOutlet weak var loginView:UIView!
//	@IBOutlet weak var loginViewVerticalAlignment:NSLayoutConstraint!
//	@IBOutlet weak var studentHatView:UIView!
//	@IBOutlet weak var studentHatHeight:NSLayoutConstraint!
//	@IBOutlet weak var chooseInstitutionView:UIView!
//	@IBOutlet weak var chosenInstitutionLabel:UILabel!
//	@IBOutlet weak var loginFieldsView:UIView!
//	@IBOutlet weak var emailTextField:UITextField!
//	@IBOutlet weak var passwordTextField:UITextField!
//	@IBOutlet weak var loginButtonsView:UIView!
//	@IBOutlet weak var rememberMeButton:UIButton!
//	@IBOutlet weak var iAcceptTermsButton:UIButton!
//	@IBOutlet weak var termsAndConditionsButton:UIButton!
//	@IBOutlet weak var termsAndConditionsUnderlineView:UIView!
//	@IBOutlet weak var loginButton:UIButton!
//	@IBOutlet weak var staffButton:UIButton!
//	
//	@IBOutlet var termsAndConditionsView:UIView!
//	
//	@IBOutlet var instituteSelectorView:UIView!
//	@IBOutlet weak var institutesTable:UITableView!
//	@IBOutlet weak var institutesTableHeight:NSLayoutConstraint!
//	@IBOutlet weak var institutesTableBottomSpace:NSLayoutConstraint!
//	@IBOutlet weak var instituteTextField:UITextField!
//	
//	@IBOutlet var forgotPasswordView:UIView!
//	@IBOutlet weak var forgotPasswordTextField:UITextField!
//	
//	var selectedInstitute:Int = -1
//	var filteredInstitutions:[Institution] = [Institution]()
//	var studentHatAlpha:CGFloat = 1.0
//	var loginFieldsBottomSpace:CGFloat = 0.0
//	
//	let launchImage = UIImageView(image: UIImage(named: "loadingLoginScreen"))
//	
//	@IBOutlet var chooseInstitutionView2:UIView!
//	@IBOutlet weak var chosenInstitutionLabel2:UILabel!
//	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		staffChecked = false
//		chosenInstitutionLabel.adjustsFontSizeToFitWidth = true
//		instituteTextField.superview?.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
//		instituteTextField.superview?.layer.borderWidth = 1.0
//		instituteTextField.superview?.layer.cornerRadius = 10.0
//		institutesTable.register(UINib(nibName: kInstituteCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kInstituteCellIdentifier)
//		if (screenWidth == .small) {
//			adjustForSmallScreen()
//		}
//		setLoginItemsActive(false)
//		let xmgr = xAPIManager()
//		xmgr.silent = true
//		xmgr.getIDPS { (success, result, results, error) in
//			if (success) {
//				if (result != nil) {
//					if let keys = result!.allKeys as? [String] {
//						for (index, item) in keys.enumerated() {
//							let dictionary = NSMutableDictionary()
//							dictionary["id"] = "\(index)"
//							dictionary["is_learning_analytics"] = "yes"
//							dictionary["name"] = item
//							dictionary["accesskey"] = ""
//							dictionary["secret"] = ""
//							_ = Institution.insertInManagedObjectContext(managedContext, dictionary: dictionary)
//						}
//						dataManager.safelySaveContext()
//						self.filterInstitutions("")
//						self.institutesTable.reloadData()
//						self.institutesTableHeight.constant = self.institutesTable.contentSize.height
//						self.view.layoutIfNeeded()
//					}
//				}
//			}
//		}
//		
////			var dictionary = [String:String]()
////			dictionary["id"] = "1"
////			dictionary["is_learning_analytics"] = "yes"
////			dictionary["name"] = "TEST"
////			dictionary["accesskey"] = "key"
////			dictionary["secret"] = "secret"
////			Institution.insertInManagedObjectContext(managedContext, dictionary: dictionary)
//		
//		NotificationCenter.default.addObserver(self, selector: #selector(xAPILoginComplete(_:)), name: NSNotification.Name(rawValue: xAPILoginCompleteNotification), object: nil)
//		
//		addOutsideView(chooseInstitutionView2)
//	}
//	
//	@IBAction func toggleStaff(_ sender:UIButton) {
//		sender.isSelected = !sender.isSelected
//		staffChecked = sender.isSelected
//		setStaff(sender.isSelected)
//	}
//	
//	@IBAction func toggleKeepMeLoggedIn(_ sender:UIButton) {
//		sender.isSelected = !sender.isSelected
//		setKeepMeLoggenIn(sender.isSelected)
//	}
//	
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		if keepMeLoggedIn() {
//			if JWTStillValid() {
//				xAPIManager().getStudentDetails({ (success, result, results, error) in
//					var loginSuccessful = false
//					if let result = result {
//						if let shibID = result["APPSHIB_ID"] as? String {
//							if (shibID != "null") {
//								loginSuccessful = true
//							}
//						}
//					}
//					if (loginSuccessful) {
//						if let staffId = result?["STAFF_ID"] as? String {
//							NotificationCenter.default.post(name: Notification.Name(rawValue: xAPILoginCompleteNotification), object: staffId)
//						} else {
//							NotificationCenter.default.post(name: Notification.Name(rawValue: xAPILoginCompleteNotification), object: result?["STUDENT_ID"] as? String)
//						}
//						self.dismiss(animated: true, completion: {})
//					} else {
//						setKeepMeLoggenIn(false)
//						clearXAPIToken()
//					}
//				})
//			} else {
//				setKeepMeLoggenIn(false)
//				clearXAPIToken()
//			}
//		}
//	}
//	
//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//		view.layoutIfNeeded()
//		institutesTableHeight.constant = institutesTable.contentSize.height
//		view.layoutIfNeeded()
//		loginFieldsBottomSpace = view.frame.size.height - (loginView.frame.origin.y + loginView.frame.size.height)
//		loginFieldsBottomSpace += loginView.frame.size.height - (loginFieldsView.frame.origin.y + loginFieldsView.frame.size.height)
////		let currentUser = getCurrentUser()
////		var instituteID:String? = nil
////		var email:String? = nil
////		var password:String? = nil
////		if (currentUser != nil) {
////			instituteID = currentUser!["instituteID"]
////			email = currentUser!["email"]
////			password = currentUser!["password"]
////		} else if (weHaveACurrentUser()) {
////			instituteID = currentlyLoggedInStudentInstitute
////			email = currentlyLoggedInStudentEmail
////			password = currentlyLoggedInStudentPassword
////		} else if (shouldRememberXAPIUser() && xAPIToken() != nil) {
////			dataManager.loginWithXAPI(xAPIToken()!, completion: { (success, failureReason) in
////				if (success) {
////					DELEGATE.mainController = MainTabBarController()
////					DELEGATE.window?.rootViewController = DELEGATE.mainController
////				} else {
////					self.launchImage.removeFromSuperview()
////					UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalizedString).show()
////				}
////			})
////		}
////		
////		if (instituteID != nil && email != nil && password != nil) {
////			dataManager.loginStudent(instituteID!, email: email!, password: password!, completion: { (success, failureReason) -> Void in
////				if (success) {
////					currentlyLoggedInStudentInstitute = instituteID!
////					currentlyLoggedInStudentEmail = email!
////					currentlyLoggedInStudentPassword = password!
////					DELEGATE.mainController = MainTabBarController()
////					DELEGATE.window?.rootViewController = DELEGATE.mainController
////				} else {
////					self.launchImage.removeFromSuperview()
////					UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalizedString).show()
////				}
////			})
////		}
//	}
//	
//	override var preferredStatusBarStyle : UIStatusBarStyle {
//		return UIStatusBarStyle.lightContent
//	}
//	
//	func socialLogin(email:String, name:String, userId:String) {
//		dataManager.pickedInstitution = dataManager.socialInstitution()
//		dataManager.socialLogin(email: email, name: name, userId: userId) { (success, failureReason) in
//			if (success) {
//				if let student = dataManager.currentStudent {
//					dataManager.currentStudent?.jisc_id = student.id
//				}
//				RunLoop.current.add(runningActivititesTimer, forMode: RunLoopMode.commonModes)
//				DELEGATE.mainController = MainTabBarController()
//				DELEGATE.window?.rootViewController = DELEGATE.mainController
//			} else {
//				UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//			}
//		}
//	}
//	
//	func xAPILoginComplete(_ notification:Notification) {
//		if let token = xAPIToken() {
//			dataManager.loginWithXAPI(token, completion: { (success, failureReason) in
//				if (success) {
//					if let jisc_id = notification.object as? String {
//						dataManager.currentStudent?.jisc_id = jisc_id
//					}
//					if xAPIToken() == demoXAPIToken {
//						dataManager.currentStudent?.demo = true
//						dataManager.currentStudent?.institution = dataManager.demoInstitution()
//					}
//					RunLoop.current.add(runningActivititesTimer, forMode: RunLoopMode.commonModes)
//					DELEGATE.mainController = MainTabBarController()
//					DELEGATE.window?.rootViewController = DELEGATE.mainController
//				} else {
//					UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//				}
//			})
//		}
//	}
//	
//	func adjustForSmallScreen() {
//		studentHatAlpha = 0.0
//		studentHatView.alpha = 0.0
//		studentHatHeight.constant = 0.0
//		view.layoutIfNeeded()
//	}
//	
//	func addOutsideView(_ view:UIView) {
//		view.alpha = 0.0
//		view.translatesAutoresizingMaskIntoConstraints = false
//		self.view.addSubview(view)
//		addMarginConstraintsWithView(view, toSuperView: self.view)
//		self.view.layoutIfNeeded()
//		UIView.animate(withDuration: 0.25, animations: { () -> Void in
//			view.alpha = 1.0
//		}) 
//	}
//	
//	func setLoginItemsActive(_ active:Bool) {
//		setView(loginFieldsView, active: active)
//		setView(rememberMeButton, active: active)
//		setView(iAcceptTermsButton, active: active)
//		setView(termsAndConditionsButton, active: active)
//		setView(termsAndConditionsUnderlineView, active: active)
//		setView(loginButton, active: active)
//	}
//	
//	func setView(_ view:UIView, active:Bool) {
//		if (active) {
//			view.alpha = 1.0
//			view.isUserInteractionEnabled = true
//		} else {
//			view.alpha = 0.5
//			view.isUserInteractionEnabled = false
//		}
//	}
//	
//	func bringLoginFields(_ position:LoginFieldsPosition) {
//		switch (position) {
//		case .up:
//			UIView.animate(withDuration: 0.25, animations: { () -> Void in
//				self.studentHatView.alpha = 0.0
//				self.chooseInstitutionView.alpha = 0.0
//				self.loginButtonsView.alpha = 0.0
//				self.loginViewVerticalAlignment.constant = -(keyboardHeight - self.loginFieldsBottomSpace + 20)
//				self.view.layoutIfNeeded()
//			})
//			break
//		case .down:
//			UIView.animate(withDuration: 0.25, animations: { () -> Void in
//				self.studentHatView.alpha = self.studentHatAlpha
//				self.chooseInstitutionView.alpha = 1.0
//				self.loginButtonsView.alpha = 1.0
//				self.loginViewVerticalAlignment.constant = 0.0
//				self.view.layoutIfNeeded()
//			})
//			break
//		}
//	}
//	
//	@IBAction func showTermsAndConditions(_ sender:UIButton) {
//		addOutsideView(termsAndConditionsView)
//	}
//	
//	@IBAction func closeTermsAndConditions(_ sender:UIButton) {
//		UIView.animate(withDuration: 0.25, animations: { () -> Void in
//			self.termsAndConditionsView.alpha = 0.0
//			}, completion: { (done) -> Void in
//				self.termsAndConditionsView.removeFromSuperview()
//		}) 
//	}
//	
//	func filterInstitutions(_ string:String) {
//		filteredInstitutions.removeAll()
//		let fetchRequest:NSFetchRequest<Institution> = NSFetchRequest(entityName: institutionEntityName)
//		if (!string.isEmpty) {
//			fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@ AND name != %@", string, "Social")
//		} else {
//			fetchRequest.predicate = NSPredicate(format: "name != %@", string, "Social")
//		}
//		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//		do {
//			let institutions = try managedContext.fetch(fetchRequest)
//			for (_, item) in institutions.enumerated() {
//				filteredInstitutions.append(item)
//			}
//		} catch let error as NSError {
//			print("filter institutions error: \(error.localizedDescription)")
//		}
//		var socialIndex = -1
//		for (index, item) in filteredInstitutions.enumerated() {
//			if item.name == "Social" {
//				socialIndex = index
//				break
//			}
//		}
//		if socialIndex >= 0 {
//			filteredInstitutions.remove(at: socialIndex)
//		}
//	}
//	
//	@IBAction func showInstitutesSelector(_ sender:UIButton) {
//		addOutsideView(instituteSelectorView)
//	}
//	
//	@IBAction func closeInstitutesSelector(_ sender:UIButton) {
//		UIView.animate(withDuration: 0.25, animations: { () -> Void in
//			self.instituteSelectorView.alpha = 0.0
//			}, completion: { (done) -> Void in
//				self.instituteSelectorView.removeFromSuperview()
//				if (self.selectedInstitute >= 0) {
//					self.setLoginItemsActive(true)
//				}
//		}) 
//	}
//	
//	@IBAction func forgotPassword(_ sender:UIButton) {
//		addOutsideView(forgotPasswordView)
//		UIView.animate(withDuration: 0.25, animations: { () -> Void in
//			self.loginView.alpha = 0.0
//		}) 
//	}
//	
//	@IBAction func closeForgotPassword(_ sender:UIButton) {
//		UIView.animate(withDuration: 0.25, animations: { () -> Void in
//			self.forgotPasswordView.alpha = 0.0
//			self.loginView.alpha = 1.0
//			}, completion: { (done) -> Void in
//				self.forgotPasswordView.removeFromSuperview()
//		}) 
//	}
//	
//	@IBAction func sendForgotPassword(_ sender:UIButton) {
//		forgotPasswordTextField.resignFirstResponder()
//		UIView.animate(withDuration: 0.25, animations: { () -> Void in
//			self.loginView.alpha = 1.0
//			self.forgotPasswordView.alpha = 0.0
//			}, completion: {(done) -> Void in
//				self.forgotPasswordView.removeFromSuperview()
//				if (self.forgotPasswordTextField.text != nil) {
//					if (!self.forgotPasswordTextField.text!.isEmpty) {
//						if (isValidEmail(self.forgotPasswordTextField.text!)) {
//							DownloadManager().forgotPassword(self.forgotPasswordTextField.text!, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
//								self.forgotPasswordTextField.text = ""
//							})
//						} else {
//							UIAlertView(title: localized("error"), message: localized("please_enter_a_valid_email_address"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//						}
//					} else {
//						UIAlertView(title: localized("error"), message: localized("please_enter_your_email_address"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//					}
//				} else {
//					UIAlertView(title: localized("error"), message: localized("please_enter_your_email_address"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//				}
//		}) 
//	}
//	
//	@IBAction func login(_ sender:UIButton) {
//		view.endEditing(true)
//		if (emailTextField.text == nil) {
//			UIAlertView(title: localized("error"), message: localized("please_enter_your_email_id"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//		} else if (emailTextField.text!.isEmpty) {
//			UIAlertView(title: localized("error"), message: localized("please_enter_your_email_id"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//		} else if (!isValidEmail(emailTextField.text!)) {
//			UIAlertView(title: localized("error"), message: localized("please_enter_a_valid_email_address"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//		} else if (passwordTextField.text == nil) {
//			UIAlertView(title: localized("error"), message: localized("please_enter_your_password"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//		} else if (passwordTextField.text!.isEmpty) {
//			UIAlertView(title: localized("error"), message: localized("please_enter_your_password"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//		} else if (!iAcceptTermsButton.isSelected) {
//			UIAlertView(title: localized("error"), message: localized("accept_the_terms_and_conditions"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//		} else {
//			let selectedInstituteObject = filteredInstitutions[selectedInstitute]
//			dataManager.loginStudent(selectedInstituteObject.id, email: emailTextField.text!, password: passwordTextField.text!, completion: { (success, failureReason) -> Void in
//				if (success) {
//					DELEGATE.mainController = MainTabBarController()
//					DELEGATE.window?.rootViewController = DELEGATE.mainController
//				} else {
//					UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
//				}
//			})
//		}
//	}
//	
//	@IBAction func rememberMe(_ sender:UIButton) {
//		sender.isSelected = !sender.isSelected
//	}
//	
//	@IBAction func iAcceptTerms(_ sender:UIButton) {
//		sender.isSelected = !sender.isSelected
//	}
//	
//	@IBAction func demoLogin() {
//		setXAPIToken(demoXAPIToken)
//		dataManager.pickedInstitution = dataManager.demoInstitution()
//		staffButton.isSelected = false
//		staffChecked = false
//		setStaff(false)
//		xAPIManager().getStudentDetails({ (success, result, results, error) in
//			var loginSuccessful = false
//			if let result = result {
//				if let shibID = result["APPSHIB_ID"] as? String {
//					if (shibID != "null") {
//						loginSuccessful = true
//					}
//				}
//			}
//			if (loginSuccessful) {
//				NotificationCenter.default.post(name: Notification.Name(rawValue: xAPILoginCompleteNotification), object: result?["STUDENT_ID"] as? String)
//			} else {
//				
//			}
//		})
//	}
//	
//	//MARK: UITextField Delegate
//	
//	func textFieldDidBeginEditing(_ textField: UITextField) {
//		if (textField == emailTextField || textField == passwordTextField) {
//			bringLoginFields(.up)
//		} else if (textField == instituteTextField) {
//			let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//			DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: { () -> Void in
//				UIView.animate(withDuration: 0.25, animations: { () -> Void in
//					self.institutesTableBottomSpace.constant = keyboardHeight
//					self.view.layoutIfNeeded()
//				})
//			})
//		}
//	}
//	
//	func textFieldDidEndEditing(_ textField: UITextField) {
//		if (textField == passwordTextField) {
//			bringLoginFields(.down)
//		} else if (textField == instituteTextField) {
//			UIView.animate(withDuration: 0.25, animations: { () -> Void in
//				self.institutesTableBottomSpace.constant = 0.0
//				self.view.layoutIfNeeded()
//			})
//		}
//	}
//	
//	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//		var shouldReturn = true
//		switch (textField) {
//		case emailTextField:
//			shouldReturn = false
//			passwordTextField.becomeFirstResponder()
//		case passwordTextField:
//			textField.resignFirstResponder()
////			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500000000), dispatch_get_main_queue()) { () -> Void in
////				self.login(UIButton())
////			}
//		default:
//			textField.resignFirstResponder()
//		}
//		return shouldReturn
//	}
//	
//	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//		let shouldChange = true
//		if (textField == instituteTextField && textField.text != nil) {
//			let nsString = NSString(string: textField.text!)
//			filterInstitutions(nsString.replacingCharacters(in: range, with: string))
//			institutesTable.reloadData()
//			institutesTableHeight.constant = institutesTable.contentSize.height
//			view.layoutIfNeeded()
//		}
//		return shouldChange
//	}
//	
//	//MARK: UITableView Datasource
//	
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return filteredInstitutions.count + 2
//	}
//	
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		var theCell = tableView.dequeueReusableCell(withIdentifier: kInstituteCellIdentifier)
//		if (theCell == nil) {
//			theCell = UITableViewCell()
//		}
//		return theCell!
//	}
//	
//	//MARK: UITableView Delegate
//	
//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		return 35.0
//	}
//	
//	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//		let theCell = cell as? InstituteCell
//		if (theCell != nil) {
//			if indexPath.row < filteredInstitutions.count {
//				theCell?.loadInstitute(filteredInstitutions[indexPath.row])
//			} else if indexPath.row == filteredInstitutions.count {
//				theCell?.noInstitute()
//			} else {
//				theCell?.demoInstitute()
//			}
//		}
//	}
//	
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		if indexPath.row > filteredInstitutions.count {
//			demoLogin()
//		} else if indexPath.row == filteredInstitutions.count {
//			staffChecked = false
//			setStaff(false)
//			staffButton.isSelected = false
//			let vc = SocialLoginVC()
////			vc.loginVC = self
//			let nvc = UINavigationController(rootViewController: vc)
//			nvc.isNavigationBarHidden = true
//			navigationController?.present(nvc, animated: true, completion: nil)
//		} else {
//			let selectedInstituteObject = filteredInstitutions[indexPath.row]
//			chosenInstitutionLabel.text = selectedInstituteObject.name
//			chosenInstitutionLabel.textColor = UIColor.black
//			selectedInstitute = indexPath.row
//			view.layoutIfNeeded()
//			closeInstitutesSelector(UIButton())
//			dataManager.pickedInstitution = selectedInstituteObject
//			
//			if (selectedInstituteObject.isLearningAnalytics.boolValue) {
//				xAPIManager().getIDPS { (success, result, results, error) in
//					if (result != nil) {
//						let vc:xAPILoginVC = xAPILoginVC()
//						vc.idp = getIDPForInstitution(selectedInstituteObject.name, dictionary: result!)
//						self.navigationController?.present(vc, animated: true, completion: nil)
//					}
//				}
//			} else {
//				print("not learning analityics: \(selectedInstituteObject.name)");
//			}
//			
//			instituteTextField.resignFirstResponder()
//		}
//	}
//}
