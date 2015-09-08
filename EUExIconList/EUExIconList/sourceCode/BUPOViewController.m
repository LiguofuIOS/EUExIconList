
//
//  BUPOViewController.m
//  ZakerLike
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//

#import "BUPOViewController.h"
#import "EUExIconList.h"
//#define columns 4
//#define rows 2
//#define itemsPerPage (rows*columns)
#define space 15
//#define gridHight 60
//#define gridWith 60
#define unValidIndex  -1
#define threshold 10
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface BUPOViewController(private)

- (NSInteger)indexOfLocation:(CGPoint)location;

- (CGPoint)orginPointOfIndex:(NSInteger)index;

- (void) exchangeItem:(NSInteger)oldIndex withposition:(NSInteger) newIndex;

@end

@implementation BUPOViewController {
    
    int gridHight, gridWith;
    
    float x, y, w, h;
    
    NSInteger allPageNum, line, column, itemsPerPage;
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
}

- (id)initwithEuexObj:(EUExIconList *)euexObj {
    
    _euexIconList = euexObj;
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (!KUEXIS_NSMutableArray(_inArguments,1)) {
        
        return;
        
    }
    
    page = 0;
    isEditing = NO;
    //NSLog(@"打开数据-%@",_inArguments);
    
    NSString *frameStr = [_inArguments objectAtIndex:0];
    NSString *dataJson = [_inArguments objectAtIndex:1];
    
    _dataFrameDict = [frameStr JSONValue];
    _listItemDict = [dataJson JSONValue];
    
    _dataArry = [_listItemDict objectForKey:@"listItem"];
    
    x = [[_dataFrameDict objectForKey:@"x"] floatValue];
    y = [[_dataFrameDict objectForKey:@"y"] floatValue];
    w = [[_dataFrameDict objectForKey:@"w"] floatValue];
    h = [[_dataFrameDict objectForKey:@"h"] floatValue];
    
    line = [[_dataFrameDict objectForKey:@"line"] floatValue];
    column = [[_dataFrameDict objectForKey:@"row"] floatValue];
    
    _titleTextColor = [_dataFrameDict objectForKey:@"titleTextColor"];
    
    //每一页icon个数
    itemsPerPage = line * column;
    
    NSInteger n = _dataArry.count % itemsPerPage;
    NSInteger m = _dataArry.count / itemsPerPage;
    
    //共有多少页
    allPageNum = n== 0?m:m + 1;
    
    NSString *backgroundColor= @"#EFEFEF";
    
    if ([_dataFrameDict objectForKey:@"backgroundColor"]) {
        
        backgroundColor = [_dataFrameDict objectForKey:@"backgroundColor"];
        
    }
    
    _placeholderImgPath = [_euexIconList absPath:[_listItemDict objectForKey:@"placeholderImg"]];

    [self.view setFrame:CGRectMake(x, y, w, h)];
    //[self.view setBackgroundColor:[UIColor whiteColor]];
    
#if 0
    self.view.layer.borderColor = [UIColor yellowColor].CGColor;
    self.view.layer.borderWidth = 6;
#endif
    
    gridItems = [[NSMutableArray alloc] initWithCapacity:6];
    
    int pageControlHeight = 20;
    
    gridWith = ((w - (column + 1) * space)) / column;
    
    gridHight = (h - pageControlHeight - ((line - 1) * space)) / line;
    
    _scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, w, h)];

    _scrollview.delegate = self;
    
    _scrollview.scrollEnabled = YES;
    
    _scrollview.pagingEnabled = YES;

    _scrollview.showsVerticalScrollIndicator = NO;
    
    _scrollview.showsHorizontalScrollIndicator = NO;
    
    _scrollview.backgroundColor = [EUtility ColorFromString:backgroundColor];
    
    [self.view addSubview:_scrollview];
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(x+5,h-20,w-10, 20)];
    
    _pageControl.numberOfPages = allPageNum;
    
    _pageControl.currentPage=0;
    
    _pageControl.pageIndicatorTintColor = [EUtility ColorFromString:@"#D4DCE6"];
    
    _pageControl.currentPageIndicatorTintColor = [EUtility ColorFromString:@"#777777"];
    
    _pageControl.backgroundColor = [UIColor clearColor];
    
    _pageControl.userInteractionEnabled = NO;
    
    [_pageControl addTarget:self action:@selector(ValueChange:) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:_pageControl];
    
    //singletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    //[singletap setNumberOfTapsRequired:1];
    
    //singletap.delegate = self;
    
    //[_scrollview addGestureRecognizer:singletap];
    
    for (int i = 0; i < _dataArry.count; i++) {
        
        [self createIconListView:@"" addIndex:0];
        
    }
    
}

