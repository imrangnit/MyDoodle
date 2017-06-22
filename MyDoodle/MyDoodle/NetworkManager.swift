//
//  NetworkManager.swift
//  GettingStartedWithSafariViewController
//
//  Created by Mohd Imran on 6/20/17.
//  Copyright © 2017 Jordan Morgan. All rights reserved.
//

import UIKit

class NetworkRequest: NSObject {
    
    enum HTTPMethods : String {
        case GET
        case POST
        case PUT
        case UPDATE
        case DELETE
    }
    
    let rtoNetwork:TimeInterval = 30
    var objURLRequest:URLRequest!
    
    struct ContentType {
        static let textjson        = "text/json"
        static let textxml         = "text/xml"
        static let texthtml        = "text/html"
        static let applicationjson = "application/json"
        static let applicationJS   = "application/javascript"
        static let textJS          = "text/javascript"
        static let textPlain       = "text/plain"
    }
    
    convenience init(withURL url:String, withHttpMethd httpMethd:HTTPMethods) {
        self.init()
        
        guard let urlValue = URL(string: url) else {
            print("Not an URL")
            return
        }
        
        objURLRequest = URLRequest(url: urlValue, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: rtoNetwork)
        objURLRequest.httpBody = nil
        objURLRequest.allHTTPHeaderFields = nil
        objURLRequest.httpMethod = nil
        
    }
    
    convenience init(withURL url:String, withHttpBody httpBody:Dictionary<String,AnyObject>?, withHttpMethod httpMethod:HTTPMethods) {
        self.init()
        
        guard let urlValue = URL(string: url) else {
            print("Not an URL")
            return
        }
        
        objURLRequest = URLRequest(url: urlValue, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: rtoNetwork)
        objURLRequest.httpMethod = httpMethod.rawValue
        
        do {
            let httpData = try JSONSerialization.data(withJSONObject: httpBody ?? "", options: .prettyPrinted)
            objURLRequest.httpBody = httpData
        } catch let error {
            print("Error: ",error)
        }
        
    }
    
    convenience init(withURL url:String, withHttPBody httpBody:Dictionary<String, AnyObject>?, withHttpHeader httpHeader:Dictionary<String, String>?, withHttpMethod httpMethod:HTTPMethods) {
        self.init()
        
        guard let urlValue = URL(string: url) else {
            print("Not an URL")
            return
        }
        
        objURLRequest = URLRequest(url: urlValue, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: rtoNetwork)
        objURLRequest.httpMethod = httpMethod.rawValue
        
        do {
            let httpData = try JSONSerialization.data(withJSONObject: httpBody ?? "", options: .prettyPrinted)
            objURLRequest.httpBody = httpData
        } catch let error {
            print("Error: ",error)
        }
        
        objURLRequest.allHTTPHeaderFields = httpHeader
        
    }
    
}


class NetworkManager: NSObject {
    
    var sConfirguration:URLSessionConfiguration!
    
    override init() {
        super.init()
        
        sConfirguration = URLSessionConfiguration.default
    }
    
    func startAPIRequest(with objRequest:URLRequest, callBack callBackValue:@escaping (_ value:Any?, _ response:URLResponse?, _ error:Error?)->Void) -> Void {
        
        let session  = URLSession(configuration: sConfirguration)
        let dataTask = session.dataTask(with: objRequest, completionHandler: {(responseData:Data?, response:URLResponse?, error:Error?)->Void in
        
            guard let dataValue = responseData else{
                print("Data is nil")
                callBackValue(nil, response, error)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: dataValue, options: [])
                callBackValue(jsonObject, response, nil)
            } catch let error {
                print("Error:",error)
                callBackValue(nil, response, error)
            }
        })
        dataTask.resume()
        
    }

}
