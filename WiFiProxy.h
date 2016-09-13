#import <Foundation/Foundation.h>

@interface WiFiProxy : NSObject

+ (instancetype)sharedInstance;

- (void)setProxy:(NSString *)ipaddr port:(NSUInteger)port;

@end