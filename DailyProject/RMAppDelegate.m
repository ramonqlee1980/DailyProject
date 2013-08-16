//
//  RMAppDelegate.m
//  DailyProject
//
//  Created by Ramonqlee on 8/11/13.
//  Copyright (c) 2013 iDreems. All rights reserved.
//

#import "RMAppDelegate.h"
#import "RMFavoriteViewController.h"
#import "ArticlesMultiPageViewController.h"
#import "RMHistoryViewController.h"
#import "CommonHelper.h"
#import "SettingsViewController.h"
#import "resConstants.h"
#import "UMSocial.h"
#import "Flurry.h"
#import "iRate.h"
#import "iVersion.h"
#import "MobisageRecommendTableViewController.h"
#import "AdsConfig.h"
#import "AdsConfiguration.h"
#import "HTTPHelper.h"

#ifdef DPRAPR_PUSH
#import "DMAPService.h"
#import "DMAPTools.h"
#endif//DPRAPR_PUSH

@interface RMAppDelegate()
{
    BOOL      _EnterBylocalNotification;
}
@end

@implementation RMAppDelegate
+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 5;
    
//    [iVersion sharedInstance].appStoreID = 355313284;
//    [iVersion sharedInstance].remoteVersionsPlistURL = @"http://example.com/versions.plist";
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initLaunch];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    CGRect rc = [[UIScreen mainScreen]applicationFrame];
    
    rc.size.height -= (kTopTabHeight+kTabbarHeight);
    UIViewController* dailyArticlesController = [[[ArticlesMultiPageViewController alloc]initWithFrame:rc]autorelease];
    
    UIViewController *favoriteViewController = [[[RMFavoriteViewController alloc] initWithFrame:rc] autorelease];
    UIViewController * historyViewController = [[[RMHistoryViewController alloc] initWithFrame:rc] autorelease];
    UIViewController* recommendController = [[[MobisageRecommendTableViewController alloc] init] autorelease];
    
    UIViewController* tmp = [[[SettingsViewController alloc]init]autorelease];
    UINavigationController* setting = [[[UINavigationController alloc]initWithRootViewController:tmp]autorelease];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = @[dailyArticlesController,/*historyViewController,*/ favoriteViewController,recommendController,setting];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    [self startAdsConfigReceive];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notifyClick_Ad:) name:MobiSageAdView_Click_AD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMobisageRecommendSingleTap:) name:kClickRecommendViewEvent object:nil];
    
#ifdef DPRAPR_PUSH
    // 开启开发者测试模式
#ifdef __PUSH_ON__TEST_MODE__
    [DMAPTools developerTestMode];
#endif//__PUSH_ON__TEST_MODE__
    
    // Required
    [DMAPService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    // Required
    [DMAPService setupWithOption:launchOptions];
#endif
    return YES;
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //   token deviceId  publicKey
#ifdef DPRAPR_PUSH
    [DMAPService registerDeviceToken:deviceToken];
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error:%@", [error description]);
    
}

