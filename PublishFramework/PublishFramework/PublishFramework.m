//
//  PublishFramework.m
//  PublishFramework
//
//  Created by Gayane Nerkararyan on 5/2/24.
//

#import "PublishFramework.h"

@implementation Logger : NSObject

- (void)printText:(NSString *) text {
    NSLog(@"LOGGER: %@", text);
    _text = text;
}

- (NSString *) getText {
    return _text;
}

@end
