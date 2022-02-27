//
//  DataController.swift
//  Parasol
//
//  Created by Daniel Banasik on 27/02/2022.
//

import Foundation
import CoreLocation

//Shared Instance
let DC = DataController.sharedInstance

class DataController: NSObject, CLLocationManagerDelegate {
    
    #if PROD
    let post = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/prod/apartments"
    let get = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/prod/apartments"
    let count = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/prod/apartments/count"
    let contract = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/prod/doc/contract"
    #else
    let post = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/dev/apartments"
    let get = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/dev/apartments"
    let count = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/dev/apartments/count"
    let contract = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/dev/doc/contract"
    #endif
    
    var reachability: Reachability? = Reachability()!
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    var myPlacemark : CLPlacemark! = nil
    
    class var sharedInstance : DataController {
        struct Singleton {
            static let instance = DataController()
        }
        return Singleton.instance
    }
    
    var requestHandlers = [String: RequestHandler]()
    let semaphore = DispatchSemaphore(value: 1)
    
    override init() {
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getLocation(){
        // Create a CLLocationManager and assign a delegate
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    // Process Response
                    self.processResponse(withPlacemarks: placemarks, error: error)
                }
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        if let error = error {
            DLog("Unable to Reverse Geocode Location (\(error))")
            DLog("Unable to Find Address for Location")

        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                myPlacemark = placemark
                NotificationCenter.default.post(name: NSNotification.Name("updateFromLocation"), object: nil)
                DLog(placemark.compactAddress)
            } else {
                DLog("No Matching Addresses Found")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    
    func registerRequestHandler( _ requestObj:RequestHandler, for url:String){
        
        semaphore.wait()
        self.requestHandlers[url] = requestObj
        semaphore.signal()
        
    }
    
    func getAll(handleCompletion: @escaping AppCompletionHandler ) {
        
        let requestObj = RequestHandler()
        let url = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/dev/apartments"
        self.registerRequestHandler(requestObj, for:url)
        
        requestObj.get("all", url: url, allowUIAnimations: false) {
            (_ rUrl: String, _ code: Int, _ message: String, _ responseObj: AnyObject?) in
            
            if code.isSuccess {
                
            }else{
                
            }
            
            handleCompletion(rUrl, code, message, responseObj as AnyObject?)
        }
    }
    
    func sendNewChataWith(params: Dictionary<String, Any>, handleCompletion: @escaping AppDataCompletionHandler) {
        let requestObj = RequestHandler()
        let url = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/dev/apartments"
        self.registerRequestHandler(requestObj, for:url)
        
        requestObj.post("chata post", url: url, allowUIAnimations: false, parameters: params) {
            (_ rUrl: String, _ code: Int, _ message: String, _ responseObj: AnyObject?) in
            
            if code.isSuccess {
                
            }else{
                
            }
            
            handleCompletion(rUrl, code, message, responseObj as? Data)
        }
    }
    
    func sendChataUpdateWith(params: Dictionary<String, Any>, handleCompletion: @escaping AppDataCompletionHandler) {
        let requestObj = RequestHandler()
        let url = "https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/dev/apartments"
        self.registerRequestHandler(requestObj, for:url)
        
        requestObj.put("chata update", url: url, allowUIAnimations: false, parameters: params) {
            (_ rUrl: String, _ code: Int, _ message: String, _ responseObj: AnyObject?) in
            
            if code.isSuccess {
                
            }else{
                
            }
            
            handleCompletion(rUrl, code, message, responseObj as? Data)
        }
    }
    
    /*
     new GET endpoint to list volonteers:
     https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/dev/fundation
     New Post endpoint to confirm volunteer:
     https://cu2kg3w6c1.execute-api.eu-west-1.amazonaws.com/dev/fundation/volonteerconfirm
     */
}
