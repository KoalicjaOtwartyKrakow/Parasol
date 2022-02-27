//
//  Extensions.swift
//  Parasol
//
//  Created by Daniel Banasik on 27/02/2022.
//

import Foundation
import UIKit
import CoreLocation

extension Int {
    var isSuccess : Bool { return 200...299 ~= self }
}

extension UIDevice {
    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

extension Locale {
    func isoCode(for countryName: String) -> String? {
        let needle = countryName.replacingOccurrences(of: "-", with: " ").lowercased()
        return Locale.isoRegionCodes.first(where: { (code) -> Bool in
            if let countryString = localizedString(forRegionCode: code)?.lowercased().replacingOccurrences(of: "&", with: " and ").replacingOccurrences(of: "  ", with: " ") {
                return countryString.contains(needle) || needle.contains(countryString)
            }
            return false
        })
    }
}

extension CLPlacemark {

    var compactAddress: String? {
        if let name = name {
            var result = name

            if let street = thoroughfare {
                result += ", \(street)"
            }

            if let city = locality {
                result += ", \(city)"
            }

            if let country = country {
                result += ", \(country)"
            }

            return result
        }

        return nil
    }

}
