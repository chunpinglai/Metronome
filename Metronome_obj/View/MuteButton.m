//
//  MuteButton.m
//  Metronome_obj
//
//  Created by AbbyLai on 2016/10/27.
//  Copyright © 2016年 AbbyLai. All rights reserved.
//

#import "MuteButton.h"

@implementation MuteButton

- (id)init {
    return [self initWithStatus:MuteBtnStatus_PlaySound];
}

- (id)initWithStatus:(MuteBtnStatus)status {
    self = [super init];
    if(self) {
        _status = status;
    }
    return self;
}

- (void)changeUI {
    if (_status == MuteBtnStatus_PlaySound) {
        [self setBackgroundImage:[UIImage imageNamed:@"sound_mute"] forState:UIControlStateNormal];
        _status = MuteBtnStatus_Mute;
    }
    else {
        [self setBackgroundImage:[UIImage imageNamed:@"sound_play"] forState:UIControlStateNormal];
        _status = MuteBtnStatus_PlaySound;
    }
}

@end
