//
//  Swing.m
//  MetronomeObj
//
//  Created by AbbyLai on 2016/10/31.
//  Copyright © 2016年 AbbyLai. All rights reserved.
//

#import "SwingAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation SwingAnimation

+ (void)startSwing:(float)time view:(UIView *)targetView {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    NSArray *values = @[@0, @0.5, @0, @(-0.5), @0];
    [animation setValues:values]; //from right, center , left
    float x = INFINITY;
    animation.repeatCount = x;
    [animation setDuration:time];
    animation.additive = true;
    [targetView.layer addAnimation:animation forKey:@"swing"];
}

+ (void)stopSwingWithView:(UIView *)targetView {
    [targetView.layer removeAllAnimations];
}

@end
