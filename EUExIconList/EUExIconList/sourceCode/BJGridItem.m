//
//  BJGridItem.m
//  ZakerLike
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "BJGridItem.h"
#import "EUExIconList.h"

@implementation BJGridItem
@synthesize isEditing, isRemovable, isCanMove, index;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Initialization code
        
    }
    
    return self;
    
}

- (id)initWithDataArr:(NSMutableArray *)dataArr atIndex:(NSInteger)aIndex editable:(BOOL)removable width:(float)width height:(float)heigth euexObj:(EUExIconList *)euexIconListItem titleColor:(NSString *)titleColorRgb placeholderImg:(NSString *)placeholderImgPath{
    
    _euexIconListObj = euexIconListItem;
    
    self = [super initWithFrame:CGRectMake(10, 0, width, heigth)];
    
    if (self) {
        
        NSMutableDictionary *dataItemDict = [NSMutableDictionary dictionary];
        
        if (aIndex < dataArr.count) {
            
            dataItemDict = [dataArr objectAtIndex:aIndex];
            
        }
        _cbJsonData = [dataItemDict JSONFragment];
        
        NSString *imagePath = [euexIconListItem absPath:[dataItemDict objectForKey:@"image"]];
        
        //NSString *placeholderImgPath = [_euexIconListItem absPath:[_listItemDict objectForKey:@"placeholderImg"]];
        
        //NSString *placeholderImgPath = @"uexIconList/placeholderImg.png";
        
        NSString *title = [dataItemDict objectForKey:@"title"];
        
        NSString *isCanDel = [dataItemDict objectForKey:@"isCanDel"];
        
        UIImage *placeholderImg = [UIImage imageWithData:[self getImageDataByPath:placeholderImgPath]];
        
        isRemovable = YES;
        isCanMove = YES;
        isEditing = NO;
        
        index = aIndex;
        
        if (KUEXIS_NSString(isCanDel)) {
            
            isRemovable = [isCanDel boolValue];
            
        }
        
        NSString *isCanMoveStr = [dataItemDict objectForKey:@"isCanMove"] ;
        
        if (KUEXIS_NSString(isCanMoveStr)) {
            
            isCanMove = [isCanMoveStr boolValue];
            
        }
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        float btnW = CGRectGetWidth(self.frame);
        float btnH = CGRectGetHeight(self.frame) - 20;
        
        float btnSize = btnW > btnH ? btnH:btnW ;
        
        //[_button setFrame:CGRectMake(0, 5,btnSize, btnSize)];
        
         [_button setFrame:CGRectMake(btnSize * 0.15, 10, btnSize * 0.7, btnSize * 0.7)];
        
        _button.contentMode = UIViewContentModeScaleAspectFit;

        //占位图片
        if (!placeholderImg) {
            
            placeholderImg = [UIImage imageNamed:@"uexIconList/placeholderImg.png"];
            
        }
        
        if([imagePath hasPrefix:@"http://"]) {
            
            if ([_button respondsToSelector:@selector(setImageWithURL:forState:placeholderImage:)]) {
                
                [_button setImageWithURL:[NSURL URLWithString:imagePath] forState:UIControlStateNormal placeholderImage:placeholderImg];
                
            }
            
        } else {
            
            UIImage *imageview = [UIImage imageWithData:[self getImageDataByPath:imagePath]];
            
            if (imageview) {
                
                [_button setBackgroundImage:imageview forState:UIControlStateNormal];
                
            } else {
                
                [_button setBackgroundImage:placeholderImg forState:UIControlStateNormal];
                
            }
        }
        
        [_button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_button];
        
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_button.frame) + 5, CGRectGetWidth(self.frame), 20)];
        
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.text = title;
        _labelTitle.textColor = [EUtility ColorFromString:titleColorRgb];
        _labelTitle.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:_labelTitle];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedLong:)];
        
        if (isRemovable) {
            
            [self addGestureRecognizer:longPress];

        }
        
        if (isRemovable) {
            
            deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            float w = 20;
            float h = 20;
            
            [deleteButton setFrame:CGRectMake(self.frame.size.width - 20, self.frame.origin.y, w, h)];
            [deleteButton setImage:[UIImage imageNamed:@"uexIconList/plugin_iconlist_del_icon.png"] forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(removeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [deleteButton setHidden:YES];
            
            [self addSubview:deleteButton];
            
        }
        
    }
    
#if 0
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 3;
    
    _button.layer.borderWidth = 2;
    _button.layer.borderColor = [UIColor greenColor].CGColor;
    
    _labelTitle.layer.borderColor = [UIColor blackColor].CGColor;
    _labelTitle.layer.borderWidth = 2;
#endif
    
    return self;
    
}

