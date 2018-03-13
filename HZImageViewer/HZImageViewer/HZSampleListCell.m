//
//  HZSampleListCell.m
//  HZImageViewer
//
//  Created by zz go on 2018/3/13.
//  Copyright © 2018年 zenon. All rights reserved.
//

#import "HZSampleListCell.h"

@interface HZSampleListCell ()

@property (nonatomic,strong) UIImageView  *imageView;

@end

@implementation HZSampleListCell
#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    

    [self.contentView addSubview:self.imageView];
    
    return self;
}



#pragma mark - public


- (void)configureImage:(id)image{
 
    self.imageView.image = image;

}

#pragma mark - private
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView=[[UIImageView alloc] init];
        _imageView.contentMode  =   UIViewContentModeScaleAspectFit;
        _imageView.frame = self.bounds;
    }
    return _imageView;
}
@end


