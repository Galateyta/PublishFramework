//
//  PublishFramework.h
//  PublishFramework
//
//  Created by Gayane Nerkararyan on 5/2/24.
//

#import <Foundation/Foundation.h>

//! Project version number for PublishFramework.
FOUNDATION_EXPORT double PublishFrameworkVersionNumber;

//! Project version string for PublishFramework.
FOUNDATION_EXPORT const unsigned char PublishFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PublishFramework/PublicHeader.h>

@interface Logger : NSObject

@property NSString * text;

- (void)printText:(NSString *) text;

- (NSString *)getText;

@end