-(void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    // Required
#ifdef DPRAPR_PUSH
    [DMAPService handleRemoteNotification:userInfo];
#endif
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    _EnterBylocalNotification = NO;
    NSLog(@"applicationDidEnterBackground");
    
    if ([self scheduleNotificationWhenQuit]) {
        
        const NSTimeInterval kDelay = 0;//1;
        NSString* popContent = NSLocalizedString(appFriendlyTip,"");
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self scheduleLocalNotification:popContent delayTimeInterval:kDelay];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/
#pragma  mark init launch methods
-(void)initLaunch
{
    [UMSocialData setAppKey:UMENG_APPKEY];
    //init launch task
    if([CommonHelper initLaunch])
    {
        [CommonHelper setGold:kDefaultGold];
        [CommonHelper setNotInitLaunch];
        
        //enable quit notification
        [self setQuitNotification:YES];
    }
}

#pragma mark  quit switch
#define kQuitNotificationKey @"kQuitNotificationKey"
-(BOOL)scheduleNotificationWhenQuit
{
    NSUserDefaults* defaultSetting = [NSUserDefaults standardUserDefaults];
    return [defaultSetting boolForKey:kQuitNotificationKey];
}
-(void)setQuitNotification:(BOOL)enable
{
    NSUserDefaults* defaultSetting = [NSUserDefaults standardUserDefaults];
    [defaultSetting setBool:enable forKey:kQuitNotificationKey];
    [defaultSetting synchronize];
}

#pragma mark schedule notification

-(void)scheduleLocalNotification:(NSString*)alertBody
{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        NSDate *now=[NSDate date];
#define kOneDayInSeconds 24*60*60
        notification.fireDate=[now dateByAddingTimeInterval:kOneDayInSeconds];
        NSLog(@"alertDate::%@",now);
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber+1;
        notification.alertBody=alertBody;
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
    [notification release];
}
-(void)scheduleLocalNotification:(NSString*)alertBody delayTimeInterval:(NSTimeInterval)delay
{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        NSDate *now=[NSDate date];
        notification.fireDate=[now dateByAddingTimeInterval:delay];
        NSLog(@"alertDate::%@",now);
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber;
        notification.alertBody=alertBody;
        notification.hasAction = NO;
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
    [notification release];
}

#pragma mark ad click event handler
/**
 banner ad clicked,increment gold
 */
-(void)notifyClick_Ad:(NSNotification*)notification
{
    [CommonHelper setGold:[CommonHelper gold]+kGoldByClickingBanner];
    NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kGoldByClickingBanner] forKey:kClickBannerEvent];
    [Flurry logEvent:kGoldEvent withParameters:dict];
    
    
    NSLog(@"notify:%@,gold:%d",notification.name,[CommonHelper gold]);
}
-(void)handleMobisageRecommendSingleTap:(NSNotification*)notification
{
    if (notification && [notification.name isEqualToString:kClickRecommendViewEvent]) {
        [CommonHelper setGold:[CommonHelper gold]+kGoldByClickingRecommendView];
        
        NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kGoldByClickingRecommendView] forKey:kClickRecommendViewEvent];
        [Flurry logEvent:kGoldEvent withParameters:dict];
    }
}
#pragma mark ads utils

-(void)getResult:(NSNotification*)notification
{
    if (notification && ![notification.object isKindOfClass:[NSError class]]) {
        //parse ads and send notification
        AdsConfiguration* adsConfig = [AdsConfiguration sharedInstance];
        [adsConfig initWithJson:[notification.userInfo objectForKey:kPostResponseData]];
        
        //flurry
        [Flurry startSession:[[AdsConfiguration sharedInstance]FlurryId]];
        //向微信注册
        [WXApi registerApp:[[AdsConfiguration sharedInstance]wechatId]];
//        [self checkUpdate];
//        [iVersion sharedInstance].appStoreID = [[AdsConfiguration sharedInstance]appleId];
        
        //notify
        [[NSNotificationCenter defaultCenter]postNotificationName:kAdsConfigUpdated object:nil];
    }
    
}
- (void)startAdsConfigReceive
// Starts a connection to download the current URL.
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getResult:) name:kPostNotification object:nil];
    //new method to get ads
    [self beginPostRequest:kAdsJsonUrl withDictionary:[CommonHelper getAdPostReqParams]];

}
#pragma mark HTTP util methods
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown setAllowResumeForFileDownloads:(BOOL)allow
{
    [[HTTPHelper sharedInstance]beginRequest:fileInfo isBeginDown:isBeginDown setAllowResumeForFileDownloads:allow];
}
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown
{
    [[HTTPHelper sharedInstance]beginRequest:fileInfo isBeginDown:isBeginDown];
}

-(void)beginPostRequest:(NSString*)url withDictionary:(NSDictionary*)postData
{
    [[HTTPHelper sharedInstance]beginPostRequest:url withDictionary:postData];
}

@end
