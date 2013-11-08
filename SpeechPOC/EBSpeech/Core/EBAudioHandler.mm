//
//  EBAudioHandler.m
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-15.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import "EBAudioHandler.h"
#import "AQPlayer.h"
#import "AQRecorder.h"
#import "EBLevelMeter.h"
#include "wav_to_flac.h"

@interface EBAudioHandler() {
        CFStringRef	 recordFilePath;
    }
    @property (readonly) AQPlayer       *player;
    @property (readonly) AQRecorder     *recorder;
    @property (nonatomic)  EBLevelMeter	*levelmeter;
    @property			 BOOL			playbackWasInterrupted;
@end

@implementation EBAudioHandler
@synthesize player = _player, recorder = _recorder, playbackWasInterrupted = _playbackWasInterrupted, levelmeter = _levelmeter, delegate = _delegate;


//singleton instance
+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (EBLevelMeter*)levelmeter
{
    if(!_levelmeter) {
        _levelmeter = [[EBLevelMeter alloc] init];
        _levelmeter.delegate = self;
    }
    return _levelmeter;
}

- (EBAudioHandler *) init
{
    self = [super init];
    if (self){
        // Allocate our singleton instance for the recorder & player object
        _recorder = new AQRecorder();
        _player = new AQPlayer();

        OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, (__bridge void*)self);
        if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
        else
        {
            UInt32 category = kAudioSessionCategory_PlayAndRecord;
            error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
            if (error) printf("couldn't set audio category!");
            
            error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, (__bridge void*)self);
            if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
            UInt32 inputAvailable = 0;
            UInt32 size = sizeof(inputAvailable);
            
            // we do not want to allow recording if input is not available
            error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
            if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);
            
            // we also need to listen to see if input availability changes
            error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, (__bridge void*)self);
            if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
            
            error = AudioSessionSetActive(true);
            if (error) printf("AudioSessionSetActive (true) failed");
        }
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
        
        // disable the play button since we have no recording to play yet
        //btn_play.enabled = NO;
        self.playbackWasInterrupted = NO;
        //playbackWasPaused = NO;
        
        //[self registerForBackgroundNotifications];
    }
    return self;
}

char *OSTypeToStr(char *buf, OSType t)
{
	char *p = buf;
	char str[4] = {0};
    char *q = str;
	*(UInt32 *)str = CFSwapInt32(t);
	for (int i = 0; i < 4; ++i) {
		if (isprint(*q) && *q != '\\')
			*p++ = *q++;
		else {
			sprintf(p, "\\x%02x", *q++);
			p += 4;
		}
	}
	*p = '\0';
	return buf;
}

-(void)setFileDescriptionForFormat: (CAStreamBasicDescription)format withName:(NSString*)name
{
	char buf[5];
	const char *dataFormat = OSTypeToStr(buf, format.mFormatID);
	NSString* description = [[NSString alloc] initWithFormat:@"(%ld ch. %s @ %g Hz)", format.NumberChannels(), dataFormat, format.mSampleRate, nil];
	NSLog(@"setFileDescriptionForFormat : %@",description);
	description = nil;
}

- (void)startRecord
{
	if (self.recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
		[self stopRecord];
	}
	else // If we're not recording, start.
	{
		// Start the recorder
		self.recorder->StartRecord(CFSTR("recordedFile.wav"));
		
		[self setFileDescriptionForFormat:self.recorder->DataFormat() withName:@"Recorded File"];
		
		// Hook the level meter up to the Audio Queue for the recorder
		[self.levelmeter setAudioQueue:self.recorder->Queue()];
	}
}

- (void)stopRecord
{
	// Disconnect our level meter from the audio queue
	[self.levelmeter setAudioQueue: nil];
	
	self.recorder->StopRecord();
	
	// dispose the previous playback queue
	self.player->DisposeQueue(true);
    
}

