

#import "HZImageViewerCell.h"

@interface HZImageViewerCell ()<UIScrollViewDelegate>


@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation HZImageViewerCell
#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handleDoubleTapGesture:)];

    self.doubleTapGesture.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:self.doubleTapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                  action:@selector(longPressGesture:)];
    [self.imageView addGestureRecognizer:longPressGesture];
    
    [self.contentView addSubview:self.scrollView];

    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.imageView.image) {
        [self.scrollView  setZoomScale:1 animated:NO];
        [self calcImageViewFrame:self.imageView.image];
    }
}

- (void)calcImageViewFrame:(UIImage *)image{
    
    
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
   
    CGFloat hRate = screenSize.height / imageHeight;
    CGFloat wRate = screenSize.width / imageWidth;
    CGFloat rate  = MIN(hRate, wRate);
    CGSize  imageViewSize = (CGSize){
        .width  = floor(imageWidth * rate),
        .height = floor(imageHeight * rate)};
    
    self.imageView.frame = (CGRect){
        .origin = CGPointZero,
        .size   = imageViewSize
    };
    self.scrollView.contentSize = imageViewSize;
    [self updateImageViewToCenter];
}


#pragma mark - public
- (void)resetImageView{
    self.imageView.image = nil;
    [self.scrollView setZoomScale:1 animated:NO];
}

- (void)configureImage:(id)image{
    if ([image isKindOfClass:[UIImage class]]) {
        [self setImage:image];
        
        return;
    }
    
    if ([image isKindOfClass:[NSString class]]) {
        [self.activityIndicatorView startAnimating];
        self.activityIndicatorView.hidden = NO;
#warning TODO image load from network
//        [self.imageView yy_setImageWithURL:(NSString *)image
//                               placeholder:[UIImage imageWithColor:[UIColor whiteColor]]
//                                 completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
//                                     self.activityIndicatorView.hidden = YES;
//                                     [self.activityIndicatorView stopAnimating];
//                                     if (!error) {
//                                         [self setImage:image];
//                                     }
//                                 }
//         ];
        return;
    }
    
    NSAssert(NO, @"非 UIImage 或 NSString 的数据");
}

#pragma mark - private

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender{
    if (self.scrollView.maximumZoomScale > self.scrollView.zoomScale ){
        
        CGPoint location =  [sender locationInView:self.imageView];
        CGRect zoomRect = (CGRect){
            .origin = location,
            .size   = CGSizeZero,
        };
        
        [self.scrollView zoomToRect:zoomRect animated:YES];
        
        [self updateImageViewToCenter];
        
    } else {
        [self.scrollView setZoomScale:1 animated:YES];
    }

}

- (void)longPressGesture:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(longPressImageView)]) {
            [self.delegate longPressImageView];
        }
    }
}

- (void)updateImageViewToCenter{

    CGSize   screenSize   = [UIScreen mainScreen].bounds.size;
    CGFloat  heightMargin = (screenSize.height - self.imageView.frame.size.height) / 2;
    CGFloat  widthMargin  = (screenSize.width - self.imageView.frame.size.width) / 2;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(MAX(heightMargin, 0), MAX(widthMargin, 0), 0, 0);
}

- (void)setImage:(UIImage *)image{
    self.imageView.image=image;
    [self calcImageViewFrame:image];
    [self.scrollView addSubview:self.imageView];
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self updateImageViewToCenter];
}


- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    
    if ([self.delegate respondsToSelector:@selector(viewerScrollViewWillBeginZooming:withView:)]) {
        [self.delegate  viewerScrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    if ([self.delegate respondsToSelector:@selector(viewerScrollViewDidEndZooming:withView:atScale:)]) {
        [self.delegate  viewerScrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

#pragma mark - getter

- (UIScrollView *)scrollView{
    if (!_scrollView) {
 
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.maximumZoomScale = 3;
        _scrollView.minimumZoomScale = 1;
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator   = false;
        _scrollView.backgroundColor  = [UIColor clearColor];
        _scrollView.delegate = self;
        
    }
    return _scrollView;
}

- (UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        CGSize   screenSize    = [UIScreen mainScreen].bounds.size;
        CGFloat  length        = 30;
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((screenSize.width- length  )/2, (screenSize.height- length  )/2,length,length)];
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _activityIndicatorView.hidden = YES;
    }
    return _activityIndicatorView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView=[[UIImageView alloc] init];
        _imageView.userInteractionEnabled= YES;
    }
    return _imageView;
}
@end

