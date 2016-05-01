//
//  LikeButton.m
//  InShorts
//
//  Created by Saalis Umer on 4/28/16.
//  Copyright © 2016 Saalis Umer. All rights reserved.
//

#import "LikeButton.h"
@interface LikeButton()
@property (nonatomic, strong) CAShapeLayer * imageShape;
@property (nonatomic, strong) CAShapeLayer * circleShape;
@property (nonatomic, strong) CAShapeLayer * circleMask;
@property (nonatomic, strong) NSMutableArray * lines;
@property (nonatomic, strong) CAKeyframeAnimation * circleTransform;
@property (nonatomic, strong) CAKeyframeAnimation * circleMaskTransform;
@property (nonatomic, strong) CAKeyframeAnimation * lineStrokeStart;
@property (nonatomic, strong) CAKeyframeAnimation * lineStrokeEnd;
@property (nonatomic, strong) CAKeyframeAnimation * lineOpacity;
@property (nonatomic, strong) CAKeyframeAnimation * imageTransform;
@property (nonatomic, strong) CAKeyframeAnimation * imageTransformDislike;


@end


@implementation LikeButton

-(void)setImage:(UIImage *)image
{
    _image = image;
    [self createLayersWithImage:image];
    
}

-(void)setImageColorOn:(UIColor *)imageColorOn
{
    _imageColorOn = imageColorOn;
    if (self.buttonSelected) {
        _imageShape.fillColor = _imageColorOn.CGColor;
    }
}

-(void)setImageColorOff:(UIColor *)imageColorOff
{
    _imageColorOff = imageColorOff;
    if(!self.buttonSelected)
        _imageShape.fillColor = _imageColorOff.CGColor;
}

-(void)setCircleColor:(UIColor *)circleColor
{
    _circleColor = circleColor;
    _circleShape.fillColor = circleColor.CGColor;
}

-(void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    for (CAShapeLayer * line in _lines) {
        line.strokeColor = _lineColor.CGColor;
    }
}

-(void)setDuration:(double)duration
{
    _duration = duration;
    _circleTransform.duration = 0.333 * duration; // 0.0333 * 10
    _circleMaskTransform.duration = 0.333 * duration; // 0.0333 * 10
    _lineStrokeStart.duration = 0.6 * duration; //0.0333 * 18
    _lineStrokeEnd.duration = 0.6 * duration; //0.0333 * 18
    _lineOpacity.duration = 1.0 * duration; //0.0333 * 30
    _imageTransform.duration = 1.0 * duration; //0.0333 * 30
    _imageTransformDislike.duration = 0.5 * duration;
}

-(void)setButtonSelected:(BOOL)selected
{
    if(self.buttonSelected != selected)
    {
        _buttonSelected = selected;
        if (selected) {
            _imageShape.fillColor = _imageColorOn.CGColor;
        }
        else
        {
            [self deselect];
        }
        
    }
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame andImage:[[UIImage alloc]init]];
    if (self) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        self.image = image;
        [self createLayersWithImage:image];
        [self addTargets];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
        [self createLayersWithImage:[[UIImage alloc]init]];
        [self addTargets];
    }
    return self;
}

-(void)initialize
{
    _circleTransform = [CAKeyframeAnimation animationWithKeyPath: @"transform"];
    _circleMaskTransform = [CAKeyframeAnimation animationWithKeyPath: @"transform"];
    _lineStrokeStart = [CAKeyframeAnimation animationWithKeyPath: @"strokeStart"];
    _lineStrokeEnd = [CAKeyframeAnimation animationWithKeyPath: @"strokeEnd"];
    _lineOpacity = [CAKeyframeAnimation animationWithKeyPath: @"opacity"];
    _imageTransform = [CAKeyframeAnimation animationWithKeyPath: @"transform"];
    _imageTransformDislike = [CAKeyframeAnimation animationWithKeyPath: @"transform"];
}

