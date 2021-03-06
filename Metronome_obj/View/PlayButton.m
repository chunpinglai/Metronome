//
//  PlayButton.m
//  Metronome_obj
//
//  Created by AbbyLai on 2016/10/27.
//  Copyright © 2016年 AbbyLai. All rights reserved.
//

#import "PlayButton.h"
#import "MetronomeConstant.h"

@implementation PlayButton

- (id)init {
    return [self initWithStatus:PlayBtnStatus_Stop];
}

- (id)initWithStatus:(PlayBtnStatus)status {
    self = [super init];
    if(self) {
        _playStatus = status;
    }
    return self;
}

- (void)changeUI {
    if (_playStatus == PlayBtnStatus_Play) {
        [self setImage:[UIImage imageNamed:PlayButton_Play_ImageName] forState:UIControlStateNormal];
        _playStatus = PlayBtnStatus_Stop;
    }
    else {
        [self setImage:[UIImage imageNamed:PlayButton_Stop_ImageName] forState:UIControlStateNormal];
        _playStatus = PlayBtnStatus_Play;
    }
}

@end
