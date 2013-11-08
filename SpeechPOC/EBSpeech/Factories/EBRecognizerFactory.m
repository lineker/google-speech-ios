//
//  EBRecognizerFactory.m
//  EBSpeech
//
//  Created by Lineker_IBM on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import "EBRecognizerFactory.h"
#import "EBGoogleRecognizer.h"

@implementation EBRecognizerFactory

+ (id <EBRecognizer>)initRecognizerWithService:(EBSpeechRecognizerService)service type:(NSString *)type detection:(EBEndOfSpeechDetection)detection language:(NSString *)language delegate:(id <EBRecognizerDelegate>)delegate;
{
    switch (service) {
        case EBGoogleRecognizerService:
            return [[EBGoogleRecognizer alloc] initWithType:type detection:detection language:language delegate:delegate];
            break;
        default:
            return nil;
    }
}

@end
