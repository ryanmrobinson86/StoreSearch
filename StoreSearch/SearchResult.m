//
//  SearchResult.m
//  StoreSearch
//
//  Created by Ryan Robinson on 6/28/14.
//  Copyright (c) 2014 RyanRobinson. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

- (NSComparisonResult)compareName:(SearchResult *)other
{
  return [self.name localizedStandardCompare:other.name];
}
- (NSComparisonResult)compareArtist:(SearchResult *)other
{
  return [self.artistName localizedStandardCompare:other.artistName];
}

@end
