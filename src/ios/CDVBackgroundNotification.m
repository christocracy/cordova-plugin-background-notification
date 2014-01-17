////
//  CDVBackgroundGeoLocation
//
//  Created by Chris Scott <chris@transistorsoft.com> on 2013-06-15
//  Largely based upon http://www.mindsizzlers.com/2011/07/ios-background-location/
//
#import "CDVBackgroundNotification.h"
#import <Cordova/CDVJSON.h>
#import "AppDelegate.h"

@implementation AppDelegate(AppDelegate)

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult result))completionHandler
{
    void (^safeHandler)(UIBackgroundFetchResult) = ^(UIBackgroundFetchResult result){
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(result);
        });
    };
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:safeHandler forKey:@"handler"];
    [params setObject:userInfo forKey:@"userInfo"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundNotification" object:params];
}

@end

@implementation CDVBackgroundNotification
{
    void (^_completionHandler)(UIBackgroundFetchResult);
    NSString *_callbackId;
    NSNotification *_notification;
}

- (void)pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(onNotification:)
        name:@"BackgroundNotification"
        object:nil];
}

- (void) configure:(CDVInvokedUrlCommand*)command
{    
    NSLog(@"- CDVBackgroundNotification configure");
    UIApplication *app = [UIApplication sharedApplication];
    UIApplicationState state = [app applicationState];
    
    _callbackId = command.callbackId;
    
    // Handle case where app was launched due to notification event
    if (state == UIApplicationStateBackground && _completionHandler && _notification) {
        [self onNotification:_notification];
    }
}

-(void) onNotification:(NSNotification *) notification
{
    UIApplication *app = [UIApplication sharedApplication];
    // We only run in the background.  Foreground notifications should already be handled.
    UIApplicationState state = [app applicationState];
    if (state != UIApplicationStateBackground) {
        return;
    }
    
    NSLog(@"- CDVBackgroundNotification onNotification");
    _notification = notification;
    _completionHandler = [notification.object[@"handler"] copy];
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* result = nil;
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: notification.object[@"userInfo"]];
        [result setKeepCallbackAsBool:YES];
        
        // Inform javascript a background-fetch event has occurred.
        [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
    }];
    
}
-(void) finish:(CDVInvokedUrlCommand*)command
{
    NSLog(@"- CDVBackgroundNotification finish");
    [self stopBackgroundTask];
}

-(void)stopBackgroundTask
{
    UIApplication *app = [UIApplication sharedApplication];
    
    if (_completionHandler) {
        NSLog(@"- CDVBackgroundNotification stopBackgroundTask (remaining t: %f)", app.backgroundTimeRemaining);
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