/*! @brief 删除操作,将数据从数组删除并刷新界面
 *
 * @param 要删除item的信息标识
 */

- (void)onClickDeleteBtn:(NSString *)str {
    
    NSMutableDictionary *dict = [str JSONValue];
    
    [_dataArry removeObject:dict];
    
    for (__strong BJGridItem *item in gridItems) {
        
        if ([item.cbJsonData isEqualToString:str]) {
            
            NSInteger index = item.index;
            
            [gridItems removeObjectAtIndex:index];
            
            [UIView animateWithDuration:0.2 animations:^{
                
                CGRect lastFrame = item.frame;
                CGRect curFrame;
                
                for (NSInteger i = index; i < [gridItems count]; i++) {
                    
                    BJGridItem *temp = [gridItems objectAtIndex:i];
                    
                    curFrame = temp.frame;
                    
                    [temp setFrame:lastFrame];
                    
                    lastFrame = curFrame;
                    
                    [temp setIndex:i];
                }
                
                [addbutton setFrame:lastFrame];
                
            }];
            
            [item itemRemoveFromSuperview];
            
            item = nil;
            
            break;
        }
        
    }
    
    NSInteger n = _dataArry.count % itemsPerPage;
    NSInteger m = _dataArry.count / itemsPerPage;
    
    //共有多少页
    allPageNum = n == 0?m:m + 1;
    
    _pageControl.numberOfPages = allPageNum;
    
    [_scrollview setContentSize:CGSizeMake(_scrollview.frame.size.width * allPageNum , _scrollview.frame.size.height)];
    
    [self performSelectorOnMainThread:@selector(delIconItemCompleted) withObject:nil waitUntilDone:NO];
}

/** @brief 执行无参数刷新
 *
 */

- (void)refreshIconListView {
    
    if (isEditing) {
        
        for (BJGridItem *item in gridItems) {
            
            [item disableEditing];
            
        }
        
        [addbutton disableEditing];
        
    }
    
    isEditing = NO;
    
    _pageControl.currentPage = 0;

    _scrollview.contentOffset=CGPointMake(0,0);
}

/*! @brief 执行有参数刷新
 *
 * 数据改变,刷新界面
 */

- (void)refreshIconListViewWithDataArr {
    
    NSInteger n = _dataArry.count % itemsPerPage;
    NSInteger m = _dataArry.count / itemsPerPage;
    
    //共有多少页
    allPageNum = n == 0?m:m + 1;
    
    _pageControl.numberOfPages = allPageNum;
    
    [_scrollview setContentSize:CGSizeMake(_scrollview.frame.size.width * allPageNum , _scrollview.frame.size.height)];
    
    
    [UIView animateWithDuration:0.2f animations:^{
        
        for (BJGridItem *item in gridItems) {
            
            [item removeFromSuperview];
        }
        [gridItems removeAllObjects];
        
    }];
    
    [self.view addSubview:_scrollview];
    [self.view addSubview:_pageControl];
    
#if 0
    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 4;
#endif
    for (int i = 0; i < _dataArry.count; i++) {
        
        [self createIconListView:@"" addIndex:0];
        
    }

    [self refreshIconListView];
    
}

/*! @brief 执行增加item的操作
 *
 * 如果最后一个item可移动,新增加在最后位置;如果不可移动,则增加在倒数第二个位置
 *
 * @param jsonStr 增加item的数据信息
 */

