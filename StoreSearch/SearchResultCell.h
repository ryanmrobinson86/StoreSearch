//
//  SearchResultCell.h
//  StoreSearch
//
//  Created by Ryan Robinson on 6/28/14.
//  Copyright (c) 2014 RyanRobinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

@interface SearchResultCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *artworkImageView;

- (void)configureForSearchResult:(SearchResult *)searchResult;

@end
