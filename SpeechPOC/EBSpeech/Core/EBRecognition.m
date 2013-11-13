//
//  EBRecognition.m
//  EBSpeech
//
//  Created by Lineker_ on 2013-07-16.
//  Copyright (c) 2013 eb. All rights reserved.
//

#import "EBRecognition.h"


@implementation EBRecognition

@synthesize results = _results, scores = _scores, suggestion = _suggestion, data = _data;

- (NSMutableArray *)results
{
    if (!_results){
        _results = [[NSMutableArray alloc] init];
    }
    return _results;
}

- (NSMutableArray *)scores
{
    if (!_scores){
        _scores = [[NSMutableArray alloc] init];
    }
    return _scores;
}

- (NSString *)firstResult
{
    if(self.results.count > 0)
        return self.results[0];
    else
        return nil;
}

@end
