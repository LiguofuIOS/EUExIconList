//
//  BUPOViewController.h
//  ZakerLike
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJGridItem.h"
#import "JSON.h"
#import "EUtility.h"

@class EUExIconList;

#define KUEXIS_NSMutableArray(x,y) ([x isKindOfClass:[NSMutableArray class]] && [x count]>y)

//#define KUEXIS_NSString(x) ([x isKindOfClass:[NSString class]] && x.length>0

@interface BUPOViewController : UIViewController<UIScrollViewDelegate,BJGridItemDelegate,UIGestureRecognizerDelegate> {
    
    NSMutableArray *gridItems;
    
    BJGridItem *addbutton;
    
    int page;
    
    float preX;
    
    BOOL isMoving;
    
    CGRect preFrame;
    
    BOOL isEditing;
    
    UITapGestureRecognizer *singletap;

}

@property (nonatomic, assign) EUExIconList *euexIconList;

@property (nonatomic, strong) NSMutableArray *inArguments;

@property (nonatomic, strong)  UIImageView *backgoundImage;

@property (nonatomic, strong)  UIScrollView *scrollview;

@property (nonatomic, strong) NSMutableDictionary *dataFrameDict;

@property (nonatomic, strong) NSMutableDictionary *listItemDict;

@property (nonatomic, strong) NSMutableArray *dataArry;

@property (nonatomic, strong) NSString *titleTextColor;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSString *placeholderImgPath;

- (id)initwithEuexObj:(EUExIconList *)euexObj;

- (void)addiconListViewItem:(NSString *)jsonStr;

- (void)resetFrameOpenIconList:(NSMutableArray *)arr;

- (void)refreshIconListViewWithDataArr;

- (void)onClickDeleteBtn:(NSString *)str;

- (void)closeIconListView;

- (void)refreshIconListView;

@end
