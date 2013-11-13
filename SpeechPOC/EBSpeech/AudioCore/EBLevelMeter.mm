//
//  LevelMeter.m
//  EBSpeech
//
//  Created by Lineker_ on 2013-07-15.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import "EBLevelMeter.h"
#import "CAStreamBasicDescription.h"

@implementation EBLevelMeter


- (id)init {
	if (self = [super init]) {
		_refreshHz = 1. / 30.;
		
		_channelNumbers = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
		_chan_lvls = (AudioQueueLevelMeterState*)malloc(sizeof(AudioQueueLevelMeterState) * [_channelNumbers count]);
		_meterTable = new MeterTable(kMinDBvalue);
	}
	return self;
}

-(void) setAudioQueue:(AudioQueueRef) v {
    _totalSilenceTime = 0;
    if (_silenceTimer) [_silenceTimer invalidate];
    
    if ((_aq == NULL) && (v != NULL))
	{
		if (_updateTimer) [_updateTimer invalidate];
		
		_updateTimer = [NSTimer
						scheduledTimerWithTimeInterval:_refreshHz
						target:self
						selector:@selector(_refresh)
						userInfo:nil
						repeats:YES
						];
	} else if ((_aq != NULL) && (v == NULL)) {
		_peakFalloffLastFire = CFAbsoluteTimeGetCurrent();
	}
    
    _aq = v;
    
    if (_aq)
	{
		try {
			UInt32 val = 1;
			XThrowIfError(AudioQueueSetProperty(_aq, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32)), "couldn't enable metering");
			
			// now check the number of channels in the new queue, we will need to reallocate if this has changed
			CAStreamBasicDescription queueFormat;
			UInt32 data_sz = sizeof(queueFormat);
			XThrowIfError(AudioQueueGetProperty(_aq, kAudioQueueProperty_StreamDescription, &queueFormat, &data_sz), "couldn't get stream description");
            
			if (queueFormat.NumberChannels() != [_channelNumbers count])
			{
				NSArray *chan_array;
				if (queueFormat.NumberChannels() < 2)
					chan_array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
				else
					chan_array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], nil];
                
				[self setChannelNumbers:chan_array];
				chan_array = nil;
				
				_chan_lvls = (AudioQueueLevelMeterState*)realloc(_chan_lvls, queueFormat.NumberChannels() * sizeof(AudioQueueLevelMeterState));
			}
		}
		catch (CAXException e) {
			char buf[256];
			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		}
	} else {
		/*for (LevelMeter *thisMeter in _subLevelMeters) {
			[thisMeter setNeedsDisplay];
		}*/
        NSLog(@"_aq is NULL!!!!");
	}
}

- (float)refreshHz { return _refreshHz; }
- (void)setRefreshHz:(float)v
{
	_refreshHz = v;
	if (_updateTimer)
	{
		[_updateTimer invalidate];
		_updateTimer = [NSTimer
						scheduledTimerWithTimeInterval:_refreshHz
						target:self
						selector:@selector(_refresh)
						userInfo:nil
						repeats:YES
						];
	}
}

- (void)_refresh
{
	BOOL success = NO;
    
	// if we have no queue, but still have levels, gradually bring them down
	if (_aq == NULL)
	{
        NSLog(@"_aq IS NULL 2");
		float maxLvl = -1.;
		CFAbsoluteTime thisFire = CFAbsoluteTimeGetCurrent();
		// calculate how much time passed since the last draw
		CFAbsoluteTime timePassed = thisFire - _peakFalloffLastFire;
		// stop the timer when the last level has hit 0
		if (maxLvl <= 0.)
		{
			[_updateTimer invalidate];
			_updateTimer = nil;
		}
		
		_peakFalloffLastFire = thisFire;
		success = YES;
	} else {
		
		UInt32 data_sz = sizeof(AudioQueueLevelMeterState) * [_channelNumbers count];
		OSErr status = AudioQueueGetProperty(_aq, kAudioQueueProperty_CurrentLevelMeterDB, _chan_lvls, &data_sz);
		if (status != noErr) goto bail;
        
		for (int i=0; i<[_channelNumbers count]; i++)
		{
			NSInteger channelIdx = [(NSNumber *)[_channelNumbers objectAtIndex:i] intValue];
			//LevelMeter *channelView = [_subLevelMeters objectAtIndex:channelIdx];
			
			if (channelIdx >= [_channelNumbers count]) goto bail;
			if (channelIdx > 127) goto bail;
			
			if (_chan_lvls)
			{
				float chanlevel = _meterTable->ValueAt((float)(_chan_lvls[channelIdx].mAveragePower));
				float peaklevel = _meterTable->ValueAt((float)(_chan_lvls[channelIdx].mPeakPower));
                
                NSLog(@"chanlevel : %f", chanlevel);
                //INCREASE this number to make more sensitive to noise
                if (chanlevel <  0.07 && [_channelNumbers count] > 0) {
                    
                    CFAbsoluteTime thisFire = CFAbsoluteTimeGetCurrent();
                    // calculate how much time passed since the last draw
                    CFAbsoluteTime timePassed = thisFire - _peakFalloffLastFire;
                    
                    NSLog(@"thisFire : %f   \n timePassed : %f", thisFire, timePassed);
                    
                    _peakFalloffLastFire = thisFire;
                    
                    if (_silenceTimer == nil && timePassed != thisFire) {
                        if(timePassed < 1) {
                            _totalSilenceTime = _totalSilenceTime + timePassed;
                             NSLog(@"_totalSilenceTime : %f ", _totalSilenceTime);
                        }
                        
                        _silenceTimer = [NSTimer
                                         scheduledTimerWithTimeInterval:1
                                         target:self
                                         selector:@selector(inSilence)
                                         userInfo:nil
                                         repeats:YES
                                         ];
                    }
                    
                    //set timer
                    
                   /* CFAbsoluteTime thisFire = CFAbsoluteTimeGetCurrent();
                    // calculate how much time passed since the last draw
                    CFAbsoluteTime timePassed = thisFire - _peakFalloffLastFire;
                    
                    NSLog(@"TIME : %f", timePassed);
                    
                    _peakFalloffLastFire = thisFire;
                    
                    _totalSilenceTime = _totalSilenceTime + [[NSString stringWithFormat:@"%f",timePassed] floatValue];
                    
                    if(_totalSilenceTime >= 3){
                        NSLog(@"IS IN SILENCE : %f", _totalSilenceTime);
                    }*/
                }
                else {
                    //invalidate timer
                    [_silenceTimer invalidate];
                    _silenceTimer = nil;
                    _totalSilenceTime = 0;
                }
                
                //NSLog(@"level : %f, peak : %f", chanlevel, peaklevel);
                //if(_delegate) {
                //    [_delegate silenceDelegate:_delegate hasNewAvgLevel:chanlevel];
                //}
				success = YES;
			}
			
		}
	}
	
bail:
	
	if (!success)
	{
		printf("ERROR: metering failed\n");
	}
}

- (void) inSilence
{
    [_silenceTimer invalidate];
    [_delegate silenceDelegate:_delegate hasNewAvgLevel:nil];
}

@end
