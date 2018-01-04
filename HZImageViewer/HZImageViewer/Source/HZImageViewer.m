

#import "HZImageViewer.h"
#import "HZImageViewerCell.h"

static NSString *const HZImageViewerCellIdentifier = @"HZImageViewerCellIdentifier";

@interface HZImageViewer ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong)  UICollectionView *listView;
@property (nonatomic,strong)  UICollectionViewFlowLayout *flowLayout;

@property (nonatomic,strong)  HZImageViewerCell *selectedCell;
@property (nonatomic,strong)  UITapGestureRecognizer *singleTapGesture;
@property (nonatomic,assign)  NSInteger pageIndex;
@property (nonatomic,assign)  CGFloat originPanImageViewCenterX;
@property (nonatomic,assign)  CGFloat panImageViewCenterX;
@end

@implementation HZImageViewer
#pragma mark - life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view .backgroundColor = [UIColor orangeColor];
    self.singleTapGesture = [[UITapGestureRecognizer alloc] init];
    self.singleTapGesture.delaysTouchesEnded=YES;
    self.singleTapGesture.cancelsTouchesInView = YES;
    
//    UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc] initWithTarget:self
//                                                                               action:@selector(handlePanGesture:)];
//    panGesture.delaysTouchesEnded=YES;
//    panGesture.cancelsTouchesInView = YES;
//    [self.view addGestureRecognizer:panGesture];
    
    [self.view addSubview:self.listView];
    
    [self.listView reloadData];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.listView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self firstSetImageDetail];
}


#pragma mark - private

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender{
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint point = [sender locationInView:self.listView];
            NSIndexPath *indexPath = [self.listView indexPathForItemAtPoint:point];
            
            UICollectionViewCell *cell = [self.listView cellForItemAtIndexPath:indexPath];
            self.selectedCell = (HZImageViewerCell *)cell;
            self.originPanImageViewCenterX = self.selectedCell.imageView.center.y;
            [self dismissViewControllerAnimated:YES completion:nil];
            
            break;
        }
    case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [sender translationInView:self.view];
            self.panImageViewCenterX = self.selectedCell.imageView.center.y + translation.y;
            
            CGPoint oldCenter = self.selectedCell.imageView.center;
            CGPoint newCenter = CGPointMake(oldCenter.x,  self.panImageViewCenterX );
            self.selectedCell.imageView.center = newCenter;

            [sender setTranslation:CGPointZero inView:self.view];

            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {

            double velocityY  = fabs([sender velocityInView:self.view].y);
            BOOL isScrollUp = (self.originPanImageViewCenterX - self.panImageViewCenterX) > 0;

            if (velocityY > 800) {
                self.view.userInteractionEnabled = NO;

                [UIView animateWithDuration:0.3 animations:^{
                    CGFloat height = self.view.frame.size.height;
                    CGFloat y = isScrollUp ? -height : height;
                    
                    CGSize size = self.selectedCell.frame.size;
                    CGPoint origin =  self.selectedCell.frame.origin;
                    self.selectedCell.frame = (CGRect){
                        .size   = size,
                        .origin = CGPointMake(origin.x, y),
                    };
                }];

            } else {

                [UIView animateWithDuration:0.3 animations:^{
                    
                   CGPoint oldCenter = self.selectedCell.imageView.center;
                   CGPoint newCenter = CGPointMake(oldCenter.x, self.originPanImageViewCenterX);
                  self.selectedCell.imageView.center = newCenter;

                }];
            }
            break;
        }
        default:
            break;
    }
}

- (void)firstSetImageDetail{
    [self setPageIndexOffSet];

}

- (void)setPageIndexOffSet{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat  newOffSetX = screenWidth*(CGFloat)self.pageIndex;
    CGFloat  totalSpaceX = 20 * (CGFloat)self.pageIndex;
    CGPoint newOffSet = CGPointMake(newOffSetX+totalSpaceX, 0);
    [self.listView setContentOffset:newOffSet animated:NO];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat contentOffSetX = scrollView.contentOffset.x;
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    NSInteger newPageIndex = (int)round(contentOffSetX / scrollViewWidth);
    
    if (self.pageIndex != newPageIndex ){
//        setImageDetailText(newPageIndex)
        self.pageIndex = newPageIndex;
    }
    
    
//    CGFloat x =  newPageIndex==0? 0 : newPageIndex*(scrollViewWidth+20);
//    [scrollView setContentOffset:CGPointMake(x, scrollView.contentOffset.y) animated:YES];
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
    
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   HZImageViewerCell *cell = [self.listView dequeueReusableCellWithReuseIdentifier:HZImageViewerCellIdentifier
                                                                           forIndexPath:indexPath];
    [cell resetImageView];
    [cell configureImage:self.dataList[indexPath.row]];
    return cell;
}
#pragma mark -
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return     [UIScreen mainScreen].bounds.size;
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
        if (@available(iOS 11.0, *)) {
            _listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
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
@end
