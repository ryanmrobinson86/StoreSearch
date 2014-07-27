//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by Ryan Robinson on 6/28/14.
//  Copyright (c) 2014 RyanRobinson. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "SearchResultCell.h"
#import "SearchResult.h"

@implementation SearchResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
  selectedView.backgroundColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:0.5f];
  self.selectedBackgroundView = selectedView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
  [super prepareForReuse];
  [self.artworkImageView cancelImageRequestOperation];
  self.nameLabel.text = nil;
  self.artistNameLabel.text = nil;
}

- (void)configureForSearchResult:(SearchResult *)searchResult
{
  self.nameLabel.text = searchResult.name;
  
  NSString *artistName = searchResult.artistName;
  if (artistName == nil) {
    artistName = @"Unknown";
  }
  
  NSString *kind = [searchResult kindForDisplay];
  self.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
  
  [self.artworkImageView setImageWithURL:[NSURL URLWithString:searchResult.artworkURL60] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}

@end
