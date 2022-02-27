//
//  ViewController.swift
//  Parasol
//
//  Created by Daniel Banasik on 26/02/2022.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    
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
        
        /*
        DC.getAll {
            url, code, message, responseObj in
            
            if code.isSuccess {
                do{
                    let chatas = try JSONDecoder().decode([Chata].self, from: responseObj as! Data)
                    DLog(chatas.count)
                }catch{
                    DLog(error)
                }
            }
            
        }
         */
    }
    
    @IBAction func formularzBtnPressed(_ sender: Any) {
        
    }
    
    private func getMapData(){
        DC.getAll {
            url, code, message, responseObj in
            
            if code.isSuccess {
                do{
                    let chatas = try JSONDecoder().decode([Chata].self, from: responseObj as! Data)
                    DLog(chatas.count)
                }catch{
                    DLog(error)
                }
            }
            
        }
    }
    

}

