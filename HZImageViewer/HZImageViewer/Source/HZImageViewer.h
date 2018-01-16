
#import <UIKit/UIKit.h>

@protocol HZImageViewerDelegate <NSObject>


@end


@interface HZImageViewer : UIViewController
@property (nonatomic,copy  )  NSArray          *dataList;
@property (nonatomic,assign)  NSInteger         pageIndex;
@property (nonatomic,assign)  BOOL              isCycle;
@end
