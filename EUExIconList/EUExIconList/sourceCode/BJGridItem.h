//
//  BJGridItem.h
//  :
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@class EUExIconList;
typedef enum{
    BJGridItemNormalMode = 0,
    BJGridItemEditingMode = 1,
}BJMode;

@protocol BJGridItemDelegate;

@interface BJGridItem : UIView{
    
    UIImage *editingImage;
    NSString *titleText;
    BOOL isEditing;
    UIButton *deleteButton;
    NSInteger index;
    //long press point
    CGPoint point;
    
}

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, assign) BOOL isRemovable;

@property (nonatomic, assign) BOOL isCanMove;


@property (nonatomic, assign) NSInteger index;

//lgf

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) NSString *cbJsonData;

@property (nonatomic, strong) UILabel *labelTitle;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, assign) EUExIconList *euexIconListObj;

- (void) itemRemoveFromSuperview;

@property (weak,nonatomic)id<BJGridItemDelegate> delegate;

- (id) initWithDataArr:(NSMutableArray *)dataArr atIndex:(NSInteger)aIndex editable:(BOOL)removable width:(float)width height:(float)heigth euexObj:(EUExIconList *)euexIconListItem titleColor:(NSString *)titleColorRgb placeholderImg:(NSString *)placeholderImgPath;

- (void) enableEditing;

- (void) disableEditing;

@end

@protocol BJGridItemDelegate <NSObject>

- (void) gridItemDidClicked:(UIButton *) gridItem;

- (void) gridItemDidEnterEditingMode:(BJGridItem *) gridItem;

- (void) gridItemDidDeleted:(BJGridItem *) gridItem atIndex:(NSInteger)index;

- (void) gridItemDidMoved:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*)recognizer;

- (void) gridItemDidEndMoved:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*) recognizer;

@end