-(void)createLayersWithImage:(UIImage*)image
{
    self.layer.sublayers = nil;
    CGRect imageFrame = CGRectMake(self.frame.size.width/2 - image.size.width/2, self.frame.size.height/2 - image.size.height/2, image.size.width, image.size.height);
    CGPoint imgCenterPoint = CGPointMake(CGRectGetMidX(imageFrame), CGRectGetMidY(imageFrame));
    CGRect lineFrame = CGRectMake(imageFrame.origin.x - imageFrame.size.width/4, imageFrame.origin.y - imageFrame.size.height/4, imageFrame.size.width*1.5, imageFrame.size.height*1.5);
    
    
    //===============
    // circle layer
    //===============
    _circleShape = [[CAShapeLayer alloc]init];
    _circleShape.bounds = imageFrame;
    _circleShape.position = imgCenterPoint;
    _circleShape.path = [UIBezierPath bezierPathWithOvalInRect:imageFrame].CGPath;
    _circleShape.fillColor = _circleColor.CGColor;
    _circleShape.transform = CATransform3DMakeScale(0.0, 0.0, 1.0);
    [self.layer addSublayer:_circleShape];
    
    _circleMask = [[CAShapeLayer alloc]init];
    _circleMask.bounds = imageFrame;
    _circleMask.position = imgCenterPoint;
    _circleMask.fillRule = kCAFillRuleEvenOdd;
    _circleShape.mask = _circleMask;
    
    UIBezierPath* maskPath = [UIBezierPath bezierPathWithRect:imageFrame];
    [maskPath addArcWithCenter:imgCenterPoint radius:0.1 startAngle:0.0 endAngle:M_PI*2.0 clockwise:true];
    _circleMask.path = maskPath.CGPath;
    
    
    //===============
    // line layer
    //===============
    _lines = [NSMutableArray array];
    for (int i = 0 ; i< 7; i++) {
        CAShapeLayer * line = [CAShapeLayer layer];
        line.bounds = lineFrame;
        line.position = imgCenterPoint;
        line.masksToBounds = true;
        [line setActions:@{@"strokeStart": [NSNull null], @"strokeEnd": [NSNull null]}];
        line.strokeColor = _lineColor.CGColor;
        line.lineWidth = 1.25;
        line.miterLimit = 1.25;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, CGRectGetMidX(lineFrame), CGRectGetMidY(lineFrame));
        CGPathAddLineToPoint(path, nil, lineFrame.origin.x + lineFrame.size.width / 2, lineFrame.origin.y);
        
        line.path = path;
        line.lineCap = kCALineCapRound;
        line.lineJoin = kCALineJoinRound;
        line.strokeStart = 0.0;
        line.strokeEnd = 0.0;
        line.opacity = 0.0;
        line.transform = CATransform3DMakeRotation(M_PI / 7 * (i * 2 + 1), 0.0, 0.0, 1.0);
        [self.layer addSublayer:line];
        [_lines addObject:line];
    }
    
    
    //===============
    // image layer
    //===============
    _imageShape = [CAShapeLayer layer];
    _imageShape.bounds = imageFrame;
    _imageShape.position = imgCenterPoint;
    _imageShape.path = [UIBezierPath bezierPathWithRect:imageFrame ].CGPath;
    _imageShape.fillColor = _imageColorOff.CGColor;
    _imageShape.actions = @{@"fillColor": [NSNull null]};
    [self.layer addSublayer:_imageShape];
    
    _imageShape.mask = [CALayer layer];
    _imageShape.mask.contents = (__bridge id _Nullable)(image.CGImage);
    _imageShape.mask.bounds = imageFrame;
    _imageShape.mask.position = imgCenterPoint;
    
    
    //==============================
    // circle transform animation
    //==============================
    _circleTransform.duration = 0.333; // 0.0333 * 10
    _circleTransform.values = @[
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0,  0.0,  1.0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5,  0.5,  1.0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0,  1.0,  1.0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2,  1.2,  1.0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3,  1.3,  1.0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.37, 1.37, 1.0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.4,  1.4,  1.0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.4,  1.4,  1.0)]
                              ];
    _circleTransform.keyTimes = @[
                                @(0.0),    //  0/10
                                @(0.1),    //  1/10
                                @(0.2),    //  2/10
                                @(0.3),    //  3/10
                                @(0.4),    //  4/10
                                @(0.5),    //  5/10
                                @(0.6),    //  6/10
                                @(1.0)     // 10/10
                                ];
    
    _circleMaskTransform.duration = 0.333; // 0.0333 * 10
    _circleMaskTransform.values = @[
                                   [NSValue valueWithCATransform3D:CATransform3DIdentity],
                                   [NSValue valueWithCATransform3D:CATransform3DIdentity],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(imageFrame.size.width * 1.25,  imageFrame.size.height * 1.25,  1.0)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(imageFrame.size.width * 2.688, imageFrame.size.height * 2.688, 1.0)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(imageFrame.size.width * 3.923, imageFrame.size.height * 3.923, 1.0)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(imageFrame.size.width * 4.375, imageFrame.size.height * 4.375, 1.0)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(imageFrame.size.width * 4.731, imageFrame.size.height * 4.731, 1.0)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(imageFrame.size.width * 5.0,   imageFrame.size.height * 5.0,   1.0)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(imageFrame.size.width * 5.0,   imageFrame.size.height * 5.0,   1.0)]
                                   ];
    _circleMaskTransform.keyTimes = @[
                                    @(0.0),    //  0/10
                                    @(0.2),    //  2/10
                                    @(0.3),    //  3/10
                                    @(0.4),    //  4/10
                                    @(0.5),    //  5/10
                                    @(0.6),    //  6/10
                                    @(0.7),    //  7/10
                                    @(0.9),    //  9/10
                                    @(1.0)     // 10/10
                                    ];

    
    //==============================
    // line stroke animation
    //==============================
    _lineStrokeStart.duration = 0.6; //0.0333 * 18
    _lineStrokeStart.values = @[
                              @(0.0),    //  0/18
                              @(0.0),    //  1/18
                              @(0.18),   //  2/18
                              @(0.2),    //  3/18
                              @(0.26),   //  4/18
                              @(0.32),   //  5/18
                              @(0.4),    //  6/18
                              @(0.6),    //  7/18
                              @(0.71),   //  8/18
                              @(0.89),   // 17/18
                              @(0.92)    // 18/18
                              ];
    _lineStrokeStart.keyTimes = @[
                                @(0.0),    //  0/18
                                @(0.056),  //  1/18
                                @(0.111),  //  2/18
                                @(0.167),  //  3/18
                                @(0.222),  //  4/18
                                @(0.278),  //  5/18
                                @(0.333),  //  6/18
                                @(0.389),  //  7/18
                                @(0.444),  //  8/18
                                @(0.944),  // 17/18
                                @(1.0)    // 18/18
                                ];
    
    _lineStrokeEnd.duration = 0.6; //0.0333 * 18
    _lineStrokeEnd.values = @[
                            @(0.0),    //  0/18
                            @(0.0),    //  1/18
                            @(0.32),   //  2/18
                            @(0.48),   //  3/18
                            @(0.64),   //  4/18
                            @(0.68),   //  5/18
                            @(0.92),   // 17/18
                            @(0.92)    // 18/18
                            ];
    _lineStrokeEnd.keyTimes = @[
                              @(0.0),    //  0/18
                              @(0.056),  //  1/18
                              @(0.111),  //  2/18
                              @(0.167),  //  3/18
                              @(0.222),  //  4/18
                              @(0.278),  //  5/18
                              @(0.944),  // 17/18
                              @(1.0)    // 18/18
                              ];
    
    _lineOpacity.duration = 1.0; //0.0333 * 30
    _lineOpacity.values = @[
                          @(1.0),    //  0/30
                          @(1.0),    // 12/30
                          @(0.0)     // 17/30
                          ];
    _lineOpacity.keyTimes = @[
                            @(0.0),    //  0/30
                            @(0.4),    // 12/30
                            @(0.567)   // 17/30
                            ];
    
    //==============================
    // image transform animation
    //==============================
    _imageTransform.duration = 1.0; //0.0333 * 30
    _imageTransform.values = @[
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0,   0.0,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0,   0.0,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2,   1.2,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.25,  1.25,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2,   1.2,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9,   0.9,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.875, 0.875, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.875, 0.875, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9,   0.9,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.013, 1.013, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.025, 1.025, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.013, 1.013, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.96,  0.96,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95,  0.95,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.96,  0.96,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.99,  0.99,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DIdentity]];
                               
    _imageTransform.keyTimes = @[
                               @(0.0),    //  0/30
                               @(0.1),    //  3/30
                               @(0.3),    //  9/30
                               @(0.333),  // 10/30
                               @(0.367),  // 11/30
                               @(0.467),  // 14/30
                               @(0.5),    // 15/30
                               @(0.533),  // 16/30
                               @(0.567),  // 17/30
                               @(0.667),  // 20/30
                               @(0.7),    // 21/30
                               @(0.733),  // 22/30
                               @(0.833),  // 25/30
                               @(0.867),  // 26/30
                               @(0.9),    // 27/30
                               @(0.967),  // 29/30
                               @(1.0)     // 30/30
                               ];
    
    //==============================
    // image transform dislike animation
    //==============================
    _imageTransformDislike.duration = 1.0*0.5; //0.0333 * 30
    _imageTransformDislike.values = @[
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0,   1.0,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0,   1.0,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3,   1.3,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.35,  1.35,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.4,   1.4,   1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.35,  1.35,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.25,  1.25,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.20,  1.20,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.10,  1.10,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.013, 1.013, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.025, 1.025, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.013, 1.013, 1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.96,  0.96,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95,  0.95,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.96,  0.96,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.99,  0.99,  1.0)],
                               [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    
    _imageTransformDislike.keyTimes = @[
                                 @(0.0),    //  0/30
                                 @(0.1),    //  3/30
                                 @(0.3),    //  9/30
                                 @(0.333),  // 10/30
                                 @(0.367),  // 11/30
                                 @(0.467),  // 14/30
                                 @(0.5),    // 15/30
                                 @(0.533),  // 16/30
                                 @(0.567),  // 17/30
                                 @(0.667),  // 20/30
                                 @(0.7),    // 21/30
                                 @(0.733),  // 22/30
                                 @(0.833),  // 25/30
                                 @(0.867),  // 26/30
                                 @(0.9),    // 27/30
                                 @(0.967),  // 29/30
                                 @(1.0)     // 30/30
                                 ];


}

