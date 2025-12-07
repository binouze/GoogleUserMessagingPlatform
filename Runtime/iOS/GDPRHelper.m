//
//  GDPRDemo.m
//
//  Created by james on 12/4/25.
//

#import <Foundation/Foundation.h>
#import "GDPRHelper.h"

@implementation GDPRHelper

+ (instancetype)shared
{
    static GDPRHelper *sSharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[GDPRHelper alloc] init];
    });
    return sSharedInstance;
}

#pragma mark - Helpers

- (NSUserDefaults *)defaults
{
    return [NSUserDefaults standardUserDefaults];
}

- (NSString *)stringForKey:(NSString *)key
{
    NSString *value = [[self defaults] stringForKey:key];
    return value ?: @"";
}

#pragma mark - Basic getters

- (NSString *)getVendorConsents
{
    return [self stringForKey:@"IABTCF_VendorConsents"];
}

- (NSString *)getVendorLI
{
    return [self stringForKey:@"IABTCF_VendorLegitimateInterests"];
}

- (NSString *)getPurposeConsents
{
    return [self stringForKey:@"IABTCF_PurposeConsents"];
}

- (NSString *)getPurposeLI
{
    return [self stringForKey:@"IABTCF_PurposeLegitimateInterests"];
}

- (NSString *)getAddtlConsent
{
    return [self stringForKey:@"IABTCF_AddtlConsent"];
}

- (BOOL)isGDPR
{
    NSInteger gdpr = [[self defaults] integerForKey:@"IABTCF_gdprApplies"];
    return gdpr == 1;
}

#pragma mark - Consent helpers

// Check if a binary string has a "1" at position "index" (1-based)
- (BOOL)hasAttributeInString:(NSString *)input index:(NSInteger)index
{
    if (index <= 0) {
        return NO;
    }
    if ((NSUInteger)index > input.length) {
        return NO;
    }
    unichar c = [input characterAtIndex:(NSUInteger)index - 1];
    return c == '1';
}

// Check if consent is given for a list of purposes
- (BOOL)hasConsentForPurposes:(NSArray<NSNumber *> *)purposes
                purposeConsent:(NSString *)purposeConsent
{
    for (NSNumber *num in purposes) {
        NSInteger idx = [num integerValue];
        if (![self hasAttributeInString:purposeConsent index:idx]) {
            return NO;
        }
    }
    return YES;
}

