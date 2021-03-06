//
//  xAPIManager.swift
//  Jisc
//
//  Created by Therapy Box on 3/15/16.
//  Copyright © 2016 Therapy Box. All rights reserved.
//

import Foundation
import UIKit

let xAPIHostPath = "https://app.analytics.alpha.jisc.ac.uk/"
let xAPIHostName = NSURL(string: hostPath)?.host

let xAPIGetIDPSPath = "idps"
let xAPIGetActivityPointsPath = "v2/activity/points"
let xAPIGetEngagementDataPath = "v2/engagement"
let xAPIGetModulesPath = "v2/filter"
let xAPIGetAttainmentPath = "v2/attainment"
let xAPIGetComparisonToTop10PercentPath = "v2/engagement"

typealias xAPICompletionBlock = ((_ success:Bool, _ result:NSDictionary?, _ results:NSArray?, _ error:String?) -> Void)

enum kXAPIEngagementScope: String {
	case Overall = "overall"
	case SevenDays = "7d"
	case ThirtyDays = "28d"
}

enum kXAPIEngagementFilterType: String {
	case Course = "course"
	case Module = "module"
}

enum kXAPIEngagementCompareType: String {
	case Average = "average"
	case Friend = "friend"
	case Top = "top"
}

enum kXAPIActivityPointsPeriod: String {
	case Overall = "overall"
	case SevenDays = "7d"
}

struct EngagementGraphOptions {
	var scope:kXAPIEngagementScope?
	var filterType:kXAPIEngagementFilterType?
	var filterValue:String?
	var compareType:kXAPIEngagementCompareType?
	var compareValue:String?
}

