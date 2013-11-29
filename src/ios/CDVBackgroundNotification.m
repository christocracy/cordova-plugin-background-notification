////
//  CDVBackgroundGeoLocation
//
//  Created by Chris Scott <chris@transistorsoft.com> on 2013-06-15
//  Largely based upon http://www.mindsizzlers.com/2011/07/ios-background-location/
//
#import "CDVBackgroundNotification.h"
#import <Cordova/CDVJSON.h>

@implementation CDVBackgroundNotification
{
    void (^_completionHandler)(UIBackgroundFetchResult);
    NSString *_callbackId;
}

- (CDVPlugin*) initWithWebView:(UIWebView*) theWebView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(onNotification:)
        name:@"BackgroundNotification"
        object:nil];
    
    return self;
}

- (void) configure:(CDVInvokedUrlCommand*)command
{    
    NSLog(@"CDVBackgroundNotification configure");    
    _callbackId = command.callbackId;
}

-(void) onNotification:(NSNotification *) notification
{
    // We only run in the background.  Foreground notifications should already be handled.
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state != UIApplicationStateBackground) {
        return;
    }
    NSLog(@"- CDVBackgroundNotification onNotification");
    _completionHandler = notification.object[@"handler"];
    
    CDVPluginResult* result = nil;
    
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: notification.object[@"userInfo"]];
    [result setKeepCallbackAsBool:YES];
    
    // Inform javascript a background-fetch event has occurred.
    [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
}
-(void) finish:(CDVInvokedUrlCommand*)command
{
    NSLog(@"- CDVBackgroundNotification finish");
    if (_completionHandler) {
        _completionHandler(UIBackgroundFetchResultNewData);
        _completionHandler = nil;
    }
}

// If you don't stopMonitorying when application terminates, the app will be awoken still when a
// new location arrives, essentially monitoring the user's location even when they've killed the app.
// Might be desirable in certain apps.
- (void)applicationWillTerminate:(UIApplication *)application 
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
