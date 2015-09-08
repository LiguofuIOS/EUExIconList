//
//  EUExIconList.h
//  EUExIconList
//
//  Created by liguofu on 15/6/25.
//  Copyright (c) 2015年 appcan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBrowserView.h"
#import "SDImageCache.h"
#import "EUExBase.h"
#import "EUtility.h"
#import "JSON.h"

#import "BUPOViewController.h"

#define KUEXIS_NSMutableArray(x,y) ([x isKindOfClass:[NSMutableArray class]] && [x count]>y)

#define KUEXIS_NSString(x) ([x isKindOfClass:[NSString class]] && x.length>0)

#define KUEX_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define KUEX_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface EUExIconList : EUExBase

@property(nonatomic, assign) BOOL canMoveToScrollView;

@property(nonatomic, strong) BUPOViewController *iconListView;

@end
