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

- (NSString *)kindForDisplay
{
  if ([self.kind isEqualToString:@"album"]) {
    return @"Album";
  } else if ([self.kind isEqualToString:@"audiobook"]) {
    return @"Audiobook";
  } else if ([self.kind isEqualToString:@"book"]) {
    return @"Book";
  } else if ([self.kind isEqualToString:@"ebook"]) {
    return @"E-Book";
  } else if ([self.kind isEqualToString:@"feature-movie"]) {
    return @"Movie";
  } else if ([self.kind isEqualToString:@"music-video"]) {
    return @"Music Video";
  } else if ([self.kind isEqualToString:@"podcast"]) {
    return @"Podcast";
  } else if ([self.kind isEqualToString:@"software"]) {
    return @"App";
  } else if ([self.kind isEqualToString:@"song"]) {
    return @"Song";
  } else if([self.kind isEqualToString:@"tv-episode"]) {
    return @"TV Episode";
  }
  return self.kind;
}

- (NSString *)symbolForCurrency
{
  if ([self.currency isEqualToString:@"USD"]) {
    return @"$";
  }
  return self.currency;
}

@end