- (void)addiconListViewItem:(NSString *)jsonStr {
    
    NSMutableDictionary *dict = [jsonStr JSONValue];
    
    if ([_dataArry containsObject:dict]) {
        
        NSDictionary *cbDict=[NSDictionary dictionaryWithObjectsAndKeys:@"fail",@"status",@"icon_is_exist",@"info", nil];
        
        [_euexIconList jsSuccessWithName:@"uexIconList.cbAddIconItem" opId:0 dataType:0 strData:[cbDict JSONFragment]];
        
        return;
    }
    
    NSMutableDictionary *lastItemDict = [_dataArry lastObject];
    
    BOOL lastItemCanMove = YES;
    
    NSInteger addIndex = -1;
    
    if ([lastItemDict objectForKey:@"isCanMove"]) {
        
        lastItemCanMove = [[lastItemDict objectForKey:@"isCanMove"] boolValue];
        
    }
    if (lastItemCanMove == NO) {
        
        //暂时未考虑最后一个Item的特殊情况,后续增加
        if (_dataArry.count > 0) {
            
            [_dataArry insertObject:dict atIndex:_dataArry.count-1];
            
            addIndex = 102410241024;
            
            [UIView animateWithDuration:0.2f animations:^{
                
                BJGridItem *item = [gridItems lastObject];
                
                [item removeFromSuperview];
                
                [gridItems removeObject:item];
                
                
            }];
        }
        
    } else {
        
        [_dataArry addObject:dict];
        
    }
    
    
    NSInteger n = _dataArry.count % itemsPerPage;
    NSInteger m = _dataArry.count / itemsPerPage;
    
    allPageNum = n==0?m:m+1;
    
    _pageControl.numberOfPages = allPageNum;
    _pageControl.currentPage = allPageNum-1;
    
    _scrollview.contentOffset = CGPointMake(w * (allPageNum - 1), 0);
    
    if (addIndex != -1) {
        
        for (int i = 0; i < 2; i++) {
            
            [self createIconListView:@"addiconListViewItem" addIndex:addIndex];
 
        }
        
    } else {
       
        [self createIconListView:@"" addIndex:0];
        
    }
    
}

- (void)resetFrameOpenIconList:(NSMutableArray *)arr {
    
    NSString *frameStr = [arr objectAtIndex:0];
    _dataFrameDict = [frameStr JSONValue];
    
    x = [[_dataFrameDict objectForKey:@"x"] floatValue];
    y = [[_dataFrameDict objectForKey:@"y"] floatValue];
    w = [[_dataFrameDict objectForKey:@"w"] floatValue];
    h = [[_dataFrameDict objectForKey:@"h"] floatValue];
    
    line = [[_dataFrameDict objectForKey:@"line"] floatValue];
    column = [[_dataFrameDict objectForKey:@"row"] floatValue];
    _titleTextColor = [_dataFrameDict objectForKey:@"titleTextColor"];
    
    NSString *backgroundColor= @"#EFEFEF";
    
    if ([_dataFrameDict objectForKey:@"backgroundColor"]) {
        
        backgroundColor = [_dataFrameDict objectForKey:@"backgroundColor"];
    }
    
    [self.view setFrame:CGRectMake(x, y, w, h)];
    
    _scrollview.backgroundColor = [EUtility ColorFromString:backgroundColor];
    
    _scrollview.frame = CGRectMake(0, 0, w, h);
    
    _pageControl.frame = CGRectMake(x+5,h-20,w-10, 20);
    
    //每一页icon个数
    itemsPerPage = line * column;
    
    NSInteger n = _dataArry.count % itemsPerPage;
    NSInteger m = _dataArry.count / itemsPerPage;
    
    allPageNum = n==0?m:m+1;
    
    _pageControl.numberOfPages = allPageNum;
    _pageControl.currentPage = 0;
    
    [_scrollview setContentSize:CGSizeMake(w * allPageNum , h)];
    
    [UIView animateWithDuration:0.2f animations:^{
        
        for (BJGridItem *item in gridItems) {
            
            [item removeFromSuperview];
        }
        [gridItems removeAllObjects];
        
    }];
    
    [self.view addSubview:_scrollview];
    [self.view addSubview:_pageControl];
    
#if 0
    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 4;
#endif
    for (int i = 0; i < _dataArry.count; i++) {
        
        [self createIconListView:@"" addIndex:0];
        
    }
    
}

- (void)closeIconListView {
    
    if (_scrollview) {
        
        [_scrollview removeFromSuperview];
        
        _scrollview = nil;
    }
    
    if (_pageControl) {
        
        [_pageControl removeFromSuperview];
        
        _pageControl = nil;
    }
    
}

- (void)ValueChange:(UIPageControl *)page {
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
}

#pragma mark-- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect frame = self.backgoundImage.frame;
    
    frame.origin.x = preFrame.origin.x + (preX - scrollView.contentOffset.x)/10 ;
    
    if (frame.origin.x <= 0 && frame.origin.x > scrollView.frame.size.width - frame.size.width ) {
        
        self.backgoundImage.frame = frame;
        
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger currentPage = scrollView.contentOffset.x/w;
    
    if (currentPage >= allPageNum) {
        
        return;
        
    }
    
    _pageControl.currentPage = currentPage;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    preX = scrollView.contentOffset.x;
    preFrame = _backgoundImage.frame;
    
}

