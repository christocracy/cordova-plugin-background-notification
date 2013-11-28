//
//  CDVBackgroundGeoLocation.hs
//
//  Created by Chris Scott <chris@transistorsoft.com>
//

#import <Cordova/CDVPlugin.h>
#import "AppDelegate.h"

@interface CDVBackgroundNotification : CDVPlugin <UIApplicationDelegate>
- (void) configure:(CDVInvokedUrlCommand*)command;
- (void) finish:(CDVInvokedUrlCommand*)command;

@end

