//
//  GoogleUserMessagingPlatform.h
//
//  Created by Benjamin BOUFFIER.
//  On 9/11/2022
//

#include <UserMessagingPlatform/UserMessagingPlatform.h>

@interface GoogleUserMessagingPlatform : NSObject

//////////////////////////////////////////

#pragma mark - GoogleUserMessagingPlatform

+ (void) Initialize;
+ (void) LoadForm;
+ (void) EnableDebugLogging;
+ (void) SetDebugMode;

//////////////////////////////////////////


@end