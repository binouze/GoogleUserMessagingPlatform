//
//  GoogleUserMessagingPlatform.mm
//
//  Created by Benjamin BOUFFIER.
//  On 9/11/2022
//
// 
// #include <UserMessagingPlatform/UserMessagingPlatform.h>
// #import <UnityAppController.h>
// #import "UnityInterface.h"
// #import "UnityFramework/UnityFramework-Swift.h"
// 
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// #pragma mark - "C"
// 
// extern "C" 
// {
//     //////////////////////////////////////////
//     // GoogleUserMessagingPlatform
//     
//     static bool IsInit = false;
//     static bool IsFormAvailable = false;
//     static bool IsLogEnabled = false;
//     
//     static bool DebugMode  = false;
//     static bool ForceReset = false;
//     static bool TargetChildren = false;
//     static NSString * DebugDevice = nil;
//     
//     // There is no public unity header, need to declare this manually:
//     // http://answers.unity3d.com/questions/58322/calling-unitysendmessage-requires-which-library-on.html
//     extern void UnitySendMessage(const char *, const char *, const char *);
//     
//     void Log( NSString * nsmsg )
//     {
//         if( IsLogEnabled )
//         {
//             NSLog(@"[GoogleUserMessagingPlatform]: %@", nsmsg);
//         }
//     }
//     void LogError( NSString * nsmsg )
//     {
//         NSLog(@"[GoogleUserMessagingPlatform]: %@", nsmsg);
//     }
//     
//     void dispatchStatus( int status )
//     {
//         NSString* NSStatus    = [NSString stringWithFormat:@"%d",status];
//         const char* strStatus = (const char*) [NSStatus UTF8String];
//         
//         NSLog(@"[GoogleUserMessagingPlatform]: DispatchStatus %@", NSStatus);
//         
//         UnitySendMessage( "GoogleUserMessagingPlatform", "OnFormDissmissedMessage", strStatus );
//     }
//     
//     // -- EXPOSED TO UNITY -- //
//     
//     char* _GetPurposeConsent()
//     {
//         NSString* NSPurpose = [[GDPRHelper shared] getPurposeConsents];
//         char* strPurpose    = (char*) [NSPurpose UTF8String];
//         return strPurpose;
//     } 
//     char* _GetPurposeLI()
//     {
//         NSString* NSPurpose = [[GDPRHelper shared] getPurposeLI];
//         char* strPurpose    = (char*) [NSPurpose UTF8String];
//         return strPurpose;
//     } 
//     char* _GetVendorConsent()
//     {
//         NSString* NSPurpose = [[GDPRHelper shared] getVendorConsents];
//         char* strPurpose    = (char*) [NSPurpose UTF8String];
//         return strPurpose;
//     } 
//     char* _GetVendorLI()
//     {
//         NSString* NSPurpose = [[GDPRHelper shared] getVendorLI];
//         char* strPurpose    = (char*) [NSPurpose UTF8String];
//         return strPurpose;
//     } 
//     char* _GetAddtlConsent()
//     {
//         NSString* NSPurpose = [[GDPRHelper shared] getAddtlConsent];
//         char* strPurpose    = (char*) [NSPurpose UTF8String];
//         return strPurpose;
//     } 
//     
//     bool _GetCanShowAds()
//     {
//         if( DebugMode )
//         {
//             NSString* vc  = [[GDPRHelper shared] getVendorConsents];
//             NSString* pc  = [[GDPRHelper shared] getPurposeConsents];
//             NSString* ac  = [[GDPRHelper shared] getAddtlConsent];
//             NSString* log = [NSString stringWithFormat:@"GetCanShowAds %@ %@ %@", pc, vc, ac];
//             Log(log);
//         }
//     
//         return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] canShowAds];
//     }
//     
//     bool _GetCanShowPersonalizedAds()
//     {
//         if( DebugMode )
//         {
//             NSString* vc  = [[GDPRHelper shared] getVendorConsents];
//             NSString* pc  = [[GDPRHelper shared] getPurposeConsents];
//             NSString* ac  = [[GDPRHelper shared] getAddtlConsent];
//             NSString* log = [NSString stringWithFormat:@"GetCanShowPersonalizedAds %@ %@ %@", pc, vc, ac];
//             Log(log);
//         }
//     
//         return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] canShowPersonalizedAds];
//     }
//     
//     bool _GetConsentForVendor(int vendorID)
//     {
//         if( DebugMode )
//         {
//             NSString* vc  = [[GDPRHelper shared] getVendorConsents];
//             NSString* pc  = [[GDPRHelper shared] getPurposeConsents];
//             NSString* ac  = [[GDPRHelper shared] getAddtlConsent];
//             NSString* log = [NSString stringWithFormat:@"GetConsentForVendor %@ %@ %@", pc, vc, ac];
//             Log(log);
//         }
//     
//         return [[GDPRHelper shared] isVendorAutorizedWithVendorID:vendorID];
//     }
//     
//     bool _GetConsentForExternal(int externalID)
//     {
//         if( DebugMode )
//         {
//             NSString* vc  = [[GDPRHelper shared] getVendorConsents];
//             NSString* pc  = [[GDPRHelper shared] getPurposeConsents];
//             NSString* ac  = [[GDPRHelper shared] getAddtlConsent];
//             NSString* log = [NSString stringWithFormat:@"_GetConsentForExternal %@ %@ %@", pc, vc, ac];
//             Log(log);
//         }
//     
//         return [[GDPRHelper shared] isExternalAutorizedWithExternalID:externalID];
//     }
//     
//     bool _GetGDPRRequired()
//     {
//         if( DebugMode )
//         {
//             NSString* vc  = [[GDPRHelper shared] getVendorConsents];
//             NSString* pc  = [[GDPRHelper shared] getPurposeConsents];
//             NSString* ac  = [[GDPRHelper shared] getAddtlConsent];
//             NSString* log = [NSString stringWithFormat:@"GetGDPRRequired %@ %@ %@", pc, vc, ac];
//             Log(log);
//         }
//     
//         return [[GDPRHelper shared] isGDPR];
//     }
//     
//     bool _GetFirebase_ad_storage()
//     {
//         if( DebugMode )
//         {
//             NSString* pc  = [[GDPRHelper shared] getPurposeConsents];
//             NSString* log = [NSString stringWithFormat:@"_GetFirebase_ad_storage %@", pc];
//             Log(log);
//         }
//     
//         return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] getFirebase_ad_storage];
//     }
//     bool _GetFirebase_ad_personalization()
//     {
//         if( DebugMode )
//         {
//             NSString* pc  = [[GDPRHelper shared] getPurposeConsents];
//             NSString* log = [NSString stringWithFormat:@"_GetFirebase_ad_personalization %@", pc];
//             Log(log);
//         }
//     
//         return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] getFirebase_ad_personalization];
//     }
//     bool _GetFirebase_ad_user_data()
//     {
//         if( DebugMode )
//         {
//             NSString* pc  = [[GDPRHelper shared] getPurposeConsents];
//             NSString* log = [NSString stringWithFormat:@"_GetFirebase_ad_user_data %@", pc];
//             Log(log);
//         }
//     
//         return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] getFirebase_ad_user_data];
//     }
//     
//     
//     void _EnableDebugLogging( bool enabled )
//     {
//         IsLogEnabled = enabled;
//     }
//     
//     void _SetDebugMode( const char * device, bool forceReset )
//     {
//         DebugDevice = [NSString stringWithCString:device encoding:NSUTF8StringEncoding];
//         DebugMode   = DebugDevice != nil && [DebugDevice length] > 0;
//         ForceReset  = forceReset;
//     }
//     
//     void _SetTargetChildren( bool val )
//     {
//         TargetChildren = val;
//     }
//     
//     void _LoadForm( bool forceShow, bool forceDispatch )
//     {
//         if( !IsFormAvailable )
//         {
//             if( forceDispatch || forceShow )
//                 dispatchStatus( (int)UMPConsentInformation.sharedInstance.consentStatus );
//                 
//             LogError(@"LoadForm FORM NOT AVAILABLE");
//             return;
//         }
//         
//         [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *form, NSError *loadError)
//             {
//                 if( loadError )
//                 {
//                     if( forceShow || forceDispatch )
//                         dispatchStatus( (int)UMPConsentInformation.sharedInstance.consentStatus );
//                         
//                     // Handle the error
//                     LogError( [NSString stringWithFormat:@"%@ / %@", @"onConsentFormLoadFailure ERROR ", loadError.description] );
//                 }
//                 else
//                 {
//                     Log( [NSString stringWithFormat:@"%@ / %ld", @"onConsentFormLoadSuccess ", (long)UMPConsentInformation.sharedInstance.consentStatus] );
//                 
//                     if( forceDispatch )
//                         dispatchStatus( (int)UMPConsentInformation.sharedInstance.consentStatus );
//                         
//                     // Present the form
//                     if( forceShow )
//                     {
//                         [form presentFromViewController:UnityGetGLViewController()
//                               completionHandler:^(NSError *_Nullable dismissError)
//                               {
//                                   Log(@"onConsentFormDismissed");
//                                   dispatchStatus( (int)UMPConsentInformation.sharedInstance.consentStatus );
//                               }];
//                     }
//                 }
//             }];
//     }
//     
//     bool _IsFormAvailable()
//     {
//         return IsFormAvailable;
//     }
// 
//     bool _GetCanRequestAds()
//     {
//         if( IsInit )
//             return UMPConsentInformation.sharedInstance.canRequestAds;
//         return false;
//     }
// 
//     void _Initialize() 
//     {        
//         if( IsInit )
//             return;
//         IsInit = true;
//     
//         Log(@"Initialize");
//     
//         /*bool deleted = [[GDPRHelper shared] deleteOutdatedTCString];
//         if( deleted )
//             Log(@"deleted outdated TCF String");*/
//     
//         // Create a UMPRequestParameters object.
//         UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];
//         // Set tag for under age of consent. Here NO means users are not under age.
//         parameters.tagForUnderAgeOfConsent = TargetChildren;
//         
//         if( DebugMode )
//         {
//             LogError(@"MODE DEBUG");
//             
//             UMPDebugSettings *debugSettings     = [[UMPDebugSettings alloc] init];
//             debugSettings.testDeviceIdentifiers = @[ DebugDevice ];
//             debugSettings.geography             = UMPDebugGeographyEEA;
//             parameters.debugSettings            = debugSettings;
//             
//             if( ForceReset )
//             {
//                 LogError(@"RESETING DATAS");
//                 [UMPConsentInformation.sharedInstance reset];
//             }
//         }
//         
//         // Request an update to the consent information.
//         [UMPConsentInformation.sharedInstance 
//             requestConsentInfoUpdateWithParameters:parameters
//             completionHandler:^(NSError *_Nullable error) 
//             {
//                 if( error ) 
//                 {
//                     // Handle the error.
//                     LogError( [NSString stringWithFormat:@"%@ / %@", @"onConsentInfoUpdateFailure ERROR ", error.description] );
//                 } 
//                 else 
//                 {
//                     // The consent information state was updated.
//                     // You are now ready to check if a form is
//                     // available.
//                     if( UMPConsentInformation.sharedInstance.formStatus == UMPFormStatusAvailable ) 
//                     {
//                         Log(@"onConsentInfoUpdateSuccess FROM AVAILABLE");
//                         IsFormAvailable = true;
//                     }
//                     else
//                     {
//                         Log(@"onConsentInfoUpdateSuccess FROM NOT AVAILABLE");
//                     }
//                 }
//                 _LoadForm( false, true );
//             }];
//     }
// }


