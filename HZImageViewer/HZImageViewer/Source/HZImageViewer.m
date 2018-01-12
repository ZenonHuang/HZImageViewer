

#import "HZImageViewer.h"
#import "HZImageViewerCell.h"

static NSString *const HZImageViewerCellIdentifier = @"HZImageViewerCellIdentifier";
//HZImageViewerCellDelegate
@interface HZImageViewer ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong)  UICollectionView           *listView;
@property (nonatomic,strong)  UICollectionViewFlowLayout *flowLayout;

@property (nonatomic,strong)  HZImageViewerCell       *selectedCell;
@property (nonatomic,strong)  UITapGestureRecognizer  *singleTapGesture;
@property (nonatomic,assign)  NSInteger                pageIndex;

@property (nonatomic,strong)  UIPageControl          *pageControl;
@property (nonatomic,assign)  CGFloat                 originPanImageViewCenterX;
@property (nonatomic,assign)  CGFloat                 panImageViewCenterX;
@end

@interface HZImageViewer ()
@property (nonatomic,copy)  NSArray *cycleList;
@end

@implementation HZImageViewer

#pragma mark - life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view .backgroundColor    = [UIColor darkTextColor];
    self.singleTapGesture         = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleTapGesture:)];
    self.singleTapGesture.delaysTouchesEnded   = YES;
    self.singleTapGesture.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:self.singleTapGesture];
    
    //    UIPanGestureRecognizer *panGesture = [[ UIPanGestureRecognizer alloc] initWithTarget:self
    //                                                                                  action:@selector(handlePanGesture:)];
    //    panGesture.delaysTouchesEnded   = YES;
    //    panGesture.cancelsTouchesInView = YES;
    //    [self.view addGestureRecognizer:panGesture];
    
    [self.view addSubview:self.listView];
    if (self.dataList.count>1) {
        [self.view addSubview:self.pageControl];
        self.pageControl.currentPage = self.pageIndex;
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.listView reloadData];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.listView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setPageIndexOffSet];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)dealloc{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        return;
    }
    // iOS8.x
    _listView.dataSource = nil;
    _listView.delegate   = nil;
}
#pragma mark - private

- (void)setPageIndexOffSet{
    CGFloat  screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat  newOffSetX  = screenWidth*(CGFloat)self.pageIndex;
    CGFloat  totalSpaceX = 20 * (CGFloat)self.pageIndex;
    CGPoint  newOffSet   = CGPointMake(newOffSetX+totalSpaceX, 0);
    [self.listView setContentOffset:newOffSet animated:NO];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    //    [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            CGPoint point = [sender locationInView:self.listView];
            NSIndexPath *indexPath = [self.listView indexPathForItemAtPoint:point];
            self.selectedCell =(HZImageViewerCell *)[self.listView cellForItemAtIndexPath:indexPath];
            
            self.originPanImageViewCenterX = self.selectedCell.imageView.center.y;
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            break;
        }
        case UIGestureRecognizerStateChanged:{
            
            CGPoint  translation = [sender translationInView:self.view];
            self.panImageViewCenterX = self.selectedCell.imageView.frame.origin.y + translation.y;
            
            CGPoint oldCenter =  self.selectedCell.imageView.center;
            self.selectedCell.imageView.center = CGPointMake(oldCenter.x, self.panImageViewCenterX);
            
            [sender setTranslation:CGPointZero inView:self.view];
            
            CGFloat vertivalMovement = self.originPanImageViewCenterX - self.panImageViewCenterX;
            float verticalPercent = fabs(vertivalMovement / self.view.frame.size.height);
            self.view.alpha = 1 - verticalPercent;
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:{
            float velocityY = fabs([sender velocityInView:self.view].y);
            BOOL  isScrollUp = (self.originPanImageViewCenterX - self.panImageViewCenterX) > 0;
            
            if (velocityY > 800) {
                self.view.userInteractionEnabled = NO;
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.view.alpha = 0;
                    CGFloat height = self.view.frame.size.height;
                    CGFloat y      = isScrollUp ? -height : height;
                    CGPoint oldOrigin = self.selectedCell.frame.origin;
                    CGSize  oldSize   = self.selectedCell.frame.size;
                    self.selectedCell.frame = (CGRect){
                        .size = oldSize,
                        .origin =CGPointMake(oldOrigin.x,y)
                    };
                }];
            } else {
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.view.alpha = 1;
                    
                    CGPoint oldCenter =  self.selectedCell.imageView.center;
                    self.selectedCell.imageView.center = CGPointMake(oldCenter.x,self.originPanImageViewCenterX);
                }];
                
            }
            break;
        }
        default:
            break;
    }
    
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat contentOffSetX = scrollView.contentOffset.x;
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    NSInteger newPageIndex = (int)round(contentOffSetX / scrollViewWidth);
    
    if (self.pageIndex == newPageIndex ){
        return;
    }
    
    
    self.pageIndex = newPageIndex% (self.dataList.count);
    self.pageControl.currentPage = newPageIndex% (self.dataList.count);
    
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    

    
}




#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (![cell isKindOfClass:[HZImageViewerCell class]]) {
        return;
    }
    
    HZImageViewerCell *displayCell =(HZImageViewerCell *) cell;
    [displayCell.scrollView setZoomScale:1 animated:NO];
    
    [self.singleTapGesture requireGestureRecognizerToFail:displayCell.doubleTapGesture];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.isCycle) {
          return self.dataList.count * 100;
    }
    
    return self.dataList.count;
  
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HZImageViewerCell *cell = [self.listView dequeueReusableCellWithReuseIdentifier:HZImageViewerCellIdentifier
                                                                       forIndexPath:indexPath];
    [cell resetImageView];
   
    
    if (self.isCycle) {
        
        NSInteger i = indexPath.row % (self.dataList.count);
         [cell configureImage:self.dataList[i]];

    }else{
        [cell configureImage:self.dataList[indexPath.row]];
    }
    
//    cell.delegate = self;
    
    return cell;
    
}
#pragma mark - UICollectionViewLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return     [UIScreen mainScreen].bounds.size;
}

#pragma mark - WFImageListViewerCellDelegate
- (void)singleTapImageView{
    //    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - getter
- (UICollectionView *)listView{
    if (!_listView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        _listView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, frame.size.width+20, frame.size.height)
                                       collectionViewLayout:self.flowLayout];
        
        [_listView registerClass:[HZImageViewerCell class]
      forCellWithReuseIdentifier:HZImageViewerCellIdentifier];
        
        _listView.delegate = self;
        _listView.dataSource = self;
        
        _listView.pagingEnabled = YES;
        _listView.backgroundColor = [UIColor clearColor];
        
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.showsVerticalScrollIndicator   = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 11.0, *)) {
            _listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
    }
    return _listView;
}

-(UICollectionViewFlowLayout *)flowLayout{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _flowLayout.sectionInset = UIEdgeInsetsMake(0,10, 0, 10);
        _flowLayout.minimumLineSpacing = 20;
        _flowLayout.minimumInteritemSpacing = 0;
    }
    return _flowLayout;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake( 0, screenSize.height - 30,  screenSize.width, 10)];
        _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPage   = self.pageIndex;
        _pageControl.numberOfPages = self.dataList.count;
    }
    
    return _pageControl;
    
}

@end
