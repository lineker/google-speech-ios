//
//  ViewController.h
//  SpeechPOC
//
//  Created by Lineker Tomazeli on 11/8/2013.
//  Copyright (c) 2013 Lineker Tomazeli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBRecognizer.h"
#import "EBVocalizer.h"
@interface ViewController : UIViewController <EBRecognizerDelegate, EBVocalizerDelegate>

@end
