
#import <Foundation/Foundation.h>

#import "WiFiProxy.h"
#import "SCNetworkHeader.h"

#define DDLog(s,...) NSLog(@"******TESTPROXY****** %s:%d %@",__func__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__]);


@implementation WiFiProxy

+ (instancetype)sharedInstance {
	static id _instance;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		_instance = [[WiFiProxy alloc]init];
	});
	return _instance;
}

- (void)setProxy:(NSString *)ipaddr port:(NSUInteger)port {

		SCPreferencesRef prefRef = SCPreferencesCreate(NULL, CFSTR("test_proxy"), NULL);

		SCPreferencesLock(prefRef, true);

	    CFStringRef currentSetPath = SCPreferencesGetValue(prefRef, kSCPrefCurrentSet);
		DDLog(@"current set key path = %@", cfs2nss(currentSetPath));

		//Get current active network configuration
	    NSDictionary *currentSet = (__bridge NSDictionary *)SCPreferencesPathGetValue(prefRef, currentSetPath);
	   	if (currentSet) {

	   		NSDictionary *currentSetServices = currentSet[cfs2nss(kSCCompNetwork)][cfs2nss(kSCCompService)];
	   		DDLog(@"current set services: %@", currentSetServices);

		    NSDictionary *services = (__bridge NSDictionary *)SCPreferencesGetValue(prefRef, kSCPrefNetworkServices);
		    DDLog(@"services = %@", services);

		    NSString *wifiServiceKey = nil;
		    for (NSString *key in currentSetServices) {
		   		NSDictionary *service = services[key];
		   		NSString *name = service[cfs2nss(kSCPropUserDefinedName)];
		   		DDLog(@"network service name: %@", name);
		   		if (service && [@"Wi-Fi" isEqualToString: name]) {
		   			wifiServiceKey = key;
		   			break;
		   		}
		    }

		    if (wifiServiceKey) {
		    	DDLog(@"Find target servcie: %@", wifiServiceKey);
			 	NSData *data = 
				[NSPropertyListSerialization dataWithPropertyList:services
		                                             format:NSPropertyListBinaryFormat_v1_0
		                                             options:0
		                                        	   error:nil];
		 		NSMutableDictionary *nservices =
		 		[NSPropertyListSerialization propertyListWithData:data
		                                  		   options:NSPropertyListMutableContainersAndLeaves
		                                            format:NULL
		                                  			 error:nil];
			    NSMutableDictionary *proxies = nservices[wifiServiceKey][(__bridge NSString *)kSCEntNetProxies];
			    [proxies setObject:@(1) forKey:cfs2nss(kSCPropNetProxiesHTTPEnable)];
			   	[proxies setObject:ipaddr forKey:cfs2nss(kSCPropNetProxiesHTTPProxy)];
			   	[proxies setObject:@(port) forKey:cfs2nss(kSCPropNetProxiesHTTPPort)];
			   	[proxies setObject:@(1) forKey:cfs2nss(kSCPropNetProxiesHTTPSEnable)];
			   	[proxies setObject:ipaddr forKey:cfs2nss(kSCPropNetProxiesHTTPSProxy)];
			   	[proxies setObject:@(port) forKey:cfs2nss(kSCPropNetProxiesHTTPSPort)];
			    SCPreferencesSetValue(prefRef, kSCPrefNetworkServices, (__bridge CFPropertyListRef)nservices);
			    SCPreferencesCommitChanges(prefRef);
			    SCPreferencesApplyChanges(prefRef);
		    } else {
		    	DDLog(@"Does not find target service");
		    }
	   	} else {
	   		DDLog(@"Does not find set for set key:%@", currentSetPath);
	   	}
		SCPreferencesUnlock(prefRef);
		CFRelease(prefRef);
}

@end