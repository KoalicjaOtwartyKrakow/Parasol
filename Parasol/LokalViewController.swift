//
//  LokalViewController.swift
//  Parasol
//
//  Created by Daniel Banasik on 27/02/2022.
//

import UIKit

class LokalViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var personalDataLbl: UILabel!
    @IBOutlet weak var personalDataPanel: UIView!
    
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var addressPanel: UIView!
    
    @IBOutlet weak var additionalInfoLbl: UILabel!
    @IBOutlet weak var additionalInfoPanel: UIView!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var telephoneTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var streetTF: UITextField!
    @IBOutlet weak var strNumberTF: UITextField!
    @IBOutlet weak var flatNumberTF: UITextField!
    @IBOutlet weak var postalCodeTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var numOfPlacesTF: UITextField!
    
    @IBOutlet weak var additionalInfoTV: UITextView!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var offsetConstr: NSLayoutConstraint!
    
    private var allTextFields : [UITextField] = []
    
    private var keyboardShown:Bool = false
    private var currentOffsetNeeded = 0.0
    
    private var chata : Chata! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFromLocation), name: NSNotification.Name("updateFromLocation"), object: nil)
        
        allTextFields = [nameTF,
                         telephoneTF,
                        emailTF,
                        streetTF,
                        strNumberTF,
                        flatNumberTF,
                        postalCodeTF,
                        cityTF,
                        stateTF,
                        numOfPlacesTF]
        
        allTextFields.forEach { tf in
            tf.delegate = self
        }
        
        DC.getLocation()
    }
    
    @objc func updateFromLocation(){
        self.streetTF.text = DC.myPlacemark.thoroughfare
        self.postalCodeTF.text = DC.myPlacemark.postalCode
        self.cityTF.text = DC.myPlacemark.locality
        self.stateTF.text = DC.myPlacemark.administrativeArea
    }
    
    @objc func hideKeybaord(){
        self.additionalInfoTV.resignFirstResponder()
        
        self.allTextFields.forEach { tf in
            tf.resignFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if keyboardShown {
                return
            }
            
            keyboardShown = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if !keyboardShown {
            return
        }
        keyboardShown = false
        
        self.offsetConstr.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func stopEditing(_ sender: Any) {
        hideKeybaord()
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        hideKeybaord()
        
        chata = Chata()
        chata.APT_NUM = flatNumberTF.text ?? ""
        chata.CITY = cityTF.text ?? ""
        chata.CNT_NAME = wojewodztwa(rawValue: stateTF.text ?? "")!
        chata.DESCRIPTION = additionalInfoTV.text ?? ""
        chata.LANDLORD_EMAIL = emailTF.text ?? ""
        chata.LANDLORD_PHONE = telephoneTF.text ?? ""
        chata.LANDLORD_NAME = nameTF.text ?? ""
        chata.PLACES_NUM = Int(numOfPlacesTF.text ?? "") ?? 1
        chata.ST_NAME = streetTF.text ?? ""
        chata.ST_NUM = strNumberTF.text ?? ""
        chata.ZIP = postalCodeTF.text ?? ""
        
        let params = chata.postDictionary()
        DC.sendNewChataWith(params: params) {
        (url, code, message, data) in
            if code.isSuccess {
                
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if allTextFields.firstIndex(of: textField)! < 3 {
            currentOffsetNeeded = 0
        }else if allTextFields.firstIndex(of: textField)! >= 3 &&
                    allTextFields.firstIndex(of: textField)! < 9
        {
            currentOffsetNeeded = 200
        }else{
            currentOffsetNeeded = 400
        }
        
        self.offsetConstr.constant = -currentOffsetNeeded
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentOffsetNeeded = 400
        
        self.offsetConstr.constant = -currentOffsetNeeded
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let idx = textField.tag
        
        if idx < 10 {
            self.view.viewWithTag(idx+1)?.becomeFirstResponder()
        }
        
        return true
    }
}
