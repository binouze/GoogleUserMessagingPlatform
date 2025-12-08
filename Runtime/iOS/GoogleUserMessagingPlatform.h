//
//  GoogleUserMessagingPlatform.h
//
//  Created by Benjamin BOUFFIER.
//  On 9/11/2022
//

//#include <UserMessagingPlatform/UserMessagingPlatform.h>
//
//@interface GoogleUserMessagingPlatform : NSObject
//
////////////////////////////////////////////
//
//#pragma mark - GoogleUserMessagingPlatform
//
//+ (void) Initialize;
//+ (void) LoadForm;
//+ (void) EnableDebugLogging;
//+ (void) SetDebugMode;
//
////////////////////////////////////////////
//
//
//@end



//
// GoogleUserMessagingPlatform.h
//
// Created by Benjamin BOUFFIER.
// On 9/11/2022
//

#ifndef GoogleUserMessagingPlatform_h
#define GoogleUserMessagingPlatform_h

#include <stdbool.h> // For bool type

#ifdef __cplusplus
extern "C" {
#endif

    // Exposed to Unity (C functions)
    char* _GetPurposeConsent();
    char* _GetPurposeLI();
    char* _GetVendorConsent();
    char* _GetVendorLI();
    char* _GetAddtlConsent();
    bool _GetCanShowAds();
    bool _GetCanShowPersonalizedAds();
    bool _GetConsentForVendor(int vendorID);
    bool _GetConsentForExternal(int externalID);
    bool _GetGDPRRequired();
    bool _GetFirebase_ad_storage();
    bool _GetFirebase_ad_personalization();
    bool _GetFirebase_ad_user_data();

    void _EnableDebugLogging(bool enabled);
    void _SetDebugMode(const char* device, bool forceReset, int debugGeography);
    void _SetTargetChildren(bool val);
    void _LoadForm(bool forceShow, bool forceDispatch);
    bool _IsFormAvailable();
    bool _GetCanRequestAds();
    void _Initialize();

#ifdef __cplusplus
}
#endif

#endif /* GoogleUserMessagingPlatform_h */
