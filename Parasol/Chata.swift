//
//  Chata.swift
//  Parasol
//
//  Created by Daniel Banasik on 27/02/2022.
//

import Foundation


enum wojewodztwa : String {
    case DOLNOSLASKIE = "dolnośląskie"
    case KUJAWSKO_POMORSKIE = "kujawsko-pomorskie"
    case LUBELSKIE = "lubelskie"
    case LUBUSKIE = "lubuskie"
    case LODZKIE = "łódzkie"
    case MALOPOLSKIE = "małopolskie"
    case MAZOWIECKIE = "mazowieckie"
    case OPOLSKIE = "opolskie"
    case PODKARPACKIE = "podkarpackie"
    case PODLASKIE = "podlaskie"
    case POMORSKIE = "pomorskie"
    case SLASKIE = "śląskie"
    case SWIETOKRZYSKIE = "świętokrzyskie"
    case WARMINSKO_MAZURSKIE = "warmińsko-mazurskie"
    case WIELKOPOLSKIE = "wielkopolskie"
    case ZACHODNIOPOMORSKIE = "zachodniopomorskie"
}


struct Chata : Codable {
    
    var ZIP: String
    var CITY: String
    var DESCRIPTION: String
    var LANDLORD_PHONE: String
    var ApartmentId: String
    var LANDLORD_EMAIL: String
    var PLACES_NUM: Int
    var LANDLORD_NAME: String
    var CNT_NAME: String //wojewodztwo
    var APT_NUM: String
    var ST_NAME: String //ulica
    var VOLUNTEER_NAME: String
    var CreationTime: String
    var PLACES_BUSY: Int
    var ST_NUM: String
    var IS_VERIFIED: Bool
    
    enum CodingKeys : String, CodingKey {
        case ZIP
        case CITY
        case DESCRIPTION
        case LANDLORD_PHONE
        case ApartmentId
        case LANDLORD_EMAIL
        case PLACES_NUM
        case LANDLORD_NAME
        case CNT_NAME
        case APT_NUM
        case ST_NAME
        case VOLUNTEER_NAME
        case CreationTime
        case PLACES_BUSY
        case ST_NUM
        case IS_VERIFIED
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.ZIP = values.contains(.ZIP) ? try values.decode(String.self, forKey: .ZIP) : ""
        self.CITY = values.contains(.CITY) ? try values.decode(String.self, forKey: .CITY) : ""
        self.DESCRIPTION = values.contains(.DESCRIPTION) ? try values.decode(String.self, forKey: .DESCRIPTION) : ""
        self.LANDLORD_PHONE = values.contains(.LANDLORD_PHONE) ? try values.decode(String.self, forKey: .LANDLORD_PHONE) : ""
        self.ApartmentId = values.contains(.ApartmentId) ? try values.decode(String.self, forKey: .ApartmentId) : ""
        self.LANDLORD_EMAIL = values.contains(.LANDLORD_EMAIL) ? try values.decode(String.self, forKey: .LANDLORD_EMAIL) : ""
        self.PLACES_NUM = values.contains(.PLACES_NUM) ? try values.decode(Int.self, forKey: .PLACES_NUM) : 0
        self.LANDLORD_NAME = values.contains(.LANDLORD_NAME) ? try values.decode(String.self, forKey: .LANDLORD_NAME) : ""
        self.CNT_NAME = values.contains(.CNT_NAME) ? try values.decode(String.self, forKey: .CNT_NAME) : ""
        self.APT_NUM = values.contains(.APT_NUM) ? try values.decode(String.self, forKey: .APT_NUM) : ""
        self.ST_NAME = values.contains(.ST_NAME) ? try values.decode(String.self, forKey: .ST_NAME) : ""
        self.VOLUNTEER_NAME = values.contains(.VOLUNTEER_NAME) ? try values.decode(String.self, forKey: .VOLUNTEER_NAME) : ""
        self.CreationTime = values.contains(.CreationTime) ? try values.decode(String.self, forKey: .CreationTime) : ""
        self.PLACES_BUSY = values.contains(.PLACES_BUSY) ? try values.decode(Int.self, forKey: .PLACES_BUSY) : 0
        self.ST_NUM = values.contains(.ST_NUM) ? try values.decode(String.self, forKey: .ST_NUM) : ""
        self.IS_VERIFIED = values.contains(.IS_VERIFIED) ? try values.decode(Bool.self, forKey: .IS_VERIFIED) : false
        
    }
}
