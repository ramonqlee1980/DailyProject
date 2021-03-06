//
//  RMArticle.h
//  InfiniteTabProject
//
//  Created by Ramonqlee on 8/4/13.
//  Copyright (c) 2013 iDreems. All rights reserved.
//
/**
 article class
 */
#import <Foundation/Foundation.h>

@interface RMArticle : NSObject

@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* summary;
@property(nonatomic,copy)NSString* content;
@property(nonatomic,copy)NSString* url;
@property(nonatomic,assign)NSInteger likeNumber;
@property(nonatomic,assign)NSInteger favoriteNumber;
@property(nonatomic,assign)NSInteger commentNumber;
@end
