package com.binouze;

import androidx.preference.PreferenceManager;
import android.content.SharedPreferences;
import com.unity3d.player.UnityPlayer;
import java.util.*;
import java.lang.*;
import android.util.Log;

public class GDRPHelper
{
    private static final String TAG = "GoogleUserMessagingPlatform::GDRPHelper";
    //IABTCF_AddtlConsent

    public static String getVendorConsents()
    {
        return PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity).getString("IABTCF_VendorConsents", "");
    }
    public static String getVendorLI()
    {
        return PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity).getString("IABTCF_VendorLegitimateInterests", "");
    }
    public static String getPurposeConsents()
    {
        return PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity).getString("IABTCF_PurposeConsents", "");
    }
    public static String getPurposeLI()
    {
        return PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity).getString("IABTCF_PurposeLegitimateInterests", "");
    }
    public static String getAddtlConsent()
    {
        return PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity).getString("IABTCF_AddtlConsent", "");
    }

    public static Boolean isGDPR()
    {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity);
        Integer           gdpr  = prefs.getInt("IABTCF_gdprApplies", 0);
        
        return gdpr == 1;
    }
    
    public static Boolean canShowAds()
    {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity);
    
        //https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details
        //https://support.google.com/admob/answer/9760862?hl=en&ref_topic=9756841
        // vendor id list: https://iabeurope.eu/vendor-list-tcf/
    
        String purposeConsent = prefs.getString("IABTCF_PurposeConsents", "");
        String vendorConsent  = prefs.getString("IABTCF_VendorConsents","");
        String vendorLI       = prefs.getString("IABTCF_VendorLegitimateInterests","");
        String purposeLI      = prefs.getString("IABTCF_PurposeLegitimateInterests","");
    
        // Minimum required for at least non-personalized ads
        return hasConsentFor( Arrays.asList(1), purposeConsent ) && 
               hasConsentOrLegitimateInterestFor( Arrays.asList(2,7,9,10), purposeConsent, purposeLI );
    }
    
    public static Boolean canShowPersonalizedAds()
    {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity);
    
        //https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details
        //https://support.google.com/admob/answer/9760862?hl=en&ref_topic=9756841
    
        String purposeConsent = prefs.getString("IABTCF_PurposeConsents", "");
        String vendorConsent  = prefs.getString("IABTCF_VendorConsents","");
        String vendorLI       = prefs.getString("IABTCF_VendorLegitimateInterests","");
        String purposeLI      = prefs.getString("IABTCF_PurposeLegitimateInterests","");
    
        return hasConsentFor( Arrays.asList(1,3,4), purposeConsent ) && 
               hasConsentOrLegitimateInterestFor( Arrays.asList(2,7,9,10), purposeConsent, purposeLI );
    }
    
    // -- FIREBASE -----------------------------------------------------------------------------------------------------
    
    public static Boolean getFirebase_ad_storage()
    {
        // https://developers.google.com/tag-platform/security/guides/implement-TCF-strings
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity);
        String purposeConsent   = prefs.getString("IABTCF_PurposeConsents", "");
        String purposeLI        = prefs.getString("IABTCF_PurposeLegitimateInterests", "");
    
        Boolean consent = hasConsentFor( Arrays.asList(1), purposeConsent );
        Boolean li      = hasConsentFor( Arrays.asList(1), purposeLI );
    
        return consent || li;
    }
    
     public static Boolean getFirebase_ad_personalization()
     {
         // https://developers.google.com/tag-platform/security/guides/implement-TCF-strings
         SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity);
         String purposeConsent   = prefs.getString("IABTCF_PurposeConsents", "");
         String purposeLI        = prefs.getString("IABTCF_PurposeLegitimateInterests", "");
     
         Boolean consent3 = hasConsentFor( Arrays.asList(3), purposeConsent );
         Boolean consent4 = hasConsentFor( Arrays.asList(4), purposeConsent );
         
         Boolean li3 = hasConsentFor( Arrays.asList(3), purposeLI );
         Boolean li4 = hasConsentFor( Arrays.asList(4), purposeLI );
     
         return (consent3 || li3) && (consent4 || li4);
     }
     
     public static Boolean getFirebase_ad_user_data()
     {
         // https://developers.google.com/tag-platform/security/guides/implement-TCF-strings
         SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity);
         String purposeConsent   = prefs.getString("IABTCF_PurposeConsents", "");
         String purposeLI        = prefs.getString("IABTCF_PurposeLegitimateInterests", "");
     
         Boolean consent1 = hasConsentFor( Arrays.asList(1), purposeConsent );
         Boolean consent7 = hasConsentFor( Arrays.asList(7), purposeConsent );
         
         Boolean li1 = hasConsentFor( Arrays.asList(1), purposeLI );
         Boolean li7 = hasConsentFor( Arrays.asList(7), purposeLI );
     
         return (consent1 || li1) && (consent7 || li7);
     }
    
    // -----------------------------------------------------------------------------------------------------------------
    
    /**
     * Savoir si un vendeur avec un ID specifie a ete autorise par l'utilisateur
     * @see https://iabeurope.eu/vendor-list-tcf/ for vendorList IDs
     */
    public static Boolean isVendorAutorized( Integer vendorID )
    {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity);
        String vendorConsent    = prefs.getString("IABTCF_VendorConsents","");
        return hasAttribute( vendorConsent, vendorID );
    }
    
    /**
     * Savoir si un vendeur avec un ID specifie a ete autorise par l'utilisateur
     * @see https://iabeurope.eu/vendor-list-tcf/ for vendorList IDs
     */
    public static Boolean isAddtlConsentAutorized( Integer externalID )
    {
        String strId            = externalID.toString();
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity);
        String addtlConsent     = prefs.getString("IABTCF_AddtlConsent","");
        return addtlConsent.contains(strId);
    }
    
    // Check if a binary string has a "1" at position "index" (1-based)
    private static Boolean hasAttribute( String input, Integer index )
    {
        return input.length() >= index && input.charAt(index-1) == '1';
    }
    
    // Check if consent is given for a list of purposes
    private static Boolean hasConsentFor( List<Integer> purposes, String purposeConsent )
    {
        for(int p : purposes) {
            if(!hasAttribute(purposeConsent, p)) {
                return false;
            }
        }
        return true;
        //return purposes.stream().allMatch( p -> hasAttribute(purposeConsent, p) );
    }
    
    // Check if a vendor either has consent or legitimate interest for a list of purposes
    private static Boolean hasConsentOrLegitimateInterestFor( List<Integer> purposes, String purposeConsent, String purposeLI )
    {
         for(int p : purposes) {
            if(!hasAttribute(purposeConsent, p) && !hasAttribute(purposeLI, p)) {
                return false;
            }
        }
        return true;
        //return purposes.stream().allMatch( p -> hasAttribute(purposeLI, p) || hasAttribute(purposeConsent, p) );
    }
    
    // this function deletes the IABTCF_TCString if the timestamp is too old (365 days or more)
    public static boolean deleteOutdatedTCString() 
    {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(UnityPlayer.currentActivity);

        // get IABTCF string containing creation timestamp;
        // fall back to string encoding timestamp 0 if nothing is currently stored
        String tcString      = prefs.getString("IABTCF_TCString", "AAAAAAA");
        String base64        = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        String dateSubstring = tcString.subSequence(1,7).toString();

        //interpret date substring as Base64-encoded integer value
        long timestamp = 0;
        for( int i=0; i<dateSubstring.length(); i++ ) 
        {
            char c    = dateSubstring.charAt(i);
            int value = base64.indexOf(c);
            timestamp = timestamp * 64 + value;
        }

        // timestamp is given is deci-seconds, convert to milliseconds
        timestamp *= 100;

        // compare with current timestamp to get age in days
        long now     = System.currentTimeMillis();
        long daysAgo = (now - timestamp) / (1000*60*60*24);
        
        // logging debug infos
        Log.i(TAG, TAG+":: deleteOutdatedTCString now = " + now + " - timestamp = " + timestamp + " - daysAgo = " + daysAgo);
        
        //delete TC string if age is over a year
        if( daysAgo > 365 ) 
        {
            prefs.edit().remove("IABTCF_TCString").apply();
            return true;
        }
        
        return false;
    }
}