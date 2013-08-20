//
//  ViewController.h
//  MSTableRecommendDemo
//
//  Created by stick on 12-12-4.
//  Copyright (c) 2012年 stick. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"
#import "MobiSageSDK.h"


@interface MobisageRecommendTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, MobiSageRecommendDelegate>


@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) MSRecommendContentView *recommendView;





@end
