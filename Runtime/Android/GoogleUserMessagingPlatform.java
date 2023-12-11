package com.binouze;

import com.google.android.ump.ConsentForm;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.ConsentDebugSettings;
import com.google.android.ump.FormError;
import com.google.android.ump.UserMessagingPlatform;

import com.unity3d.player.UnityPlayer;
import com.binouze.GDRPHelper;
import android.util.Log;

public class GoogleUserMessagingPlatform
{
    private static final String  TAG            = "GoogleUserMessagingPlatform";
    private static       boolean loggingEnabled = false;
    
    private static void SendStatusMessage( String status )
    {
        logInfo( "SendStatusMessage " + status );
        UnityPlayer.UnitySendMessage( "GoogleUserMessagingPlatform", "OnFormDissmissedMessage", status );
    }
    
    /**
     * Enables verbose logging
     */
    public static void EnableDebugLogging( boolean flag ) 
    {
        loggingEnabled = flag;
    }
    
    private static boolean DebugMode      = false;
    private static boolean ForceReset     = false;
    private static boolean TargetChildren = false;
    private static String  DebugDevice    = null;
    
    /**
     * debug mode for a test device
     */
    public static void SetDebugMode( String device, boolean forceReset ) 
    {
        DebugDevice = device;
        DebugMode   = DebugDevice != null;
        ForceReset  = forceReset;
    }
    
    public static void SetTargetChildren( boolean val ) 
    {
        TargetChildren = val;
    }
    
    private static void logInfo( String msg ) 
    {
        if( loggingEnabled || DebugMode ) 
        {
            Log.i(TAG, TAG+"::"+msg);
        }
    }
    private static void logError( String msg ) 
    {
        Log.e(TAG, TAG+"::"+msg);
    }

    private static  ConsentInformation consentInformation;
    private static  ConsentForm        consentForm;
    private static  boolean            IsInit        = false;
    private static  boolean            FormAvailable = false;
    private static  int                ConsentStatus = ConsentInformation.ConsentStatus.UNKNOWN;
    
    /**
     * Start initialisation
     * call DoInitialize on the main thread
     */
    public static void Initialize()
    {
        UnityPlayer.currentActivity.runOnUiThread(
            (Runnable) () -> {
                DoInitialize();
            });
    }

    /**
     * Start initialisation
     */
    private static void DoInitialize()
    {
        if( IsInit )
            return;
        IsInit = true;
        
        logInfo("Initialize");
    
        boolean deleted = GDRPHelper.deleteOutdatedTCString();
        if( deleted )
            logInfo("deleted outdated TCF String");
            
        ConsentRequestParameters params;
        if( DebugMode )
        {
            logInfo("Mode Debug");
        
            ConsentDebugSettings debugSettings = new ConsentDebugSettings
                .Builder( UnityPlayer.currentActivity )
                .setDebugGeography( ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA )
                .addTestDeviceHashedId( DebugDevice )
                .build();
                
            // Set tag for underage of consent. Here false means users are not underage.
            params = new ConsentRequestParameters
                .Builder()
                .setTagForUnderAgeOfConsent(TargetChildren)
                .setConsentDebugSettings(debugSettings)
                .build();
            
        }
        else
        {
            // Set tag for underage of consent. Here false means users are not underage.
            params = new ConsentRequestParameters
                .Builder()
                .setTagForUnderAgeOfConsent(TargetChildren)
                .build();
        }
            
        consentInformation = UserMessagingPlatform.getConsentInformation( UnityPlayer.currentActivity );
        if( DebugMode && ForceReset )
        {
            logInfo("Force Reset Datas");
            consentInformation.reset();
        }
        
        consentInformation.requestConsentInfoUpdate(
            UnityPlayer.currentActivity,
            params,
            (ConsentInformation.OnConsentInfoUpdateSuccessListener) () -> 
            {
                // The consent information state was updated.
                // You are now ready to check if a form is available.
                if( consentInformation.isConsentFormAvailable() ) 
                {
                    logInfo("onConsentInfoUpdateSuccess FORM AVAILABLE");
                    FormAvailable = true;
                }
                else
                {
                    logError("onConsentInfoUpdateSuccess FORM NOT AVAILABLE");
                    FormAvailable = false;
                }
                
                // load the form
                LoadForm( false, true );
            },
            (ConsentInformation.OnConsentInfoUpdateFailureListener) formError -> 
            {
                // Handle the error.
                logError("onConsentInfoUpdateFailure ERROR: "+formError.getMessage());
            }
        );
    }
    
