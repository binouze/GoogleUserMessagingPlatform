//
//  GoogleUserMessagingPlatform.mm
//
//  Created by Benjamin BOUFFIER.
//  On 9/11/2022
//

#include <UserMessagingPlatform/UserMessagingPlatform.h>
#import <UnityAppController.h>
#import "UnityInterface.h"
#import "UnityFramework/UnityFramework-Swift.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - "C"

extern "C" 
{
    //////////////////////////////////////////
    // GoogleUserMessagingPlatform
    
    static bool IsInit = false;
    static bool IsFormAvailable = false;
    static bool IsLogEnabled = false;
    
    static bool DebugMode  = false;
    static bool ForceReset = false;
    static bool TargetChildren = false;
    static NSString * DebugDevice = nil;
    
    // There is no public unity header, need to declare this manually:
    // http://answers.unity3d.com/questions/58322/calling-unitysendmessage-requires-which-library-on.html
    extern void UnitySendMessage(const char *, const char *, const char *);
    
    void Log( NSString * nsmsg )
    {
        if( IsLogEnabled )
        {
            NSLog(@"[GoogleUserMessagingPlatform]: %@", nsmsg);
        }
    }
    void LogError( NSString * nsmsg )
    {
        NSLog(@"[GoogleUserMessagingPlatform]: %@", nsmsg);
    }
    
    void dispatchStatus( int status )
    {
        NSString* NSStatus    = [NSString stringWithFormat:@"%d",status];
        const char* strStatus = (const char*) [NSStatus UTF8String];
        
        NSLog(@"[GoogleUserMessagingPlatform]: DispatchStatus %@", NSStatus);
        
        UnitySendMessage( "GoogleUserMessagingPlatform", "OnFormDissmissedMessage", strStatus );
    }
    
    // -- EXPOSED TO UNITY -- //
    
    bool _GetCanShowAds()
    {
        NSString* vc = [[GDPRHelper shared] getVendorConsents];
        NSString* pc = [[GDPRHelper shared] getPurposeConsents];
        Log(@"GetCanShowAds %@ %@", pc, vc);
    
        return [[GDPRHelper shared] canShowAds];
    }
    
    void _EnableDebugLogging( bool enabled )
    {
        IsLogEnabled = enabled;
    }
    
    void _SetDebugMode( const char * device, bool forceReset )
    {
        DebugDevice = [NSString stringWithCString:device encoding:NSUTF8StringEncoding];
        DebugMode   = DebugDevice != nil && [DebugDevice length] > 0;
        ForceReset  = forceReset;
    }
    
    void _SetTargetChildren( bool val )
    {
        TargetChildren = val;
    }
    
    void _LoadForm( bool forceShow, bool forceDispatch )
    {
        if( !IsFormAvailable )
        {
            if( forceDispatch )
                dispatchStatus( 0 );
                
            LogError(@"LoadForm FORM NOT AVAILABLE");
            return;
        }
        
        [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *form, NSError *loadError)
            {
                if( loadError )
                {
                    if( forceShow )
                        dispatchStatus( 0 );
                        
                    // Handle the error
                    LogError( [NSString stringWithFormat:@"%@ / %@", @"onConsentFormLoadFailure ERROR ", loadError.description] );
                }
                else
                {
                    Log( [NSString stringWithFormat:@"%@ / %ld", @"onConsentFormLoadSuccess ", (long)UMPConsentInformation.sharedInstance.consentStatus] );
                
                    if( forceDispatch )
                        dispatchStatus( (int)UMPConsentInformation.sharedInstance.consentStatus );
                        
                    // Present the form
                    if( forceShow )
                    {
                        [form presentFromViewController:UnityGetGLViewController()
                              completionHandler:^(NSError *_Nullable dismissError)
                              {
                                  Log(@"onConsentFormDismissed");
                                  dispatchStatus( (int)UMPConsentInformation.sharedInstance.consentStatus );
                              }];
                    }
                }
            }];
    }
    
    bool _IsFormAvailable()
    {
        return IsFormAvailable;
    }

    void _Initialize() 
    {        
        if( IsInit )
            return;
        IsInit = true;
    
        Log(@"Initialize");
    
        // Create a UMPRequestParameters object.
        UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];
        // Set tag for under age of consent. Here NO means users are not under age.
        parameters.tagForUnderAgeOfConsent = TargetChildren;
        
        if( DebugMode )
        {
            LogError(@"MODE DEBUG");
            
            UMPDebugSettings *debugSettings     = [[UMPDebugSettings alloc] init];
            debugSettings.testDeviceIdentifiers = @[ DebugDevice ];
            debugSettings.geography             = UMPDebugGeographyEEA;
            parameters.debugSettings            = debugSettings;
            
            if( ForceReset )
            {
                LogError(@"RESETING DATAS");
                [UMPConsentInformation.sharedInstance reset];
            }
        }
        
        // Request an update to the consent information.
        [UMPConsentInformation.sharedInstance 
            requestConsentInfoUpdateWithParameters:parameters
            completionHandler:^(NSError *_Nullable error) 
            {
                if( error ) 
                {
                    // Handle the error.
                    LogError( [NSString stringWithFormat:@"%@ / %@", @"onConsentInfoUpdateFailure ERROR ", error.description] );
                } 
                else 
                {
                    // The consent information state was updated.
                    // You are now ready to check if a form is
                    // available.
                    if( UMPConsentInformation.sharedInstance.formStatus == UMPFormStatusAvailable ) 
                    {
                        Log(@"onConsentInfoUpdateSuccess FROM AVAILABLE");
                        IsFormAvailable = true;
                    }
                    else
                    {
                        Log(@"onConsentInfoUpdateSuccess FROM NOT AVAILABLE");
                    }
                    
                    _LoadForm( false, true );
                }
            }];
    }
}