-(void)addTargets
{
    [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [self addTarget:self action:@selector(touchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
}

-(void)touchDown:(LikeButton*)sender
{
    self.layer.opacity = 0.4;
}

-(void)touchUpInside:(LikeButton*)sender
{
    self.layer.opacity = 1.0;
}

-(void)touchDragExit:(LikeButton*)sender
{
    self.layer.opacity = 1.0;
}

-(void)touchDragEnter:(LikeButton*)sender
{
    self.layer.opacity = 0.4;
}

-(void)touchCancel:(LikeButton*)sender
{
    self.layer.opacity = 1.0;
}

-(void)select
{
    [self selectWithAnimation:true];
}

-(void)selectWithAnimation:(BOOL) animate {
    self.buttonSelected = true;
    _imageShape.fillColor = _imageColorOn.CGColor;
    
    [self removeAllAnimations];
    
    if (animate) {
        [CATransaction begin];
        [_circleShape addAnimation:_circleTransform forKey:@"transform" ];
        [_circleMask addAnimation:_circleTransform forKey:@"transform"];
        [_imageShape addAnimation:_imageTransform forKey:@"transform"];
        
        for (int i = 0; i< 7; i++) {
            [_lines[i] addAnimation:_lineStrokeStart forKey:@"strokeStart"];
            [_lines[i] addAnimation:_lineStrokeEnd forKey:@"strokeEnd"];
            [_lines[i] addAnimation:_lineOpacity forKey:@"opacity"];
        }
        
        [CATransaction commit];
    }
}


-(void)deselect
{
    self.buttonSelected = false;
    _imageShape.fillColor = _imageColorOff.CGColor;
    
    [self removeAllAnimations];
    
    [CATransaction begin];

    [_imageShape addAnimation:_imageTransformDislike forKey:@"transform01"];
    
    [CATransaction commit];

}

-(void)removeAllAnimations
{
    // remove all animations
    [_circleShape removeAllAnimations];
    [_circleMask removeAllAnimations];
    [_imageShape removeAllAnimations];
    [_lines[0] removeAllAnimations];
    [_lines[1] removeAllAnimations];
    [_lines[2] removeAllAnimations];
    [_lines[3] removeAllAnimations];
    [_lines[4] removeAllAnimations];
    [_lines[5] removeAllAnimations];
    [_lines[6] removeAllAnimations];
}


@end