    /**
     * true if user accepted GDPR consent usage necessary to see ads
     */
    public static boolean GetCanShowAds()
    {
        if( DebugMode )
        {
            String vc = GDRPHelper.getVendorConsents();
            String pc = GDRPHelper.getPurposeConsents();
            String ac = GDRPHelper.getAddtlConsent();
            logInfo("GetCanShowAds "+pc+" "+vc+" "+ac);
        }
        
        return !GDRPHelper.isGDPR() || GDRPHelper.canShowAds();
    }
    
    /**
     * true if user accepted GDPR consent usage necessary to see ads
     */
    public static boolean GetGDPRRequired()
    {
        if( DebugMode )
        {
            String vc = GDRPHelper.getVendorConsents();
            String pc = GDRPHelper.getPurposeConsents();
            String ac = GDRPHelper.getAddtlConsent();
            logInfo("GetGDPRRequired "+pc+" "+vc+" "+ac);
        }
        
        return GDRPHelper.isGDPR();
    }
    
    /**
     * récupérer le string purpose consent
     */
    public static String GetPurposeConsent()
    {
        return GDRPHelper.getPurposeConsents();
    }
    
    /**
     * recuperer le status de consentement pour un vendor par son ID
     */
    public static boolean GetConsentForVendor(int vendorID)
    {
        if( DebugMode )
        {
            String vc = GDRPHelper.getVendorConsents();
            String pc = GDRPHelper.getPurposeConsents();
            String ac = GDRPHelper.getAddtlConsent();
            logInfo("GetConsentForVendor "+pc+" "+vc+" "+ac);
        }
        
        return GDRPHelper.isVendorAutorized(Integer.valueOf(vendorID));
    }
    
    /**
     * recuperer le status de consentement pour un vendor par son ID
     */
    public static boolean GetConsentForAdditional(int vendorID)
    {
        if( DebugMode )
        {
            String vc = GDRPHelper.getVendorConsents();
            String pc = GDRPHelper.getPurposeConsents();
            String ac = GDRPHelper.getAddtlConsent();
            logInfo("GetConsentForAdditional "+pc+" "+vc+" "+ac);
        }
        
        return GDRPHelper.isAddtlConsentAutorized(Integer.valueOf(vendorID));
    }
    
    /**
     * true if a form is available to be shown
     */
    public static boolean IsFormAvailable()
    {
        return FormAvailable;
    }
    
    /**
     * get the consent status
     */
    public static int GetConsentStatus()
    {
        return ConsentStatus;
    }
    
    /**
     * Show the form
     */
    public static void LoadForm( boolean forceShow, boolean sendStatusToUnity )
    {
        UnityPlayer.currentActivity.runOnUiThread(
            (Runnable) () -> {
                DoLoadForm(forceShow,sendStatusToUnity);
            });
    }
    
    private static void DoLoadForm( boolean forceShow, boolean sendStatusToUnity )
    {
        if( !FormAvailable )
        {
            if( forceShow )
                SendStatusMessage( "0" );
                
            logError("LoadForm FORM NOT AVAILABLE");
            return;
        }
    
        UserMessagingPlatform.loadConsentForm(
            UnityPlayer.currentActivity, 
            (ConsentInformation.OnConsentFormLoadSuccessListener) () -> 
            {
                GoogleUserMessagingPlatform.consentForm = consentForm;
                // Update consent status
                ConsentStatus = consentInformation.getConsentStatus();
                
                logInfo("onConsentFormLoadSuccess " + ConsentStatus);
                
                if( sendStatusToUnity )
                    SendStatusMessage( String.format("%d", consentInformation.getConsentStatus()) );
                
                if( forceShow ) 
                {
                    consentForm.show( 
                        UnityPlayer.currentActivity,
                        (ConsentInformation.OnConsentFormDismissedListener) showFormError ->
                        {
                            if( showFormError != null )
                            {
                                logError("onConsentFormDismissed with error: "+showFormError.getMessage());
                            }
                            else
                            {
                                // Update consent status
                                ConsentStatus = consentInformation.getConsentStatus();
                                // Send status update to Unity
                                SendStatusMessage( String.format("%d", consentInformation.getConsentStatus()) );
                                
                                logInfo("onConsentFormDismissed "+ConsentStatus);
                            }
                        }
                    );
                 }
            },
            (ConsentInformation.OnConsentFormLoadFailureListener) formError -> 
            {
                if( forceShow )
                    SendStatusMessage( "0" );
                
                // Handle the error.
                logError("onConsentFormLoadFailure ERROR: "+formError.getMessage());
            }
        );
    }
}