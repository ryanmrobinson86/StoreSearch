//
//  SearchViewController.m
//  StoreSearch
//
//  Created by Ryan Robinson on 6/24/14.
//  Copyright (c) 2014 RyanRobinson. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController
{
  NSMutableArray *_searchResults;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (_searchResults == nil) {
    return 0;
  } else if ([_searchResults count]) {
    return [_searchResults count];
  } else {
    return 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"SearchResultCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  if ([_searchResults count]) {
    SearchResult *result = _searchResults[indexPath.row];
  
    cell.textLabel.text = result.name;
    cell.detailTextLabel.text = result.artistName;
  } else {
    cell.textLabel.text = @"(Nothing Found)";
  }
  
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (![_searchResults count]) {
    return nil;
  } else {
    return indexPath;
  }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  _searchResults = [NSMutableArray arrayWithCapacity:10];
  
  [searchBar resignFirstResponder];
  
  if (![searchBar.text isEqualToString:@"justin beiber"]) {
    for (int i = 0; i<3; i++)
    {
      SearchResult *result = [[SearchResult alloc] init];
    
      result.name = [NSString stringWithFormat:@"Fake Result %d for", i];
      result.artistName = searchBar.text;
      [_searchResults addObject:result];
    }
  }
  
  [self.tableView reloadData];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
  return UIBarPositionTopAttached;
}

@end