- (void)createIconListView:(NSString *)flag addIndex:(NSInteger)addIndex {
    
    CGRect frame = CGRectMake(space, 0, gridWith, gridHight);
    
    NSInteger n = [gridItems count];
    
    NSInteger row = n / column;
    NSInteger col = n % column;
    NSInteger curpage = n / itemsPerPage;
    
    row = row % line;
    
    frame.origin.x = frame.origin.x + frame.size.width * col + space * col + _scrollview.frame.size.width * curpage;
    frame.origin.y = frame.origin.y + frame.size.height * row + space * row;
    
    if ([flag isEqualToString:@"addiconListViewItem"]) {
        
       // n = addIndex;
    }

    BJGridItem *gridItem = [[BJGridItem alloc] initWithDataArr:_dataArry atIndex:n editable:YES width:gridWith height:gridHight euexObj:_euexIconList titleColor:_titleTextColor placeholderImg:_placeholderImgPath];
    
    if ([flag isEqualToString:@"addiconListViewItem"]) {
        
       // n = [gridItems count];

    }
    
    [gridItem setFrame:frame];
    
    gridItem.delegate = self;
    
    [gridItems addObject:gridItem];
    
    [_scrollview addSubview:gridItem];
    
    gridItem = nil;
    
    //move the add button
    row = n / column;
    col = n % column;
    curpage = n / itemsPerPage;
    row = row % line;
    
    frame = CGRectMake(space, 0, gridWith, gridHight);
    
    frame.origin.x = frame.origin.x + frame.size.width * col + space * col + _scrollview.frame.size.width * curpage;
    frame.origin.y = frame.origin.y + frame.size.height * row + space * row;
    
    [_scrollview setContentSize:CGSizeMake(_scrollview.frame.size.width * (curpage + 1), _scrollview.frame.size.height)];
    
    //    [scrollview scrollRectToVisible:CGRectMake(scrollview.frame.size.width * curpage, scrollview.frame.origin.y, scrollview.frame.size.width, scrollview.frame.size.height) animated:NO];
    //            [UIView animateWithDuration:0.2f animations:^{
    //                [addbutton setFrame:frame];
    //            }];
    //            addbutton.index += 1;
    
}

#pragma mark-- BJGridItemDelegate

- (void)gridItemDidClicked:(UIButton *)gridItem {
    
    for (BJGridItem *clickItem in gridItems) {
        
        if ([clickItem.button isEqual:gridItem]) {
            
            if (clickItem.isEditing == NO) {
                
                [self performSelectorOnMainThread:@selector(clickItemCbMethod:) withObject:clickItem.cbJsonData waitUntilDone:NO];
                
            }
            
            break;
        }
    }
    
}

- (void)gridItemDidDeleted:(BJGridItem *)gridItem atIndex:(NSInteger)index {
    
    [self performSelectorOnMainThread:@selector(deletedCbMethod:) withObject:gridItem.cbJsonData waitUntilDone:NO];

}

- (void)deletedCbMethod:(NSString *)cbString {
    
    [_euexIconList jsSuccessWithName:@"uexIconList.onDelClick" opId:0 dataType:0 strData:cbString];

}

- (void)clickItemCbMethod:(NSString *)cbString {
    
    [_euexIconList jsSuccessWithName:@"uexIconList.cbClickItem" opId:0 dataType:0 strData:cbString];
    
}

- (void)gridItemDidEnterEditingMode:(BJGridItem *)gridItem{
    
    for (BJGridItem *item in gridItems) {
        
        [item enableEditing];
        
    }
    
    isEditing = YES;
    
}

