#import <Foundation/Foundation.h>
#import "WiFiProxy.h"

int main(int argc, char **argv, char **envp) {
	WiFiProxy *proxy = [WiFiProxy sharedInstance]; 
	[proxy setProxy:@"192.168.1.101" port:8888];
	return 0;
}