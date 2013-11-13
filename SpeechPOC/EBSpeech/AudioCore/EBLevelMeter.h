//
//  LevelMeter.h
//  EBSpeech
//
//  Created by Lineker_ on 2013-07-15.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#include "MeterTable.h"
#import "CAXException.h"
#import "EBAudioHandler.h"

#define kPeakFalloffPerSec	.7
#define kLevelFalloffPerSec .8
#define kMinDBvalue -80.0

@interface EBLevelMeter : NSObject {
    AudioQueueRef				_aq;
	AudioQueueLevelMeterState	*_chan_lvls;
	NSArray						*_channelNumbers;
	NSArray						*_subLevelMeters;
	MeterTable					*_meterTable;
	NSTimer						*_updateTimer;
    NSTimer						*_silenceTimer;
	float						_refreshHz;
    CFAbsoluteTime				_peakFalloffLastFire;
    int                         _counterStop;
    EBAudioHandler              *_delegate;
    float                       _totalSilenceTime;
}

@property				AudioQueueRef aq; // The AudioQueue object
@property				float refreshHz; // How many times per second to redraw
@property (retain)		NSArray *channelNumbers; // Array of NSNumber objects: The indices of the channels to display in this meter
@property (retain) EBAudioHandler *delegate;
// The current level, from 0 - 1
@property	float level;
@property               float totalSilenceTime;
-(void) setAudioQueue:(AudioQueueRef) myaq;

@end