class xAPIManager: NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
	
	var rawData:NSMutableData = NSMutableData()
	var completionBlock:downloadCompletionBlock?
	var silent:Bool = inheritSilent
	var connectionSuccessfull:Bool = false
	var code:kRequestStatusCode?
	var shouldNotifyAboutInternetConnection:Bool = true

	//MARK: NSURLConnection Data Delegate
	
	func connection(_ connection: NSURLConnection, didReceive data: Data) {
		rawData.append(data)
	}
	
	func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
		let httpResponse = response as? HTTPURLResponse;
		if (httpResponse != nil) {
			code = kRequestStatusCode(rawValue:httpResponse!.statusCode)
			if (code != nil) {
				if (LOG_ACTIVITY && connection.originalRequest.url?.absoluteString != nil) {
					print("\(connection.originalRequest.url!.absoluteString) - code: \(code!)")
				}
				if (code == .ok || code == .noContent) {
					connectionSuccessfull = true
				}
				
				if (code == .unauthorized) {
					completionBlock = nil
					if let cookies = HTTPCookieStorage.shared.cookies {
						for cookie in cookies {
							HTTPCookieStorage.shared.deleteCookie(cookie)
						}
					}
					runningActivititesTimer.invalidate()
					DELEGATE.mainController?.feedViewController.refreshTimer?.invalidate()
					dataManager.currentStudent = nil
					dataManager.firstTrophyCheck = true
					deleteCurrentUser()
					clearXAPIToken()
					let nvc = UINavigationController(rootViewController: LoginVC())
					nvc.isNavigationBarHidden = true
					DELEGATE.window?.rootViewController = nvc
					UIAlertView(title: localized("session_expired_title"), message: localized("session_expired_message"), delegate: nil, cancelButtonTitle: localized("ok")).show()
				}
			}
		}
	}
	
	func connectionDidFinishLoading(_ connection: NSURLConnection) {
		if (!silent) {
			LoadingView.hide()
		}
		if (completionBlock != nil) {
			do {
				let jsonObject = try JSONSerialization.jsonObject(with: rawData as Data, options: JSONSerialization.ReadingOptions.allowFragments)
				let dictionary:NSDictionary? = jsonObject as? NSDictionary
				if (dictionary != nil) {
					if (LOG_ACTIVITY) {
						DELEGATE.printDownloadResult(true, result: dictionary, results: nil, error: nil)
					}
					DispatchQueue.main.async(execute: { () -> Void in
						if (self.code == .noContent) {
							self.completionBlock!(true, nil, nil, nil)
						} else {
							self.completionBlock!(true, dictionary, nil, nil)
						}
					})
				} else {
					let array:NSArray? = jsonObject as? NSArray
					if (array != nil) {
						if (LOG_ACTIVITY) {
							DELEGATE.printDownloadResult(true, result: nil, results: array, error: nil)
						}
						DispatchQueue.main.async(execute: { () -> Void in
							if (self.code == .noContent) {
								self.completionBlock!(true, nil, nil, nil)
							} else {
								self.completionBlock!(true, nil, array, nil)
							}
						})
					}
				}
			} catch {
				let string = String(data: rawData as Data, encoding: String.Encoding.utf8)
				
				if (string != nil) {
					if (connection.originalRequest.url?.absoluteString != nil) {
						print("\(connection.originalRequest.url!.absoluteString) - Received data to string: |\(string!)|")
					}
					DispatchQueue.main.async(execute: { () -> Void in
						if (self.connectionSuccessfull) {
							if (LOG_ACTIVITY) {
								DELEGATE.printDownloadResult(true, result: ["message":string!], results: nil, error: nil)
							}
							if (self.code == .noContent) {
								self.completionBlock!(true, nil, nil, nil)
							} else {
								self.completionBlock!(true, ["message":string!], nil, string!)
							}
						} else {
							self.completionBlock!(false, nil, nil, string!)
							if (LOG_ACTIVITY) {
								DELEGATE.printDownloadResult(false, result: nil, results: nil, error: string!)
							}
						}
					})
				} else {
					print("Could not convert received data to string. Data length = \(rawData.length)")
					DispatchQueue.main.async(execute: { () -> Void in
						self.completionBlock!(false, nil, nil, "Unknown connection error.")
						if (LOG_ACTIVITY) {
							DELEGATE.printDownloadResult(false, result: nil, results: nil, error: "Unknown connection error.")
						}
					})
				}
			}
		}
	}
	
	//MARK: NSURLConnection Delegate
	
	func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
		if (!silent) {
			LoadingView.hide()
		}
		if (completionBlock != nil) {
			if (LOG_ACTIVITY) {
				DELEGATE.printDownloadResult(false, result: nil, results: nil, error: error.localizedDescription)
			}
			DispatchQueue.main.async(execute: { () -> Void in
				self.completionBlock!(false, nil, nil, error.localizedDescription)
			})
		}
	}
	
	//MARK: Helpful Functions
	
	func urlWithHost(_ host:String, path:String) -> URL? {
		let fullPath = "\(host)\(path)"
		let theURL:URL? = URL(string: fullPath)
		return theURL
	}
	
	func urlWithPath(_ path:String) -> URL? {
		let fullPath = "\(xAPIHostPath)\(path)"
		var theURL = URL(string: "")
		if let escapedString = fullPath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
			if let url = URL(string: escapedString) {
				theURL = url
			} else {
				print("URL failed: \(fullPath)")
			}
		}
		return theURL
	}
	
	func createGetRequest(_ path:String, withJWT:Bool) -> URLRequest? {
		var request:URLRequest?
		if let url = urlWithPath(path) {
			request = URLRequest(url: url)
			if (withJWT) {
				if let token = xAPIToken() {
					print("Token: \(token)")
					request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
				}
			}
		}
		return request
	}
	
	func bodyStringFromDictionary(_ dictionary:[String:String]) -> String {
		var string:String = ""
		let elements:NSMutableArray = NSMutableArray()
		let newDictionary:NSMutableDictionary = NSMutableDictionary(dictionary: dictionary)
		
		for key in newDictionary.allKeys
		{
			let argumentString:String? = key as? String
			let objectString:String? = newDictionary.object(forKey: key) as? String
			
			if (argumentString == nil) {
				print("key is nil")
				continue
			}
			
			if (objectString == nil) {
				print("object is nil")
				continue
			}
			
			elements.add("\(argumentString!)=\(objectString!)")
		}
		
		string = elements.componentsJoined(by: "&")
		
		let escapedString:String? = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
		
		if (escapedString != nil) {
			string = escapedString!
		}
		
		if (LOG_ACTIVITY) {
			print("body string:\n\(string)")
		}
		
		if (LOG_ACTIVITY) {
			let separator = "&"
			let array:[String] = string.components(separatedBy: separator)
			print("\(array)")
		}
		
		return string
	}
	
	func createPostRequest(_ path:String, bodyString:String)  -> URLRequest? {
		let postData:Data? = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
		var request:URLRequest?
		if let url = urlWithPath(path) {
			request = URLRequest(url: url)
		}
		if let token = xAPIToken() {
			request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
		}
		request?.httpMethod = "POST"
		if (postData != nil) {
			request?.setValue("\(postData!.count)", forHTTPHeaderField: "Content-Length")
			request?.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
		}
		request?.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
		return request
	}
	
	func createPutRequest(_ path:String, bodyString:String)  -> URLRequest? {
		let postData:Data? = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
		var request:URLRequest?
		if let url = urlWithPath(path) {
			request = URLRequest(url: url)
		}
		if let token = xAPIToken() {
			request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
		}
		request?.httpMethod = "PUT"
		if (postData != nil) {
			request?.setValue("\(postData!.count)", forHTTPHeaderField: "Content-Length")
			request?.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
		}
		request?.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
		return request
	}
	
	func createDeleteRequest(_ path:String)  -> URLRequest? {
		var request:URLRequest?
		if let url = urlWithPath(path) {
			request = URLRequest(url: url)
		}
		if let token = xAPIToken() {
			request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
		}
		request?.httpMethod = "DELETE"
		return request
	}
	
	func createProfileImageUploadRequest(_ path: String, myID:String, image:UIImage) -> URLRequest?
	{
		var request:URLRequest?
		if let url = urlWithPath(path) {
			request = URLRequest(url: url)
		}
		if let token = xAPIToken() {
			request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
		}
		request?.httpMethod = "POST"
		
		let boundary = "---------------------------14737809831466499882746641449"
		
		let contentType = NSString(format: "multipart/form-data; boundary=%@", boundary)
		request?.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
		
		let body = NSMutableData()
		
		var data = (NSString(format: "\r\n--%@\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		data = (NSString(format: "Content-Disposition: form-data; name=\"student_id\"\r\n\r\n%@", myID)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		
		data = (NSString(format: "\r\n--%@\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		var language = "en"
		if let newLanguage = BundleLocalization.sharedInstance().language {
			language = newLanguage
		}
		data = (NSString(format: "Content-Disposition: form-data; name=\"language\"\r\n\r\n%@", language)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		
		data = (NSString(format: "\r\n--%@\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		let fileName = "\(myID)_\(Date().timeIntervalSince1970)"
		let string = NSString(format: "Content-Disposition: attachment; name=\"profile_photo\"; filename=\"%@.png\"\r\nContent-Type: image/png\r\n\r\n", fileName)
		data = NSString(string: string).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		var imageData = UIImageJPEGRepresentation(image, 1.0)!
		var newImage = image
		while (imageData.count >= maximumImageSizeInBytes) {
			newImage = UIImage.scaleImage(newImage, toSize: CGSize(width: newImage.size.width * 0.9, height: newImage.size.height * 0.9))
			imageData = UIImageJPEGRepresentation(newImage, 1.0)!
		}
		body.append(imageData)
		
		data = (NSString(format: "\r\n--%@--\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
		body.append(data!)
		
		request?.httpBody = body as Data
		
		return request
	}
	
	func startConnectionWithRequest(_ request:URLRequest?) {
		if let request = request {
			if (internetAvailability == ReachabilityStatus.notInitialized) {
				let timer = Timer(timeInterval: 0.5, target: self, selector: #selector(xAPIManager.delayedConnection(_:)), userInfo: request, repeats: false)
				RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
			} else if (internetAvailability == ReachabilityStatus.notReachable) {
				if (shouldNotifyAboutInternetConnection && !internetAlertIsPresent) {
					internetAlertIsPresent = true
					UIAlertView(title: localized("connection_problem"), message: localized("check_internet"), delegate: DELEGATE, cancelButtonTitle: localized("ok")).show()
				}
				completionBlock?(false, nil, nil, nil)
			} else {
				if (!silent) {
					LoadingView.show()
				}
				let connection:NSURLConnection? = NSURLConnection(request: request, delegate: self, startImmediately: false)
				connection?.start()
				
				if (request.url?.absoluteString != nil && LOG_ACTIVITY) {
					let method:String? = request.httpMethod
					if (method != nil) {
						print(method!)
					}
					print("Request URL:\n\(request.url!.absoluteString)")
				}
			}
		} else {
			completionBlock?(false, nil, nil, "Error creating the url request")
		}
	}
	
	func delayedConnection(_ timer:Timer) {
		startConnectionWithRequest(timer.userInfo as? URLRequest)
	}
	
	//MARK: Download Functions
	
	func getStudentDetails(_ completion:@escaping xAPICompletionBlock) {
		completionBlock = completion
		var request:URLRequest?
		if staff() {
			if let url = urlWithHost("https://sp.data.alpha.jisc.ac.uk/", path: "staff/") {
				request = URLRequest(url: url)
			}
		} else {
			if let url = urlWithHost("https://sp.data.alpha.jisc.ac.uk/", path: "student/") {
				request = URLRequest(url: url)
			}
		}
		if let token = xAPIToken() {
			request?.addValue("Bearer \(token)\"}", forHTTPHeaderField: "Authorization")
		}
		startConnectionWithRequest(request)
	}
	
	func getIDPS(_ completion:@escaping xAPICompletionBlock) {
		completionBlock = completion
		startConnectionWithRequest(createGetRequest(xAPIGetIDPSPath, withJWT: false))
	}
	
	func getActivityPoints(_ period:kXAPIActivityPointsPeriod, completion:@escaping xAPICompletionBlock) {
		completionBlock = completion
		startConnectionWithRequest(createGetRequest("\(xAPIGetActivityPointsPath)?scope=\(period.rawValue)", withJWT: true))
	}
	
	func getModules(_ completion:@escaping xAPICompletionBlock) {
		completionBlock = completion
		startConnectionWithRequest(createGetRequest(xAPIGetModulesPath, withJWT: true))
	}
	
	func getModuleTest(_ completion:@escaping xAPICompletionBlock) {
		completionBlock = completion
		startConnectionWithRequest(createGetRequest("module/test?scope=overall", withJWT: true))
	}
	
	func getAttainment(_ completion:@escaping xAPICompletionBlock) {
		completionBlock = completion
		startConnectionWithRequest(createGetRequest(xAPIGetAttainmentPath, withJWT: true))
	}
	
	func getEngagementData(_ options:EngagementGraphOptions, completion:@escaping xAPICompletionBlock) {
		completionBlock = completion
		var path = xAPIGetEngagementDataPath
		
		var parameters = [String]()
		if let scope = options.scope {
			parameters.append("scope=\(scope.rawValue)")
		}
		if let filterType = options.filterType {
			parameters.append("filterType=\(filterType.rawValue)")
		}
		if let filterValue = options.filterValue {
			parameters.append("filterValue=\(filterValue)")
		}
		if let compareType = options.compareType {
			parameters.append("compareType=\(compareType.rawValue)")
		}
		if let compareValue = options.compareValue {
			parameters.append("compareValue=\(compareValue)")
		}
		if parameters.count > 0 {
			path = "\(path)?\((parameters as NSArray).componentsJoined(by: "&"))"
		}
		startConnectionWithRequest(createGetRequest(path, withJWT: true))
	}
}