//
// GoogleUserMessagingPlatform.m
//
// Created by Benjamin BOUFFIER.
// On 9/11/2022
//

#include "GoogleUserMessagingPlatform.h"
#include <UserMessagingPlatform/UserMessagingPlatform.h>
#import <UnityAppController.h>
#import "UnityInterface.h"

#import "UnityFramework/UnityFramework-Swift.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - "C"

static bool IsInit = false;
static bool IsFormAvailable = false;
static bool IsLogEnabled = false;

static bool DebugMode = false;
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
    NSString* NSStatus = [NSString stringWithFormat:@"%d",status];
    const char* strStatus = (const char*) [NSStatus UTF8String];

    NSLog(@"[GoogleUserMessagingPlatform]: DispatchStatus %@", NSStatus);

    UnitySendMessage( "GoogleUserMessagingPlatform", "OnFormDissmissedMessage", strStatus );
}

// -- EXPOSED TO UNITY -- //

char* _GetPurposeConsent()
{
    NSString* NSPurpose = [[GDPRHelper shared] getPurposeConsents];
    char* strPurpose = (char*) [NSPurpose UTF8String];
    return strPurpose;
}
char* _GetPurposeLI()
{
    NSString* NSPurpose = [[GDPRHelper shared] getPurposeLI];
    char* strPurpose = (char*) [NSPurpose UTF8String];
    return strPurpose;
}
char* _GetVendorConsent()
{
    NSString* NSPurpose = [[GDPRHelper shared] getVendorConsents];
    char* strPurpose = (char*) [NSPurpose UTF8String];
    return strPurpose;
}
char* _GetVendorLI()
{
    NSString* NSPurpose = [[GDPRHelper shared] getVendorLI];
    char* strPurpose = (char*) [NSPurpose UTF8String];
    return strPurpose;
}
char* _GetAddtlConsent()
{
    NSString* NSPurpose = [[GDPRHelper shared] getAddtlConsent];
    char* strPurpose = (char*) [NSPurpose UTF8String];
    return strPurpose;
}

