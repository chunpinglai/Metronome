//
//  MuteButton.h
//  Metronome_obj
//
//  Created by AbbyLai on 2016/10/27.
//  Copyright © 2016年 AbbyLai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _MuteBtnStatus {
    MuteBtnStatus_PlaySound,
    MuteBtnStatus_Mute
} MuteBtnStatus;

@interface MuteButton : UIButton

@property (nonatomic) MuteBtnStatus status;
- (void)changeUI;

@end