#pragma mark - UI actions

- (void)clickItem:(UIButton *)sender {
    
    [delegate gridItemDidClicked:sender];
    
}

- (void)pressedLong:(UILongPressGestureRecognizer *) gestureRecognizer {
    
    if(isEditing == NO) {
        
        [self performSelectorOnMainThread:@selector(onLongPressEvent) withObject:nil waitUntilDone:NO];
    }
    
    switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            
            point = [gestureRecognizer locationInView:self];
            
            [delegate gridItemDidEnterEditingMode:self];
            
            break;
            
        case UIGestureRecognizerStateEnded:
            
            point = [gestureRecognizer locationInView:self];
            
            [delegate gridItemDidEndMoved:self withLocation:point moveGestureRecognizer:gestureRecognizer];
            
            break;
            
        case UIGestureRecognizerStateFailed:
            
            break;
            
        case UIGestureRecognizerStateChanged:
            
            //移动
            [delegate gridItemDidMoved:self withLocation:point moveGestureRecognizer:gestureRecognizer];
            
            break;
            
        default:
            
            break;
            
    }
    
}

- (void)removeButtonClicked:(id) sender  {
    
    [delegate gridItemDidDeleted:self atIndex:index];
}

#pragma mark - Custom Methods

- (void)enableEditing {
    
    if (self.isEditing == YES)
        
        return;
    
    self.isEditing = YES;
    
    [deleteButton setHidden:NO];
    
    //[_button setEnabled:NO];
    
    CGFloat rotation = 0.03;
    
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    shake.duration = 0.13;
    shake.autoreverses = YES;
    shake.repeatCount  = MAXFLOAT;
    shake.removedOnCompletion = NO;
    
    shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform,-rotation, 0.0 ,0.0 ,1.0)];
    shake.toValue   = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, rotation, 0.0 ,0.0 ,1.0)];
    
    [self.layer addAnimation:shake forKey:@"shakeAnimation"];
    
}

- (void)disableEditing {
    
    [self.layer removeAnimationForKey:@"shakeAnimation"];
    
    [deleteButton setHidden:YES];
    
    //[_button setEnabled:YES];
    
    self.isEditing = NO;
    
}


- (void)itemRemoveFromSuperview {
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [self setFrame:CGRectMake(self.frame.origin.x+50, self.frame.origin.y+50, 0, 0)];
        
        [deleteButton setFrame:CGRectMake(0, 0, 0, 0)];
        
    }completion:^(BOOL finished) {
        
        [super removeFromSuperview];
        
    }];
    
}

- (NSData *)getImageDataByPath:(NSString *)imagePath {
    
    NSData *imageData = nil;
    
    if ([imagePath hasPrefix:@"http://"]) {
        
        NSURL *imagePathURL = [NSURL URLWithString:imagePath];
        imageData = [NSData dataWithContentsOfURL:imagePathURL];
        
    } else {
        
        imageData = [NSData dataWithContentsOfFile:imagePath];
        
    }
    
    return imageData;
}

- (void)onLongPressEvent{
    
    [_euexIconListObj jsSuccessWithName:@"uexIconList.onLongPress" opId:0 dataType:1 strData:@"0"];
    
}
@end
