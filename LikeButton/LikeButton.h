//
//  LikeButton.h
//  InShorts
//
//  Created by Saalis Umer on 4/28/16.
//  Copyright © 2016 Saalis Umer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikeButton : UIButton
@property (nonatomic, strong) IBInspectable UIImage* image;
@property (nonatomic, strong) IBInspectable UIColor* imageColorOn;
@property (nonatomic, strong) IBInspectable UIColor* imageColorOff;
@property (nonatomic, strong) IBInspectable UIColor* circleColor;
@property (nonatomic, strong) IBInspectable UIColor* lineColor;
@property (nonatomic, assign) IBInspectable double   duration;
@property (nonatomic, assign) BOOL buttonSelected;

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage*)image;
-(void)select;
-(void)deselect;
@end
