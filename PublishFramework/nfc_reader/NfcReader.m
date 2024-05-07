//
//  NfcReader.m
//

#import "NfcReader.h"
//#import "enums.h"
#import "nfc_config.h"
#import "nfc_reader-Swift.h"

@implementation NfcReader

- (id)init
{
    self = [super init];
    if (@available(iOS 13.0, *))
    {
        ovdWrapper = [[OvdWrapper alloc] init];
    }
    return self;
}

- (void)readNfcAuthResult:(NSString*)passportNumber
                  dateOfB:(NSString*)dateOfBirth
                  expiryD:(NSString*)expiryDate
                nfcConfig:(NfcConfig*)nfcConfig
                processId:(NSString*)processId
{
    NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (@available(iOS 13.0, *))
    {
        [ovdWrapper initOvdWrapperWithUrl:[nfcConfig getUrl]
                      saveAdditionalFiles:[nfcConfig getSaveAdditionalFiles]
                           saveAuthResult:[nfcConfig getSaveAuthResult]
                            saveNfcResult:[nfcConfig getSaveNfcResult]
                             showProgress:[nfcConfig getShowProgress]];

        [ovdWrapper getAuthResultWithPassportNumber:passportNumber
                                        dateOfBirth:dateOfBirth
                                       dateOfExpiry:expiryDate
                                           bundleId:bundleIdentifier
                                          processId:processId];
    }
}

- (OvdConnectorWrapper*)getOvdConnector API_AVAILABLE(ios(13.0))
{
    return [ovdWrapper ovdConnectorWrapper];
}

- (void)resetNfcData
{
    [ovdWrapper resetNfcData];
}

- (NSString*)getNfcStatus
{
    if (@available(iOS 13.0, *))
    {
        return [OvdWrapper nfcStatus];
    }
    return 0;
}

- (NSInteger)getNfcAuthCheckError
{
    if (@available(iOS 13.0, *))
    {
        return [OvdWrapper nfcAuthCheckError];
    }
    return 0;
}

- (NSData*)getSod
{
    return [ovdWrapper sodFileBinaryData];
}

- (NSData*)getDg1
{
    return [ovdWrapper dg1FileBinaryData];
}

- (NSData*)getDg2
{
    return [ovdWrapper dg2FileBinaryData];
}

- (NSData*)getDg3
{
    return [ovdWrapper dg3FileBinaryData];
}

- (NSData*)getDg4
{
    return [ovdWrapper dg4FileBinaryData];
}

- (NSData*)getDg5
{
    return [ovdWrapper dg5FileBinaryData];
}

- (NSData*)getDg6
{
    return [ovdWrapper dg6FileBinaryData];
}

- (NSData*)getDg7
{
    return [ovdWrapper dg7FileBinaryData];
}

- (NSData*)getDg8
{
    return [ovdWrapper dg8FileBinaryData];
}

- (NSData*)getDg9
{
    return [ovdWrapper dg9FileBinaryData];
}

- (NSData*)getDg10
{
    return [ovdWrapper dg10FileBinaryData];
}

- (NSData*)getDg11
{
    return [ovdWrapper dg11FileBinaryData];
}

- (NSData*)getDg12
{
    return [ovdWrapper dg12FileBinaryData];
}

- (NSData*)getDg13
{
    return [ovdWrapper dg13FileBinaryData];
}

- (NSData*)getDg14
{
    return [ovdWrapper dg14FileBinaryData];
}

- (NSData*)getDg15
{
    return [ovdWrapper dg15FileBinaryData];
}

- (NSData*)getDg16
{
    return [ovdWrapper dg16FileBinaryData];
}

- (UIImage*)getImageData
{
    return [ovdWrapper faceUIImage];
}

- (NSString*)getActiveAuthenticationResult
{
    return [ovdWrapper activeAuthenticationResult];
}

- (NSString*)getChipAuthenticationResult
{
    return [ovdWrapper chipAuthenticationResult];
}

- (NSString*)getUrl
{
    return [ovdWrapper url];
}

- (NSDictionary*)getNfcJson
{
    return [ovdWrapper nfcJson];
}

- (NSDictionary*)getSodInfo
{
    return [ovdWrapper sodInfo];
}

- (NSDictionary*)getHashForDataGroup
{
    return [ovdWrapper hashForDataGroup];
}

- (NSDictionary*)getMrzInfo
{
    return [ovdWrapper mrzInfo];
}

- (NSDictionary*)getAdditionalPersonalDetails
{
    return [ovdWrapper additionalPersonalDetails];
}

- (NSDictionary*)getAdditionalDocumentDetails
{
    return [ovdWrapper additionalDocumentDetails];
}

- (NSDictionary*)getPassiveAuthenticationDetails
{
    return [ovdWrapper passiveAuthenticationDetails];
}

- (Boolean)saveAdditionalFiles
{
    return [ovdWrapper saveAdditionalFiles];
}

- (Boolean)saveAuthResult
{
    return [ovdWrapper saveAuthResult];
}

- (Boolean)saveNfcResult
{
    return [ovdWrapper saveNfcResult];
}

+ (NSString*)convertToString:(int)errorCode
{
    NSString* result = @"EError_NFC_UnexpectedException";
//    switch (errorCode)
//    {
//    case EError_NFC_MutualAuthenticationFailedNotSatisfied:
//        result = @"EError_NFC_MutualAuthenticationFailedNotSatisfied";
//        break;
//    case EError_NFC_ReadFailed:
//        result = @"EError_NFC_ReadFailed";
//        break;
//    case EError_NFC_UnexpectedException:
//        result = @"EError_NFC_UnexpectedException";
//        break;
//    case EError_NFC_Timeout:
//        result = @"EError_NFC_Timeout";
//        break;
//    case EError_NFC_CLONED_CHIP:
//        result = @"EError_NFC_CLONED_CHIP";
//        break;
//    case EError_NFC_TechnicalError:
//        result = @"EError_NFC_TechnicalError";
//        break;
//    case EError_NFC_SessionInvalidated:
//        result = @"EError_NFC_SessionInvalidated";
//        break;
//    case EError_NFC_MoreThanOneTagFound:
//        result = @"EError_NFC_MoreThanOneTagFound";
//        break;
//    case EError_NFC_WrongTag:
//        result = @"EError_NFC_WrongTag";
//        break;
//    case EError_NFC_TagWasLost:
//        result = @"EError_NFC_TagWasLost";
//        break;
//    case EError_NFC_NotConnected:
//        result = @"EError_NFC_NotConnected";
//        break;
//    case EError_NFC_NotSupported:
//        result = @"EError_NFC_NotSupported";
//    default:
//        result = @"EError_NFC_UnexpectedException";
//    }
    return result;
}

+ (NSString*)convertDate:(NSString*)date
{
    NSArray* arr = [date componentsSeparatedByString:@"-"];
    if ([arr count] != 3)
    {
        return @"";
    }
    NSString* year = [arr[0] substringFromIndex:[arr[0] length] - 2];
    NSString* newDate = [NSString stringWithFormat:@"%@%@%@", year, arr[1], arr[2]];
    return newDate;
}

@end
