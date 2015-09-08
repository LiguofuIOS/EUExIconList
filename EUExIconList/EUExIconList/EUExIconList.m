//
//  EUExIconList.m
//  EUExIconList
//
//  Created by liguofu on 15/6/25.
//  Copyright (c) 2015年 appcan. All rights reserved.
//

#import "EUExIconList.h"

@implementation EUExIconList
    

- (id)initWithBrwView:(EBrowserView *)eInBrwView {
    
    if (self = [super initWithBrwView:eInBrwView]) {
        
        _canMoveToScrollView = YES;

        NSLog(@"lgf--EUExIconList--version--3.0.12_info == 去掉不可删除icon的长按事件");
    }
    
    return self;
}


- (void)open:(NSMutableArray *)inArguments {
    
    
    if (_iconListView) {
        
        return;
        
    } else {
        
        _iconListView = [[BUPOViewController alloc] initwithEuexObj:self];
        _iconListView.inArguments = inArguments;
    }
    
    if ([EUtility respondsToSelector:@selector(brwView:addSubviewToScrollView:)] && _canMoveToScrollView == YES) {
        
        [EUtility brwView:meBrwView addSubviewToScrollView:_iconListView.view];
        
    } else {
        
        [EUtility brwView:meBrwView addSubview:_iconListView.view];
        
    }

}

- (void)delIconItem:(NSMutableArray *)inArguments {
    
    if (_iconListView) {
        
        if (KUEXIS_NSMutableArray(inArguments, 0)) {
            
            NSString *delIconJson = [inArguments objectAtIndex:0];
            
            if (KUEXIS_NSString(delIconJson)) {
                
                if (_iconListView) {
                    
                    [_iconListView onClickDeleteBtn:delIconJson];
                }
            }
        }
    }
}

- (void)getCurrentIconList:(NSMutableArray *)inArguments {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:_iconListView.dataArry   forKey:@"listItem"];
    
    for (NSDictionary *dicc in _iconListView.dataArry) {
        
        NSLog(@"appcan-->EUExIconList.m-->getCurrentIconList-->title == %@",[dicc objectForKey:@"title"]);
        
    }
    
    [self jsSuccessWithName:@"uexIconList.cbGetCurrentIconList" opId:0 dataType:1 strData:[dict JSONFragment]];
    
}

- (void)refreshIconList:(NSMutableArray *)inArguments {
    
    if (inArguments.count == 0) {
        
        if (_iconListView) {
            
            [_iconListView refreshIconListView];
            
        }
        
    } else {
        
        if (_iconListView) {
            
            NSString *dataJson = [inArguments objectAtIndex:0];
            
            NSMutableDictionary *listItemDict = [dataJson JSONValue];
            
            _iconListView.dataArry = [listItemDict objectForKey:@"listItem"];
            
            [_iconListView refreshIconListViewWithDataArr];
            
        }
        
    }
    
}

- (void)close:(NSMutableArray *)inArguments {
    
    if (_iconListView) {
        
        [_iconListView.view removeFromSuperview];
    
        [_iconListView.pageControl removeFromSuperview];
        
        _iconListView = nil;
    }
    
}

- (void)setOption:(NSMutableArray *)inArguments {
    
    if (KUEXIS_NSMutableArray(inArguments, 0)) {
        
        NSString *jsonStr = [inArguments objectAtIndex:0];
        
        if (KUEXIS_NSString(jsonStr)) {
            
            NSDictionary *dict = [jsonStr JSONValue];
            _canMoveToScrollView = [[dict objectForKey:@"is_follow_web_roll"] boolValue];
            
        } else {
            
            _canMoveToScrollView = YES;
            
        }
        
    } else {
        
        _canMoveToScrollView = YES;
        
    }
    
}

- (void)addIconItem:(NSMutableArray *)inArguments {
    
    if (KUEXIS_NSMutableArray(inArguments, 0)) {
        
        NSString *addiconItemData = [inArguments objectAtIndex:0];
        
        if (KUEXIS_NSString(addiconItemData)) {
            
            if (_iconListView) {
                
                [_iconListView addiconListViewItem:addiconItemData];
                
            }
       
        }
    
    }

}

- (void)resetFrame:(NSMutableArray *)inArguments {
    
    if (_iconListView) {
        
        [_iconListView resetFrameOpenIconList:inArguments];
        
    }
    
}

@end
