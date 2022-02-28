//
//  ViewController.swift
//  Parasol
//
//  Created by Daniel Banasik on 26/02/2022.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    var mapData : Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMapData()
    }
    
    @IBAction func lokalBtnPressed(_ sender: Any) {
        let newL = LokalViewController()
            self.present(newL, animated: true) {
        }
    }
    
    @IBAction func koordynatorBrtnPressed(_ sender: Any) {
        if let url = URL(string: DC.wolontariusz) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func formularzBtnPressed(_ sender: Any) {
        getContract()
    }
    
    private func getMapData(){
        DC.getStats(handleCompletion: {
            url, code, message, responseObj in
            
            if code.isSuccess {
                
                if let data =  responseObj as? Data {
                    
                    do {
                        self.mapData = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    } catch let error {
                        DLog(error.localizedDescription)
                    }
                }
            }
        })
    }
    
    private func getContract(){
        DC.getContractUrl(handleCompletion: {
            url, code, message, responseObj in
            
            if code.isSuccess {
                if let urlString = String(data:(responseObj as! Data), encoding: .utf8) {
                    if let url = URL(string: urlString.replacingOccurrences(of: "\"", with: "")) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }else{
                        if let url = URL(string: urlString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                }
            }
        })
    }
}
