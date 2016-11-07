//
//  Swing.h
//  MetronomeObj
//
//  Created by AbbyLai on 2016/10/31.
//  Copyright © 2016年 AbbyLai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SwingAnimation : NSObject
+ (void)startSwing:(float)time view:(UIView *)targetView;
+ (void)stopSwingWithView:(UIView *)targetView;
@end
