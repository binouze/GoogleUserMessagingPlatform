//
//  GDPRHelper.swift
//  UnityFramework
//
//  Created by Benjamin BOUFFIER on 16/11/2022.
//

import Foundation

@objc public class GDPRHelper : NSObject
{
    @objc public static let shared = GDPRHelper()
    
    @objc public func getVendorConsents() -> String
    {
        return UserDefaults.standard.string(forKey: "IABTCF_VendorConsents") ?? ""
    }
    @objc public func getPurposeConsents() -> String
    {
        return UserDefaults.standard.string(forKey: "IABTCF_PurposeConsents") ?? ""
    }
    @objc public func getAddtlConsent() -> String
    {
        return UserDefaults.standard.string(forKey: "IABTCF_AddtlConsent") ?? ""
    }
    
    @objc public func isGDPR() -> Bool
    {
        let settings = UserDefaults.standard
        let gdpr     = settings.integer(forKey: "IABTCF_gdprApplies") ?? 0
        return gdpr == 1
    }

    // Check if a binary string has a "1" at position "index" (1-based)
    @objc public func hasAttribute(input: String, index: Int) -> Bool
    {
        return input.count >= index && String(Array(input)[index-1]) == "1"
    }

    // Check if consent is given for a list of purposes
    @objc public func hasConsentFor(_ purposes: [Int], _ purposeConsent: String) -> Bool
    {
        return purposes.allSatisfy { i in hasAttribute(input: purposeConsent, index: i) }
    }

    // Check if a vendor either has consent or legitimate interest for a list of purposes
    @objc public func hasConsentOrLegitimateInterestFor(_ purposes: [Int], _ purposeConsent: String, _ purposeLI: String) -> Bool
    {
        return purposes.allSatisfy
        { i in
            hasAttribute(input: purposeLI, index: i) ||
            hasAttribute(input: purposeConsent, index: i)
        }
    }

    @objc public func canShowAds() -> Bool
    {
        let settings = UserDefaults.standard
        
        //https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details
        //https://support.google.com/admob/answer/9760862?hl=en&ref_topic=9756841
        
        let purposeConsent = settings.string(forKey: "IABTCF_PurposeConsents") ?? ""
        let vendorConsent  = settings.string(forKey: "IABTCF_VendorConsents") ?? ""
        let vendorLI       = settings.string(forKey: "IABTCF_VendorLegitimateInterests") ?? ""
        let purposeLI      = settings.string(forKey: "IABTCF_PurposeLegitimateInterests") ?? ""
        
        /*let googleId = vendorID
        let hasGoogleVendorConsent = hasAttribute(input: vendorConsent, index: googleId)
        let hasGoogleVendorLI = hasAttribute(input: vendorLI, index: googleId)*/
        
        // Minimum required for at least non-personalized ads
        return hasConsentFor([1], purposeConsent) && 
               hasConsentOrLegitimateInterestFor([2,7,9,10], purposeConsent, purposeLI)
                             
    }

    @objc public func canShowPersonalizedAds() -> Bool
    {
        let settings = UserDefaults.standard
                
        //https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details
        //https://support.google.com/admob/answer/9760862?hl=en&ref_topic=9756841
              
        // required for personalized ads
        let purposeConsent = settings.string(forKey: "IABTCF_PurposeConsents") ?? ""
        let vendorConsent  = settings.string(forKey: "IABTCF_VendorConsents") ?? ""
        let vendorLI       = settings.string(forKey: "IABTCF_VendorLegitimateInterests") ?? ""
        let purposeLI      = settings.string(forKey: "IABTCF_PurposeLegitimateInterests") ?? ""
        
        /*let googleId = vendorID
        let hasGoogleVendorConsent = hasAttribute(input: vendorConsent, index: googleId)
        let hasGoogleVendorLI = hasAttribute(input: vendorLI, index: googleId)*/
        
        return hasAttribute([1,3,4], purposeConsent) &&
               hasConsentOrLegitimateInterestFor([2,7,9,10], purposeConsent, purposeLI)
    }
    
    @objc public func isVendorAutorized(vendorID:Int) -> Bool
    {
        let settings      = UserDefaults.standard
        let vendorConsent = settings.string(forKey: "IABTCF_VendorConsents") ?? ""
        
        return hasAttribute(purposeConsent, vendorID)
    }
    
    @objc public func deleteOutdatedTCString() -> Bool
    {
        let settings = UserDefaults.standard
        
        // get IABTCF string containing creation timestamp;
        // fall back to string encoding timestamp 0 if nothing is currently stored
        let tcString      = settings.string(forKey: "IABTCF_TCString") ?? "AAAAAAA";
        let base64        = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        var dateSubstring = "";
        if( tcString.count >= 7 )
        {
            // le substring swift... ils auraient pu faire plus simple quand meme !
            let start     = tcString.index(tcString.startIndex, offsetBy: 1)
            let end       = tcString.index(tcString.startIndex, offsetBy: 7)
            let range     = start..<end
            dateSubstring = String(tcString[range]);
        }
        
        // interpret date substring as Base64-encoded integer value
        var timestamp:Int64 = 0;
        for c in dateSubstring
        {
            let value = Int64(indexOf(base64, c));
            timestamp = timestamp * 64 + value;
        }

        // timestamp is given is deci-seconds, convert to milliseconds
        timestamp *= 100;

        // compare with current timestamp to get age in days
        let now     = Date().millisecondsSince1970;
        let daysAgo = (now - timestamp) / (1000*60*60*24);
        
        // logging debug infos
        print("GDPRHelper:: deleteOutdatedTCString now = \(now) - timestamp = \(timestamp) - daysAgo = \(daysAgo)")
        
        // delete TC string if age is over a year
        if( daysAgo > 365 )
        {
            settings.set("", forKey: "IABTCF_TCString")
            return true;
        }
        
        return false;
    }
    
    private func indexOf( _ str:String, _ c:Character ) -> Int
    {
        if let firstIndex = str.firstIndex(of: c) {
            let index = str.distance(from: str.startIndex, to: firstIndex)
            return index;
        }
        return -1;
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}