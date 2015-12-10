//
//  RailsRequest.swift
//  RR
//
//  Created by Joe E. on 11/5/15.
//  Copyright © 2015 Joe E. All rights reserved.
//

import UIKit

private let _railsRequest = RailsRequest()
private let _default = NSUserDefaults.standardUserDefaults()

private let _API_URL = "https://floating-plateau-1275.herokuapp.com"
private let _USERS_LOGIN = "/login"
private let _USERS_REGISTER = "/signup"

private let NAME = "full_name"
private let USER = "user"
private let USERNAME = "username"
private let PASSWORD = "password"
private let EMAIL = "email"
private let ERRORS = "errors"

private let OK = "ok"
private let ERROR = "error"

private let ACCESS_TOKEN = "access_token" // need to get

class RailsRequest: NSObject {
    
    let vc = UIViewController()
    var deckSelected = Int()
    
    var cards = [String:AnyObject]()
    
    class func session() -> RailsRequest {return _railsRequest }
    
    var currentName: String? {
        get { return _default.objectForKey(NAME) as? String }
        set { _default.setObject(newValue, forKey: NAME) }
            
    }
    
    var currentUsername: String? {
        get { return _default.objectForKey(USERNAME) as? String }
        set { _default.setObject(newValue, forKey: USERNAME) }
        
    }
    
    var currentPassword: String? {
        get { return _default.objectForKey(PASSWORD) as? String }
        set { _default.setObject(newValue, forKey: PASSWORD) }
        
    }
    
    var currentEmail: String? {
        get { return _default.objectForKey(EMAIL) as? String }
        set { _default.setObject(newValue, forKey: EMAIL) }
    }
    
    /// The token captured after login/register used to make authenticated API calls.
    var token: String? {
        get { return _default.objectForKey(ACCESS_TOKEN) as? String }
        set { _default.setObject(newValue, forKey: ACCESS_TOKEN) }
        
    }

    private let base = _API_URL
    
    /**
     This method will try to login a user with the credentials below
     
     - parameter username: The name used when registering
     - parameter password: The password used when registering
     */
    
    func loginWithUsername(username: String, andPassword password: String, success:Bool -> ()) {
        var info = RequestInfo()
        info.endPoint = _USERS_LOGIN
        info.method = .POST
        info.parameters = [
            USERNAME : username,
            PASSWORD : password
        
        ]
    
        requestWithInfo(info) { (returnedInfo) -> () in
            if let user = returnedInfo?[USER] as? [String:AnyObject] {
                if let key = user[ACCESS_TOKEN] as? String {
                    self.token = key
                    success(true)
                    print(success)

                }
                
            }
            
            if let error = returnedInfo?[ERRORS] as? String {
                print(error)
                
            }
            
        }
        
    }
    
    func registerWithUsername(name: String, username:String, password:String, email:String, success: (Bool) -> ()) {
        var info = RequestInfo()
        info.endPoint = _USERS_REGISTER
        info.method = .POST
        info.parameters = [
            NAME : name,
            USERNAME : username,
            PASSWORD : password,
            EMAIL : email
        
        ]
        
        
        requestWithInfo(info) { (returnedInfo) -> () in
            if let user = returnedInfo?[USER] as? [String:AnyObject] {
                if let name = user[NAME] as? String {
                    print(name)
                    self.currentName = name
                }
                
                if let username = user[USERNAME] as? String {
                    print(username)
                    self.currentUsername = username
                }
                
                if let password = user[PASSWORD] as? String {
                    print(password)
                    self.currentPassword = password
                }
                
                if let email = user[EMAIL] as? String {
                    print(email)
                    self.currentEmail = email
                }
                
                if let key = user[ACCESS_TOKEN] as? String {
                    self.token = key
                    print(self.token)
                    print("token obtained")
                    success(true)
                    
                }
                
                if let error = returnedInfo?[ERRORS] as? [String] {
                    print(error)
                    success(false)
                    
                }
                
            }
            
        }
        
    }
    
    func postPhoto(photo: AnyObject) {
        var info = RequestInfo()
        info.endPoint = "/journeys/1/images"
        info.method = .POST
        info.parameters = [
            "photo": photo
        
        ]
        
    requestWithInfo(info) { (returnedInfo) -> () in
        
        }
        
    }
    
    /**
     Makes a generic request to the API, configured by the info parameter
     
     - parameter info:       Used to configure the API request
     - parameter completion: A completion block that may be called with an optional object. The obejct could be an Array of Dictionary, you must handle the type within the completion block
     */
    
    func requestWithInfo(info: RequestInfo, completion: (returnedInfo:AnyObject?) -> ()) {
        var fullURLString = base + info.endPoint
        print(fullURLString)
        
        for (i,(k,v)) in info.query.enumerate() {
            if i == 0 { fullURLString += "?" } else { fullURLString += "&" }
            fullURLString += "\(k)=\(v)"
            
        }
        
        guard let url = NSURL(string: fullURLString) else { return }
        let request = NSMutableURLRequest(URL: url)
        print("url: \(url)")
        
        request.HTTPMethod = info.method.rawValue
        
        if let token = token {
            print(token)
            request.setValue(token, forHTTPHeaderField: ACCESS_TOKEN)

        }
        
        if info.parameters.count > 0 {
            if let requestData = try? NSJSONSerialization.dataWithJSONObject(info.parameters, options: .PrettyPrinted) {
                if let jsonString = NSString(data: requestData, encoding: NSUTF8StringEncoding) {
                    request.setValue("\(jsonString.length)", forHTTPHeaderField: "Content-Length")
                    let postData =  jsonString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
                    
                    request.HTTPBody = postData
                    
                }
                
            }
            
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let data = data {
                if let returnedInfo = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) {
                    completion(returnedInfo: returnedInfo)
                    print("returned info:\(returnedInfo)")
                    
                }
                
            } else {
                print("nothing returned")
                
            }
            
        }
        
        task.resume()
    }
    
}

struct RequestInfo {
    enum MethodType:String {
        case POST, GET, DELETE
        
    }
    
 /// The part of the URL added to the base to make a specific API call.
    var endPoint: String!
    
 /// The method type (GET, POST, DELETE) used for modifying the API call
    var method: MethodType = .GET
    
 /// Parameters that are required/optional to be added to the API call.
    var parameters: [String:AnyObject] = [:]

    var query: [String:AnyObject] = [:]
    
}