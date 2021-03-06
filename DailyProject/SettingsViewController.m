//
//  SettingsViewController.m
//  SettingsExample
//
//  Created by Jake Marsh on 10/8/11.
//  Copyright (c) 2011 Rubber Duck Software. All rights reserved.
//

#import "SettingsViewController.h"
#import "ThemeManager.h"
#import "Constants.h"
#import "RMAppDelegate.h"
#import "iRate.h"
#import "AdsConfiguration.h"
#import "RMIndexedArray.h"
#import "EarnGoldMultiPageViewController.h"
#import "resConstants.h"
#import "DAAppsViewController.h"
#import "UMFeedback.h"
#import "Flurry.h"
#import "MobisageRecommendTableViewController.h"
#import "CPPropStoreViewController.h"


NSString* reuseIdentifier = @"UITableViewCellStyleDefault";

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id) init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    
	self.title = NSLocalizedString(Tab_Title_Setting, @"Settings");
    self.tabBarItem.image = [UIImage imageNamed:kIconSetting];
    
	return self;
}

#pragma mark - View lifecycle
- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar
     setBackgroundImage:ThemeImage(@"header_bg")
     forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Back",@"") style: UIBarButtonItemStyleBordered target: nil action: nil];
    newBackButton.tintColor = TintColor;
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self removeAllSections];
    [self addSections];
}
- (void) viewDidUnload {
    [super viewDidUnload];
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark Workaround

- (void)mailComposeController:(MFMailComposeViewController*)controller             didFinishWithResult:(MFMailComposeResult)result                          error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
    {
        UIAlertView* alert = [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"EmailAlertViewTitle", @"") message:NSLocalizedString(@"EmailAlertViewMsg", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil]autorelease];
        [alert show];
    }
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#define kEmailFeedbackBody @"kEmailFeedbackBody"
// Launches the Mail application on the device.
-(void)launchMailAppOnDevice:(BOOL)feeback
{
    //    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
    //    NSString *body = @"&body=It is raining in sunny California!";
    
    NSString * email = [NSString stringWithFormat:@"mailto:&subject=%@&body=%@", NSLocalizedString(@"Title", @""), NSLocalizedString(kEmailFeedbackBody, @"")];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields.
-(void)displayComposerSheet:(BOOL)feedback
{
    MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init]autorelease];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:NSLocalizedString(@"Title", @"")];
    [picker setMessageBody:NSLocalizedString(kEmailFeedbackBody, @"") isHTML:NO];
    
    // Set up recipients
    //    NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
    //    NSArray *bccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    NSArray *recipients = [NSArray arrayWithObject:kDefaultEmailRecipients];
    
    //
    //    [picker setToRecipients:toRecipients];
    [picker setToRecipients:recipients];
    
//    [self presentModalViewController:picker animated:YES];
    [self presentViewController:picker animated:YES completion:nil];
}
-(IBAction)feedback:(id)sender
{
#if 1
    [Flurry logEvent:kOpenFeedbackEvent];
    
    [UMFeedback showFeedback:self withAppkey:UMENG_APPKEY];
#else
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet:YES];
        }
        else
        {
            [self launchMailAppOnDevice:YES];
        }
    }
    else
    {
        [self launchMailAppOnDevice:YES];
    }
#endif
}
#pragma mark about
-(void)rate
{
    NSInteger appleId = [[AdsConfiguration sharedInstance]appleId];
    if (kInvalidID!=appleId) {
        iRate* rate = [iRate sharedInstance];
        rate.appStoreID = appleId;
        
        //enable preview mode
        [rate openRatingsPageInAppStore];
        
        [Flurry logEvent:kOpenRateInSettingEvent];
    }
}
- (IBAction)modalViewAction:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(kAboutTitle, @"") message:NSLocalizedString(@"About", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

-(void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil]autorelease];
    [alert show];
}

