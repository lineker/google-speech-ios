//
//  EBSilenceProtocol.h
//  EBSpeech
//
//  Created by Lineker_ on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBRecognizer.h"

@protocol EBSilenceDelegate <NSObject>

- (void)recognizer:(id<EBRecognizer>)recognizer didFinishWithSilence:(BOOL)results;

@end