- (void)gridItemDidMoved:(BJGridItem *)gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    
    CGRect frame = gridItem.frame;
    CGPoint _point = [recognizer locationInView:self.scrollview];
    CGPoint pointInView = [recognizer locationInView:self.view];
    
    frame.origin.x = _point.x - point.x;
    frame.origin.y = _point.y - point.y;
    gridItem.frame = frame;
    
    NSInteger toIndex = [self indexOfLocation:_point];
    NSInteger fromIndex = gridItem.index;
    
    BJGridItem *toItem = nil;
    
    if (toIndex >= 0 && toIndex < gridItems.count) {
        
        toItem = [gridItems objectAtIndex:toIndex];
        
    }

    NSLog(@"fromIndex:%ld toIndex:%ld",(long)fromIndex,(long)toIndex);
    
    if (toIndex != unValidIndex && toIndex != fromIndex && gridItem.isCanMove == YES && toItem.isCanMove == YES  ) {
        
        BJGridItem *moveItem = [gridItems objectAtIndex:toIndex];
        
        [_scrollview sendSubviewToBack:moveItem];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGPoint origin = [self orginPointOfIndex:fromIndex];
            
            moveItem.frame = CGRectMake(origin.x+10, origin.y, moveItem.frame.size.width, moveItem.frame.size.height);

        }];
        //移动
        [self exchangeItem:fromIndex withposition:toIndex];

    }
    //翻页
    if (pointInView.x >= _scrollview.frame.size.width - threshold) {
        
        [_scrollview scrollRectToVisible:CGRectMake(_scrollview.contentOffset.x + _scrollview.frame.size.width, 0, _scrollview.frame.size.width, _scrollview.frame.size.height) animated:YES];
        
    }else if (pointInView.x < threshold) {
        
        [_scrollview scrollRectToVisible:CGRectMake(_scrollview.contentOffset.x - _scrollview.frame.size.width, 0, _scrollview.frame.size.width, _scrollview.frame.size.height) animated:YES];
        
    }
    
}

- (void)gridItemDidEndMoved:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*) recognizer {
    
    CGPoint _point = [recognizer locationInView:self.scrollview];
    
    NSInteger toIndex = [self indexOfLocation:_point];
    
    if (toIndex == unValidIndex || toIndex != gridItem.index ) {
        
        toIndex = gridItem.index;
    }
    
    CGPoint origin = [self orginPointOfIndex:toIndex];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        gridItem.frame = CGRectMake(origin.x+10, origin.y, gridItem.frame.size.width, gridItem.frame.size.height);
        
    }];
    
}

- (void) handleSingleTap:(UITapGestureRecognizer *) gestureRecognizer{
    
    if (isEditing) {
        
        for (BJGridItem *item in gridItems) {
            
            [item disableEditing];
            
        }
        
        [addbutton disableEditing];
        
    }
    
    isEditing = NO;
    
}

- (void)delIconItemCompleted {
   
    [_euexIconList jsSuccessWithName:@"uexIconList.cbDelIconItemCompleted" opId:0 dataType:0 strData:@""];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if(touch.view != _scrollview) {
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

#pragma mark-- private
- (NSInteger)indexOfLocation:(CGPoint)location {
    
    NSInteger index;
    
    NSInteger _page = location.x / SCREEN_WIDTH;
    
    NSInteger row =  location.y / (gridHight + space);
    
    NSInteger col = (location.x - _page * SCREEN_WIDTH) / (gridWith + space);
    
    if (row >= line || col >= column) {
        
        return  unValidIndex;
    }
    index = itemsPerPage * _page + row * column + col;
    
    if (index >= [gridItems count]) {
        
        return  unValidIndex;
    }
    
    return index;
}

- (CGPoint)orginPointOfIndex:(NSInteger)index{
    
    CGPoint point = CGPointZero;
    
    if (index > [gridItems count] || index < 0) {
        
        return point;
        
    } else {
        
        NSInteger _page = index / itemsPerPage;
        NSInteger row = (index - _page * itemsPerPage) / column;
        NSInteger col = (index - _page * itemsPerPage) % column;
        
        point.x = _page * SCREEN_WIDTH + col * gridWith + (col ) * space;
        point.y = row * gridHight + row * space;
        return  point;
    }
}

- (void)exchangeItem:(NSInteger)oldIndex withposition:(NSInteger)newIndex {
    
    ((BJGridItem *)[gridItems objectAtIndex:oldIndex]).index = newIndex;
    
    ((BJGridItem *)[gridItems objectAtIndex:newIndex]).index = oldIndex;
    
    [gridItems exchangeObjectAtIndex:oldIndex withObjectAtIndex:newIndex];
    
    if (oldIndex >= 0 && oldIndex < _dataArry.count && newIndex >= 0 && newIndex < _dataArry.count) {
        
        [_dataArry exchangeObjectAtIndex:oldIndex withObjectAtIndex:newIndex];

    }
    
}

- (void)viewDidUnload {
    
    [self setBackgoundImage:nil];
    
    [self setScrollview:nil];
    
    addbutton = nil;
    
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
}

@end