bool _GetCanShowAds()
{
    if( DebugMode )
    {
        NSString* vc = [[GDPRHelper shared] getVendorConsents];
        NSString* pc = [[GDPRHelper shared] getPurposeConsents];
        NSString* ac = [[GDPRHelper shared] getAddtlConsent];
        NSString* log = [NSString stringWithFormat:@"GetCanShowAds %@ %@ %@", pc, vc, ac];
        Log(log);
    }

    return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] canShowAds];
}

bool _GetCanShowPersonalizedAds()
{
    if( DebugMode )
    {
        NSString* vc = [[GDPRHelper shared] getVendorConsents];
        NSString* pc = [[GDPRHelper shared] getPurposeConsents];
        NSString* ac = [[GDPRHelper shared] getAddtlConsent];
        NSString* log = [NSString stringWithFormat:@"GetCanShowPersonalizedAds %@ %@ %@", pc, vc, ac];
        Log(log);
    }

    return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] canShowPersonalizedAds];
}

bool _GetConsentForVendor(int vendorID)
{
    if( DebugMode )
    {
        NSString* vc = [[GDPRHelper shared] getVendorConsents];
        NSString* pc = [[GDPRHelper shared] getPurposeConsents];
        NSString* ac = [[GDPRHelper shared] getAddtlConsent];
        NSString* log = [NSString stringWithFormat:@"GetConsentForVendor %@ %@ %@", pc, vc, ac];
        Log(log);
    }

    // Corrected call to the Swift method
    return [[GDPRHelper shared] isVendorAutorizedWithVendorID:vendorID];
}

