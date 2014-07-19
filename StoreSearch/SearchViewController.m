//
//  SearchViewController.m
//  StoreSearch
//
//  Created by Ryan Robinson on 6/24/14.
//  Copyright (c) 2014 RyanRobinson. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";

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
  
  UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
  
  UINib *nothingFoundCellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
  [self.tableView registerNib:nothingFoundCellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
  
  self.tableView.rowHeight = 80;
  [self.searchBar becomeFirstResponder];
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
  if ([_searchResults count]) {
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
    
    SearchResult *result = _searchResults[indexPath.row];
  
    cell.nameLabel.text = result.name;
    cell.artistNameLabel.text = result.artistName;
    return cell;
  } else {
    return[tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
  }
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
  if ([searchBar.text length] > 0) {
    
    [searchBar resignFirstResponder];
    
    _searchResults = [NSMutableArray arrayWithCapacity:10];
    
    NSURL *url = [self urlWithSearchText:searchBar.text];
    NSString *jsonString = [self performStoreRequestWithURL:url];
    if (jsonString == nil) {
      [self showNetworkError];
      return;
    }
    
    NSDictionary *resultsDictonary = [self parseJSON:jsonString];
    if (resultsDictonary == nil) {
      [self showNetworkError];
      return;
    }
    
    [self.tableView reloadData];
  }
}

#pragma mark - Networking

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
  return UIBarPositionTopAttached;
}

- (NSURL *)urlWithSearchText:(NSString *)searchText
{
  NSString *escaped = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@", escaped];
  
  return [NSURL URLWithString:urlString];
}

- (NSString *)performStoreRequestWithURL:(NSURL *)url
{
  NSError *error;
  NSString *resultString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
  if (resultString == nil) {
    NSLog(@"Download Error: '%@'",error);
    return nil;
  }
  return resultString;
}

- (NSDictionary *)parseJSON:(NSString *)jsonString
{
  NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  
  NSError *error;
  id resultObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
  
  if (resultObject == nil) {
    NSLog(@"Error parsing JSON: '%@'", error);
    return nil;
  }
  
  if (![resultObject isKindOfClass:[NSDictionary class]]) {
    NSLog(@"JSON Error: Expected Dictonary");
    return nil;
  }
  
  return resultObject;
}

- (void)showNetworkError
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops..." message:@"There was an error reading from the iTunes Store. Please Try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  
  [alertView show];
}

@end
