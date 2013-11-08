//
//  EBAudioHandler.h
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-15.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBAudioDelegate.h"
#import "EBSilenceDelegate.h"

@interface EBAudioHandler : NSObject <EBAudioDelegate>

- (void) startRecord;
- (void) stopRecord;
- (void)playFilename:(NSString *)filename fromResource:(BOOL)fromRes;

- (BOOL) convertToFlac;
+ (id)sharedInstance;

@property (nonatomic,strong) id <EBSilenceDelegate> delegate;
@end