- (void)playFilename:(NSString *)filename fromResource:(BOOL)fromRes
{
    NSLog(@"Started playing");
    //maybe create a new player instead of reusing?
    //if (_player) {
        //delete _player;
        _player = new AQPlayer();
        NSLog(@"done disposing");
    //}
   
    //self.player->DisposeQueue(true);

    //if(fromRes) {
    //    recordFilePath = (__bridge CFStringRef)[[NSBundle mainBundle] pathForResource: filename ofType: @""];
    //} else {
        recordFilePath = (__bridge CFStringRef)[NSTemporaryDirectory() stringByAppendingPathComponent: filename];
    //}
    
    self.player->CreateQueueForFile(recordFilePath);
    
	if (self.player->IsRunning())
	{
        [self stopPlayQueue];
	}
	else
	{
		OSStatus result = self.player->StartQueue(false);
		if (result == noErr)
            NSLog(@"playing without error");
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
        //maybe dispose player here?
	}
}

-(void)stopPlayQueue
{
	self.player->StopQueue();
	[self.levelmeter setAudioQueue:nil];
}

#pragma mark AudioSession listeners
void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
	EBAudioHandler *THIS = (__bridge EBAudioHandler*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (THIS->_recorder->IsRunning()) {
			[THIS stopRecord];
		}
		else if (THIS->_player->IsRunning()) {
			//the queue will stop itself on an interruption, we just need to update the UI
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
			THIS->_playbackWasInterrupted = YES;
		}
	}
	else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS->_playbackWasInterrupted)
	{
		// we were playing back when we were interrupted, so reset and resume now
		THIS->_player->StartQueue(true);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
		THIS->_playbackWasInterrupted = NO;
	}
}

void propListener(void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
	EBAudioHandler *THIS = (__bridge EBAudioHandler*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			/*CFStringRef oldRoute = (CFStringRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
             if (oldRoute)
             {
             printf("old route:\n");
             CFShow(oldRoute);
             }
             else
             printf("ERROR GETTING OLD AUDIO ROUTE!\n");
             
             CFStringRef newRoute;
             UInt32 size; size = sizeof(CFStringRef);
             OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
             if (error) printf("ERROR GETTING NEW AUDIO ROUTE! %d\n", error);
             else
             {
             printf("new route:\n");
             CFShow(newRoute);
             }*/
            
			if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
			{
				if (THIS->_player->IsRunning()) {
					//[THIS pausePlayQueue];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
				}
			}
            
			// stop the queue if we had a non-policy route change
			if (THIS->_recorder->IsRunning()) {
				[THIS stopRecord];
			}
		}
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32)) {
			UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
			//THIS->btn_record.enabled = (isAvailable > 0) ? YES : NO;
		}
	}
}

- (BOOL) convertToFlac
{
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [tmpDirURL URLByAppendingPathComponent:@"flacfile"];
    NSString *flacFileWithoutExtension = [fileURL path];//path to the output file
    NSLog(@"path + file without ext :  %@", flacFileWithoutExtension);
    
    NSURL *originalfileURL = [[tmpDirURL URLByAppendingPathComponent:@"recordedFile"] URLByAppendingPathExtension:@"wav"];
    NSString *waveFile = [originalfileURL path];//path to the wave input file
    NSLog(@"fileURL: %@", waveFile);
    
    int interval_seconds = 30;
    char** flac_files = (char**) malloc(sizeof(char*) * 1024);
    NSLog(@"starting flac conversion ");
    int conversionResult = convertWavToFlac([waveFile UTF8String], [flacFileWithoutExtension UTF8String], interval_seconds, flac_files);
    NSLog(@"ended flac conversion : conversionResult: %d", conversionResult);
    if(conversionResult == 0)
        return YES;
    else
        return NO;
}

- (void)silenceDelegate:(id<EBAudioDelegate>)delegate hasNewAvgLevel:(float)level {
    NSLog(@"SILENCE DETECTED...stopping recording");
    
    /*dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        [self stopRecord];
    });*/
    [self.delegate recognizer:nil didFinishWithSilence:YES];

}

@end
