//
//  EBAudioDelegate.h
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-19.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EBAudioDelegate <NSObject>

- (void)silenceDelegate:(id<EBAudioDelegate>)delegate hasNewAvgLevel:(float)level;

@end
