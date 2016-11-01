//
//  PlayButton.h
//  Metronome_obj
//
//  Created by AbbyLai on 2016/10/27.
//  Copyright © 2016年 AbbyLai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _PlayBtnStatus {
    PlayBtnStatus_Stop,
    PlayBtnStatus_Play
} PlayBtnStatus;

@interface PlayButton : UIButton

@property (nonatomic) PlayBtnStatus playStatus;
- (void)changeUI;

@end