bool _GetConsentForExternal(int externalID)
{
    if( DebugMode )
    {
        NSString* vc = [[GDPRHelper shared] getVendorConsents];
        NSString* pc = [[GDPRHelper shared] getPurposeConsents];
        NSString* ac = [[GDPRHelper shared] getAddtlConsent];
        NSString* log = [NSString stringWithFormat:@"_GetConsentForExternal %@ %@ %@", pc, vc, ac];
        Log(log);
    }

    // Corrected call to the Swift method
    return [[GDPRHelper shared] isExternalAutorizedWithExternalID:externalID];
}

bool _GetGDPRRequired()
{
    if( DebugMode )
    {
        NSString* vc = [[GDPRHelper shared] getVendorConsents];
        NSString* pc = [[GDPRHelper shared] getPurposeConsents];
        NSString* ac = [[GDPRHelper shared] getAddtlConsent];
        NSString* log = [NSString stringWithFormat:@"GetGDPRRequired %@ %@ %@", pc, vc, ac];
        Log(log);
    }

    return [[GDPRHelper shared] isGDPR];
}

bool _GetFirebase_ad_storage()
{
    if( DebugMode )
    {
        NSString* pc = [[GDPRHelper shared] getPurposeConsents];
        NSString* log = [NSString stringWithFormat:@"_GetFirebase_ad_storage %@", pc];
        Log(log);
    }

    return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] getFirebase_ad_storage];
}
bool _GetFirebase_ad_personalization()
{
    if( DebugMode )
    {
        NSString* pc = [[GDPRHelper shared] getPurposeConsents];
        NSString* log = [NSString stringWithFormat:@"_GetFirebase_ad_personalization %@", pc];
        Log(log);
    }

    return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] getFirebase_ad_personalization];
}
bool _GetFirebase_ad_user_data()
{
    if( DebugMode )
    {
        NSString* pc = [[GDPRHelper shared] getPurposeConsents];
        NSString* log = [NSString stringWithFormat:@"_GetFirebase_ad_user_data %@", pc];
        Log(log);
    }

    return ![[GDPRHelper shared] isGDPR] || [[GDPRHelper shared] getFirebase_ad_user_data];
}


