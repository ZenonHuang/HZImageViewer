

#import <UIKit/UIKit.h>

@protocol HZImageViewerCellDelegate <NSObject>

- (void)singleTapImageView;

@optional

- (void)viewerScrollViewWillBeginZooming:(UIScrollView *)scrollView
                                withView:(UIView *)view;

- (void)viewerScrollViewDidEndZooming:(UIScrollView *)scrollView
                             withView:(UIView *)view
                              atScale:(CGFloat)scale;
- (void)longPressImageView;
@end


@interface HZImageViewerCell :  UICollectionViewCell
@property (nonatomic, weak) id<HZImageViewerCellDelegate> delegate;

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIImageView  *imageView;

@property (nonatomic,strong) UITapGestureRecognizer *doubleTapGesture;

- (void)resetImageView;

///可以是 UIImage 或者 NSString
- (void)configureImage:(id)image;
@end
