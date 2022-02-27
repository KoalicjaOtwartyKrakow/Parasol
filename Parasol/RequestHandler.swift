//
//  RequestHandler.swift
//  Parasol
//
//  Created by Daniel Banasik on 27/02/2022.
//

import Foundation
import MobileCoreServices
import UniformTypeIdentifiers
import UIKit

class DLog {
    @discardableResult init(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        var data:[Any] = []
        data.append("[\(Date())] ")
        data.append(contentsOf: items)
        
        var idx = data.startIndex
        let endIdx = data.endIndex
        
        repeat {
            Swift.print(data[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
            while idx < endIdx
        #endif
    }
}

struct ContentType {
    static let json = "application/json"
    static let form = "application/x-www-form-urlencoded; charset=UTF-8"
}

typealias AppCompletionHandler = (_ url: String, _ code: Int, _ message: String, _ responseObj: AnyObject?) -> Void
typealias AppDataCompletionHandler = (_ url: String, _ code: Int, _ message: String, _ data: Data?) -> Void
typealias AWSS3CompletionHandler = (_ url: String, _ code: Int) -> Void

class RequestHandler {

    var currentCompletionHandlerObj: AppCompletionHandler?
    
    init() {
        
    }
    //MARK: - Request methods
    
    private func mobileAgent() -> String {
        return "\(UIDevice.current.systemName)/\(UIDevice.current.systemVersion) \(UIDevice.current.model)/\(UIDevice.current.modelIdentifier) \(Bundle.main.infoDictionary!["CFBundleName"]!)/\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)"
    }
    
    func get(_ message: String, url: String, allowUIAnimations:Bool = true, headerFields: Dictionary <String, String> = ["Content-Type": ContentType.json], handleCompletion:  @escaping AppCompletionHandler) {
        currentCompletionHandlerObj = handleCompletion
        request(message, url: url, uiAnimations:allowUIAnimations, httpMethod: "GET", requestParams: nil, headers: headerFields)
    }
    
    func post(_ message: String, url: String, allowUIAnimations:Bool = true, parameters: Any?, headerfields: Dictionary <String, String> = ["Content-Type": ContentType.json], handleCompletion:  @escaping AppCompletionHandler) {
        currentCompletionHandlerObj = handleCompletion
        request(message, url: url, uiAnimations:allowUIAnimations, httpMethod: "POST", requestParams: parameters, headers: headerfields)
    }
    
    func put(_ message: String, url: String, allowUIAnimations:Bool = true, parameters: Any?, headerfields: Dictionary <String, String> = ["Content-Type": ContentType.json], handleCompletion:  @escaping AppCompletionHandler) {
        currentCompletionHandlerObj = handleCompletion
        request(message, url: url, uiAnimations:allowUIAnimations, httpMethod: "PUT", requestParams: parameters, headers: headerfields)
    }
    
    //MARK: - URL Connections Methods
    /**
     * Initiate Request with URL Session
     */
    func request(_ message: String, url: String, uiAnimations:Bool = true, httpMethod: String, requestParams: Any?, headers: Dictionary <String, String>) {
        if let reachabilityObj = DC.reachability {
            if reachabilityObj.isReachable, let requestUrl = URL(string: url) {
                
                var headerfields: Dictionary <String, String> = headers
                headerfields["User-Agent"] = self.mobileAgent()

                headerfields["X-Application"] = "Parasol"
                
                var request = URLRequest(url: requestUrl)
                request.httpMethod = httpMethod
                request.cachePolicy = .reloadIgnoringCacheData
                request.timeoutInterval = 30
                
                for (key, value) in headerfields {
                    request.addValue(value, forHTTPHeaderField: key)
                }

                let debugString = "URL: \(url)\nSent headers = \(String(describing: request.allHTTPHeaderFields))"
                DLog(debugString)
                
                //Add HTTP Request Parameters
                if let requestDict = requestParams {
                    if headerfields["Content-Type"] == ContentType.form {
                        request.httpBody = getFormData(requestDict)
                    } else {
                        do {
                            request.httpBody = try JSONSerialization.data(withJSONObject: requestDict, options: .prettyPrinted)
                        } catch let error {
                            DLog(error.localizedDescription)
                        }
                    }
                }
                
                let allowUIAnimations = uiAnimations
                
                if allowUIAnimations {
                    self.startAnimation(message: message)
                }
                
                
                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                    [weak self]
                    data, response, error in
                    
                    let debugString = "URL: \(url)\nReceived headers = \(String(describing: response))"
                    DLog(debugString)
                    
                    guard error == nil && data != nil else {// check for fundamental networking error
                        DispatchQueue.main.async {
                            
                            let debugString = "URL: \(url)\nError= \(String(describing: error))"
                            DLog(debugString)
                            
                            if allowUIAnimations {
                                self?.stopAnimation()
                            }
                            self?.processResponse( 102, url:"", message: "\(error?.localizedDescription ?? "NetworkError")", data: nil)
                        }
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse , !httpStatus.statusCode.isSuccess {
                        
                        DispatchQueue.main.async {
                            if allowUIAnimations {
                                self?.stopAnimation()
                            }
                            self?.processResponse(httpStatus.statusCode, url:(response?.url?.absoluteString)!, message: "\(error?.localizedDescription ?? "Error")", data: data as Data?)
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        if allowUIAnimations {
                            self?.stopAnimation()
                        }
                        let httpStatus = response as? HTTPURLResponse
                        self?.processResponse((httpStatus?.statusCode)!, url:(response?.url?.absoluteString)!, message: "Success", data: data as Data?)
                    }
                }
                task.resume()
            }
        }
    }
    
    /**
     * Method for process Responses and return json
     **/
    func processResponse( _ code : Int, url:String, message : String , data: Data!) {

        let debugString = "Url: \(url)\nCode: \(code)\nMessage: \(message)"
        DLog("\(debugString)\nResponseData:\n\(String(data: data, encoding: .utf8) ?? "")\n")
        
        self.currentCompletionHandlerObj!(url, code, message, data as AnyObject?)
    }
    
    func clearCookies() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
    func allCookies() -> Array<HTTPCookie>? {
        return HTTPCookieStorage.shared.cookies
    }
    
    func sessionCookie() -> String? {
        var result:String? = nil
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if cookie.name == "iPlanetDirectoryPro" {
                    result = cookie.value
                }
            }
        }
        return result
    }

    func getFormData(_ requestDict: Any) -> Data {
        var postString: String = ""
        for item in requestDict as! [String : String] {
            let appendString = postString != "" ? "\(postString)&" : ""
            postString = appendString + item.0 + "=" + item.1
        }
        return postString.data(using: .utf8)!
    }
    
    //MARK: - Activity Indicator
    /**
     *Method for start and show activity indicator
     */
    func startAnimation(message: String?) {
        
    }
    
    /**
     *Method for stop and remove activity indicator
     */
    func stopAnimation() {
        
    }
    
}