#pragma mark addSections
-(void)addGeneralSection
{
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			staticContentCell.reuseIdentifier =reuseIdentifier;
			cell.selectionStyle = UITableViewCellStyleDefault;
            
			cell.textLabel.text = NSLocalizedString(@"AboutTitle", @"");
            //cell.imageView.image = [UIImage imageNamed:@"General"];
		} whenSelected:^(NSIndexPath *indexPath) {
			[self modalViewAction:nil];
		}];
        
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			staticContentCell.cellStyle = UITableViewCellStyleDefault;
			staticContentCell.reuseIdentifier = reuseIdentifier;
            
			cell.textLabel.text = NSLocalizedString(@"kMoreFeedBackKey", @"");
            //cell.imageView.image = [UIImage imageNamed:@"Mail"];
		} whenSelected:^(NSIndexPath *indexPath) {
			[self feedback:nil];
		}];
        
        NSInteger appleId = [[AdsConfiguration sharedInstance]appleId];
        if (kInvalidID!=appleId) {
            [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
                staticContentCell.cellStyle = UITableViewCellStyleDefault;
                staticContentCell.reuseIdentifier = reuseIdentifier;
                
                cell.textLabel.text = NSLocalizedString(@"kMoreRateKey", @"");
                //cell.imageView.image = [UIImage imageNamed:@"AppStore"];
            } whenSelected:^(NSIndexPath *indexPath) {
                [self rate];
            }];
        }
	}];
}
-(void)addRecommendAppList
{
    NSString* title = NSLocalizedString(RecommmendApps, @"");
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			staticContentCell.reuseIdentifier = reuseIdentifier;
			cell.selectionStyle = UITableViewCellStyleDefault;
            
			cell.textLabel.text = title;
            
		} whenSelected:^(NSIndexPath *indexPath) {
            UIViewController* appsViewController = [[[MobisageRecommendTableViewController alloc] init] autorelease];
            //for tab item
            appsViewController.title = title;
            [self.navigationController pushViewController:appsViewController animated:YES];
            
            [Flurry logEvent:kOpenRecommendAppListEvent];
		}];
	}];
    
}

-(void)addUpdateToPremiumSection
{
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			staticContentCell.reuseIdentifier = reuseIdentifier;
			cell.selectionStyle = UITableViewCellStyleDefault;
            
			cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Premium", @""),[CommonHelper gold]];
            
			cell.imageView.image = [UIImage imageNamed:@"Coins"];
		} whenSelected:^(NSIndexPath *indexPath) {
#if 0
            CGRect rect = self.view.frame;
            EarnGoldMultiPageViewController* c = [[[EarnGoldMultiPageViewController alloc]initWithFrame:rect]autorelease];
            UINavigationController* navi = [[[UINavigationController alloc]initWithRootViewController:c]autorelease];
            [self presentViewController:navi animated:YES completion:nil];
#else
            //TODO::显示一个选项，其中包括
            //1.购买积分
            //2.做任务，赚积分
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"CPPropStoreViewController"] animated:NO completion:nil];
#endif
            [Flurry logEvent:kOpenEarnGoldListInSettingEvent];
		}];
	}];
}
-(void)addQuitTipSettingSection
{
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			staticContentCell.reuseIdentifier = reuseIdentifier;
			cell.selectionStyle = UITableViewCellStyleDefault;
            
			cell.textLabel.text = NSLocalizedString(kCloseBackgroundTip, @"");
			//cell.imageView.image = [UIImage imageNamed:@"Notifications"];
            
            UISwitch *quitTipModeSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero]autorelease];
            [quitTipModeSwitch addTarget:self action:@selector(setQuitNotification:) forControlEvents:UIControlEventValueChanged];
            quitTipModeSwitch.on = [((RMAppDelegate*)SharedDelegate) scheduleNotificationWhenQuit];
			cell.accessoryView = quitTipModeSwitch;
		} whenSelected:^(NSIndexPath *indexPath) {
            
		}];
	}];
}
-(void)addSections
{
    [self addGeneralSection];
    if([[AdsConfiguration sharedInstance]getCount]>0)
    {
        [self addRecommendAppList];
        [self addUpdateToPremiumSection];
    }
    
    [self.tableView reloadData];
}

#pragma mark util methods
-(void)setQuitNotification:(id)sender
{
    if([sender isKindOfClass:[UISwitch class]])
    {
        [Flurry logEvent:kSetQuitNotificationEvent];
        
        RMAppDelegate* delegate = (RMAppDelegate*)SharedDelegate;
        [delegate setQuitNotification:((UISwitch*)sender).on];
    }
}

@end