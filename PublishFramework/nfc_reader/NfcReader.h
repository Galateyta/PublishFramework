//
//  NfcReader.h
//

#import <Foundation/Foundation.h>
@class OvdWrapper;
@class OvdConnectorWrapper;
@class UIImage;
@class NfcConfig;

@interface NfcReader : NSObject
{
    OvdWrapper* ovdWrapper;
}

- (id)init;

- (void)readNfcAuthResult:(NSString*)passportNumber
                  dateOfB:(NSString*)dateOfBirth
                  expiryD:(NSString*)expiryDate
                nfcConfig:(NfcConfig*)nfcConfig
                processId:(NSString*)processId;

- (OvdConnectorWrapper*)getOvdConnector API_AVAILABLE(ios(13.0));

- (void)resetNfcData;

- (NSString*)getNfcStatus;

- (NSInteger)getNfcAuthCheckError;

- (NSString*)getIdb;

- (NSDictionary*)getNfcJson;

- (NSData*)getSod;

- (NSData*)getDg1;

- (NSData*)getDg2;

- (NSData*)getDg3;

- (NSData*)getDg4;

- (NSData*)getDg5;

- (NSData*)getDg6;

- (NSData*)getDg7;

- (NSData*)getDg8;

- (NSData*)getDg9;

- (NSData*)getDg10;

- (NSData*)getDg11;

- (NSData*)getDg12;

- (NSData*)getDg13;

- (NSData*)getDg14;

- (NSData*)getDg15;

- (NSData*)getDg16;

- (UIImage*)getImageData;

- (NSString*)getActiveAuthenticationResult;

- (NSString*)getChipAuthenticationResult;

- (NSString*)getUrl;

- (NSDictionary*)getSodInfo;

- (NSDictionary*)getHashForDataGroup;

- (NSDictionary*)getMrzInfo;

- (NSDictionary*)getAdditionalPersonalDetails;

- (NSDictionary*)getAdditionalDocumentDetails;

- (NSDictionary*)getPassiveAuthenticationDetails;

- (Boolean)saveAdditionalFiles;

- (Boolean)saveAuthResult;

- (Boolean)saveNfcResult;

+ (NSString*)convertToString:(int)errorCode;

+ (NSString*)convertDate:(NSString*)date;

@end