void _EnableDebugLogging( bool enabled )
{
    IsLogEnabled = enabled;
}

void _SetDebugMode( const char * device, bool forceReset )
{
    DebugDevice = [NSString stringWithCString:device encoding:NSUTF8StringEncoding];
    DebugMode = DebugDevice != nil && [DebugDevice length] > 0;
    ForceReset = forceReset;
}

void _SetTargetChildren( bool val )
{
    TargetChildren = val;
}

void _LoadForm( bool forceShow, bool forceDispatch )
{
    if( !IsFormAvailable )
    {
        if( forceDispatch || forceShow )
            dispatchStatus( (int)UMPConsentInformation.sharedInstance.consentStatus );

        LogError(@"LoadForm FORM NOT AVAILABLE");
        return;
    }

    [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *form, NSError *loadError)
        {
            if( loadError )
            {
                if( forceShow || forceDispatch )
                    dispatchStatus( (int)UMPConsentInformation.sharedInstance.consentStatus );

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

bool _GetCanRequestAds()
{
    if( IsInit )
        return UMPConsentInformation.sharedInstance.canRequestAds;
    return false;
}

void _Initialize()
{
    if( IsInit )
        return;
    IsInit = true;

    Log(@"Initialize");

    /*bool deleted = [[GDPRHelper shared] deleteOutdatedTCString];
    if( deleted )
        Log(@"deleted outdated TCF String");*/

    // Create a UMPRequestParameters object.
    UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];
    // Set tag for under age of consent. Here NO means users are not under age.
    parameters.tagForUnderAgeOfConsent = TargetChildren;

    if( DebugMode )
    {
        LogError(@"MODE DEBUG");

        UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
        debugSettings.testDeviceIdentifiers = @[ DebugDevice ];
        debugSettings.geography = UMPDebugGeographyEEA;
        parameters.debugSettings = debugSettings;

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
            }
            _LoadForm( false, true );
        }];
}
