//
//  EBGoogleRecognizer.h
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBRecognizer.h"
#import "EBSilenceDelegate.h"

@interface EBGoogleRecognizer : NSObject <EBRecognizer, EBSilenceDelegate>

@end
