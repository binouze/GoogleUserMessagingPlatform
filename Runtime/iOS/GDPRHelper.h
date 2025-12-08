//
//  GDPRDemo.h
//
//  Created by james on 12/4/25.
//

#ifndef GDPRDemo_h
#define GDPRDemo_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDPRHelper : NSObject

+ (instancetype)shared;

- (NSString *)getVendorConsents;
- (NSString *)getVendorLI;
- (NSString *)getPurposeConsents;
- (NSString *)getPurposeLI;
- (NSString *)getAddtlConsent;

- (BOOL)isGDPR;

// Internal helpers
- (BOOL)hasAttributeInString:(NSString *)input index:(NSInteger)index;
- (BOOL)hasConsentForPurposes:(NSArray<NSNumber *> *)purposes
                purposeConsent:(NSString *)purposeConsent;
- (BOOL)hasConsentOrLegitimateInterestForPurposes:(NSArray<NSNumber *> *)purposes
                                    purposeConsent:(NSString *)purposeConsent
                                         purposeLI:(NSString *)purposeLI;

// Ad serving
- (BOOL)canShowAds;
- (BOOL)canShowPersonalizedAds;

// Firebase Analytics
- (BOOL)getFirebase_ad_storage;
- (BOOL)getFirebase_ad_personalization;
- (BOOL)getFirebase_ad_user_data;

// Vendor / external authorization
- (BOOL)isVendorAutorizedWithVendorID:(NSInteger)vendorID;
- (BOOL)isExternalAutorizedWithExternalID:(NSInteger)externalID;

// TCF string maintenance
- (BOOL)deleteOutdatedTCString;

@end

NS_ASSUME_NONNULL_END

#endif /* GDPRDemo_h */