// Check if a vendor either has consent or legitimate interest for a list of purposes
- (BOOL)hasConsentOrLegitimateInterestForPurposes:(NSArray<NSNumber *> *)purposes
                                    purposeConsent:(NSString *)purposeConsent
                                         purposeLI:(NSString *)purposeLI
{
    for (NSNumber *num in purposes) {
        NSInteger idx = [num integerValue];
        BOOL hasLI      = [self hasAttributeInString:purposeLI index:idx];
        BOOL hasConsent = [self hasAttributeInString:purposeConsent index:idx];
        if (!(hasLI || hasConsent)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Ad serving

- (BOOL)canShowAds
{
    NSUserDefaults *settings = [self defaults];

    // Minimum required for at least non-personalized ads
    NSString *purposeConsent = [settings stringForKey:@"IABTCF_PurposeConsents"] ?: @"";
    NSString *purposeLI      = [settings stringForKey:@"IABTCF_PurposeLegitimateInterests"] ?: @"";

    NSArray *p1      = @[@1];
    NSArray *pOthers = @[@2, @7, @9, @10];

    return [self hasConsentForPurposes:p1 purposeConsent:purposeConsent] &&
           [self hasConsentOrLegitimateInterestForPurposes:pOthers
                                             purposeConsent:purposeConsent
                                                  purposeLI:purposeLI];
}

- (BOOL)canShowPersonalizedAds
{
    NSUserDefaults *settings = [self defaults];

    NSString *purposeConsent = [settings stringForKey:@"IABTCF_PurposeConsents"] ?: @"";
    NSString *purposeLI      = [settings stringForKey:@"IABTCF_PurposeLegitimateInterests"] ?: @"";

    NSArray *pRequired = @[@1, @3, @4];
    NSArray *pOthers   = @[@2, @7, @9, @10];

    return [self hasConsentForPurposes:pRequired purposeConsent:purposeConsent] &&
           [self hasConsentOrLegitimateInterestForPurposes:pOthers
                                             purposeConsent:purposeConsent
                                                  purposeLI:purposeLI];
}

#pragma mark - Firebase Analytics specific

- (BOOL)getFirebase_ad_storage
{
    NSUserDefaults *settings = [self defaults];
    NSString *purposeConsent = [settings stringForKey:@"IABTCF_PurposeConsents"] ?: @"";
    NSString *purposeLI      = [settings stringForKey:@"IABTCF_PurposeLegitimateInterests"] ?: @"";

    BOOL consent = [self hasConsentForPurposes:@[@1] purposeConsent:purposeConsent];
    BOOL li      = [self hasConsentForPurposes:@[@1] purposeConsent:purposeLI];

    return consent || li;
}

- (BOOL)getFirebase_ad_personalization
{
    NSUserDefaults *settings = [self defaults];
    NSString *purposeConsent = [settings stringForKey:@"IABTCF_PurposeConsents"] ?: @"";
    NSString *purposeLI      = [settings stringForKey:@"IABTCF_PurposeLegitimateInterests"] ?: @"";

    BOOL consent3 = [self hasConsentForPurposes:@[@3] purposeConsent:purposeConsent];
    BOOL consent4 = [self hasConsentForPurposes:@[@4] purposeConsent:purposeConsent];

    BOOL li3      = [self hasConsentForPurposes:@[@3] purposeConsent:purposeLI];
    BOOL li4      = [self hasConsentForPurposes:@[@4] purposeConsent:purposeLI];

    return (consent3 || li3) && (consent4 || li4);
}

- (BOOL)getFirebase_ad_user_data
{
    NSUserDefaults *settings = [self defaults];
    NSString *purposeConsent = [settings stringForKey:@"IABTCF_PurposeConsents"] ?: @"";
    NSString *purposeLI      = [settings stringForKey:@"IABTCF_PurposeLegitimateInterests"] ?: @"";

    BOOL consent1 = [self hasConsentForPurposes:@[@1] purposeConsent:purposeConsent];
    BOOL consent7 = [self hasConsentForPurposes:@[@7] purposeConsent:purposeConsent];

    BOOL li1      = [self hasConsentForPurposes:@[@1] purposeConsent:purposeLI];
    BOOL li7      = [self hasConsentForPurposes:@[@7] purposeConsent:purposeLI];

    return (consent1 || li1) && (consent7 || li7);
}

#pragma mark - Vendor / external authorization

- (BOOL)isVendorAutorizedWithVendorID:(NSInteger)vendorID
{
    NSString *vendorConsent = [self stringForKey:@"IABTCF_VendorConsents"];
    return [self hasAttributeInString:vendorConsent index:vendorID];
}

- (BOOL)isExternalAutorizedWithExternalID:(NSInteger)externalID
{
    NSString *addtlConsent = [self stringForKey:@"IABTCF_AddtlConsent"];
    NSString *strId        = [NSString stringWithFormat:@"%ld", (long)externalID];
    return [addtlConsent containsString:strId];
}

#pragma mark - TCF string maintenance

- (BOOL)deleteOutdatedTCString
{
    NSUserDefaults *settings = [self defaults];

    // get IABTCF string containing creation timestamp;
    // fall back to string encoding timestamp 0 if nothing is currently stored
    NSString *tcString = [settings stringForKey:@"IABTCF_TCString"] ?: @"AAAAAAA";
    NSString *base64   = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    NSString *dateSubstring = @"";
    if (tcString.length >= 7) {
        NSRange range = NSMakeRange(1, 6); // from index 1, length 6
        dateSubstring = [tcString substringWithRange:range];
    }

    // interpret date substring as Base64-encoded integer value
    int64_t timestamp = 0;
    for (NSUInteger i = 0; i < dateSubstring.length; i++) {
        unichar c = [dateSubstring characterAtIndex:i];
        NSString *chStr = [NSString stringWithCharacters:&c length:1];
        NSRange r = [base64 rangeOfString:chStr];
        int64_t value = (r.location == NSNotFound) ? 0 : (int64_t)r.location;
        timestamp = timestamp * 64 + value;
    }

    // timestamp is given in deci-seconds, convert to milliseconds
    timestamp *= 100;

    // compare with current timestamp to get age in days
    int64_t nowMs   = (int64_t)([[NSDate date] timeIntervalSince1970] * 1000.0);
    int64_t daysAgo = (nowMs - timestamp) / (1000 * 60 * 60 * 24);

    NSLog(@"GDPRDemo:: deleteOutdatedTCString now = %lld - timestamp = %lld - daysAgo = %lld",
          nowMs, timestamp, daysAgo);

    // delete TC string if age is over a year
    if (daysAgo > 365) {
        [settings setObject:@"" forKey:@"IABTCF_TCString"];
        return YES;
    }

    return NO;
}

@end
