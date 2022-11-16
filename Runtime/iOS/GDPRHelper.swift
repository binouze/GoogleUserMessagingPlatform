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
    
    @objc public func logVendorConsents() -> String
    {
        return UserDefaults.standard.string(forKey: "IABTCF_VendorConsents") ?? ""
    }
    @objc public func logPurposeConsents() -> String
    {
        
        return UserDefaults.standard.string(forKey: "IABTCF_PurposeConsents") ?? ""
    }
    
    @objc public func isGDPR() -> Bool
    {
        let settings = UserDefaults.standard
        let gdpr = settings.integer(forKey: "IABTCF_gdprApplies")
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
        let vendorConsent = settings.string(forKey: "IABTCF_VendorConsents") ?? ""
        let vendorLI = settings.string(forKey: "IABTCF_VendorLegitimateInterests") ?? ""
        let purposeLI = settings.string(forKey: "IABTCF_PurposeLegitimateInterests") ?? ""
        
        /*let googleId = vendorID
        let hasGoogleVendorConsent = hasAttribute(input: vendorConsent, index: googleId)
        let hasGoogleVendorLI = hasAttribute(input: vendorLI, index: googleId)*/
        
        // Minimum required for at least non-personalized ads
        return hasConsentFor([1], purposeConsent) && hasConsentOrLegitimateInterestFor([2,7,9,10], purposeConsent, purposeLI)
                             
    }

    @objc public func canShowPersonalizedAds() -> Bool
    {
        let settings = UserDefaults.standard
                
        //https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details
        //https://support.google.com/admob/answer/9760862?hl=en&ref_topic=9756841
              
        // required for personalized ads
        let purposeConsent = settings.string(forKey: "IABTCF_PurposeConsents") ?? ""
        let vendorConsent = settings.string(forKey: "IABTCF_VendorConsents") ?? ""
        let vendorLI = settings.string(forKey: "IABTCF_VendorLegitimateInterests") ?? ""
        let purposeLI = settings.string(forKey: "IABTCF_PurposeLegitimateInterests") ?? ""
        
        /*let googleId = vendorID
        let hasGoogleVendorConsent = hasAttribute(input: vendorConsent, index: googleId)
        let hasGoogleVendorLI = hasAttribute(input: vendorLI, index: googleId)*/
        
        return hasConsentFor([1,3,4], purposeConsent)
            && hasConsentOrLegitimateInterestFor([2,7,9,10], purposeConsent, purposeLI)
    }
}
