
#import <UIKit/UIKit.h>

@protocol HZImageViewerDelegate <NSObject>


@end


@interface HZImageViewer : UIViewController
@property (nonatomic,copy)    NSArray          *dataList;
@end
