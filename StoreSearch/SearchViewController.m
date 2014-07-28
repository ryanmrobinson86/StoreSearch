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
#import "DetailViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation SearchViewController
{
  NSMutableArray *_searchResults;
  BOOL _isLoading;
  NSOperationQueue *_queue;
  NSString *_searchText;
  NSInteger _searchFilter;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _queue = [[NSOperationQueue alloc] init];
    _searchFilter = 0;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0);
  
  UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
  
  cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
  
  UINib *nothingFoundCellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
  [self.tableView registerNib:nothingFoundCellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
  
  self.tableView.rowHeight = 80;
  [self.searchBar becomeFirstResponder];
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (_isLoading) {
    return 1;
  } else if (_searchResults == nil) {
    return 0;
  } else if ([_searchResults count]) {
    return [_searchResults count];
  } else {
    return 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (_isLoading) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
    
    [spinner startAnimating];
    
    return cell;
  } else if ([_searchResults count]) {
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
    
    SearchResult *result = _searchResults[indexPath.row];
    
    [cell configureForSearchResult:result];
    
    return cell;
  } else {
    return[tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
  }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.searchBar resignFirstResponder];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
  SearchResult *result = (SearchResult *)_searchResults[indexPath.row];
  
  controller.searchResult = result;
  
  controller.view.frame = self.view.frame;
  
  [controller presentInParentViewController:self];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (![_searchResults count] || _isLoading) {
    return nil;
  } else {
    return indexPath;
  }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
  
  [self performSearch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  _searchText = searchText;
  
  if ([_searchText length] > 0) {
    [self performSearch];
  } else {
    [_queue cancelAllOperations];
    _isLoading = NO;
    _searchResults = nil;
    [self.tableView reloadData];
  }
}

#pragma mark - UISegmentedControl

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
  _searchFilter = sender.selectedSegmentIndex;
  
  if (_searchResults != nil) {
    [self performSearch];
  }
}

#pragma mark - Search  & Results

- (void)performSearch
{
  if ([_searchText length] > 0) {
    [_queue cancelAllOperations];
    
    _isLoading = YES;
    [self.tableView reloadData];
    
    _searchResults = [NSMutableArray arrayWithCapacity:10];
    
    NSURL *url = [self urlWithSearchText:_searchText];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      [self parseDictonary:responseObject];
      [_searchResults sortUsingSelector:@selector(compareName:)];
      
      _isLoading = NO;
      [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      if (operation.isCancelled) {
        return;
      }
      _isLoading = NO;
      [self showNetworkError];
      [self.tableView reloadData];
    }];
    
    [_queue addOperation:operation];
  }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
  return UIBarPositionTopAttached;
}

- (NSURL *)urlWithSearchText:(NSString *)searchText
{
  NSString *escaped = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *mediaString = @"all";
  
  switch (_searchFilter) {
    case 1:
      mediaString = @"music";
      break;
      
    case 2:
      mediaString = @"software";
      break;
      
    case 3:
      mediaString = @"ebook";
      
    default:
      break;
  }
  NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200&media=%@", escaped,mediaString];
  
  return [NSURL URLWithString:urlString];
}

- (void)showNetworkError
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops..." message:@"There was an error reading from the iTunes Store. Please Try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  
  [alertView show];
}

- (void)parseDictonary:(NSDictionary *)dictonary
{
  NSArray *array = dictonary[@"results"];
  if (array == nil) {
    NSLog(@"Expected 'results' array");
    return;
  }
  
  for (NSDictionary *resultDict in array) {
    SearchResult *searchResult;
    
    NSString *wrapperType = resultDict[@"wrapperType"];
    NSString *kind = resultDict[@"kind"];
    
    if ([wrapperType isEqualToString:@"track"]) {
      searchResult = [self parseTrack:resultDict];
    } else if ([wrapperType isEqualToString:@"audiobok"]) {
      searchResult = [self parseAudioBook:resultDict];
    } else if([wrapperType isEqualToString:@"software"]) {
      searchResult = [self parseSoftware:resultDict];
    } else if([kind isEqualToString:@"ebook"]) {
      searchResult = [self parseEBook:resultDict];
    }
  
    if (searchResult != nil) {
      [_searchResults addObject:searchResult];
    }
  }
}

- (SearchResult *)parseTrack:(NSDictionary *)dictonary
{
  SearchResult *searchResult = [[SearchResult alloc] init];
  
  searchResult.name = dictonary[@"trackName"];
  searchResult.artistName = dictonary[@"artistName"];
  searchResult.artworkURL60 = dictonary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictonary[@"artworkUrl100"];
  searchResult.storeURL = dictonary[@"trackViewUrl"];
  searchResult.kind = dictonary[@"kind"];
  searchResult.currency = dictonary[@"currency"];
  searchResult.price = dictonary[@"trackPrice"];
  searchResult.genre = dictonary[@"primaryGenreName"];
  
  return searchResult;
}

- (SearchResult *)parseAudioBook:(NSDictionary *)dictonary
{
  SearchResult *searchResult = [[SearchResult alloc] init];
  
  searchResult.name = dictonary[@"collectionName"];
  searchResult.artistName = dictonary[@"artistName"];
  searchResult.artworkURL60 = dictonary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictonary[@"artworkUrl100"];
  searchResult.storeURL = dictonary[@"collectionViewUrl"];
  searchResult.kind = @"audiobook";
  searchResult.currency = dictonary[@"currency"];
  searchResult.price = dictonary[@"collectionPrice"];
  searchResult.genre = dictonary[@"primaryGenreName"];
  
  return searchResult;
}


- (SearchResult *)parseSoftware:(NSDictionary *)dictonary
{
  SearchResult *searchResult = [[SearchResult alloc] init];
  
  searchResult.name = dictonary[@"trackName"];
  searchResult.artistName = dictonary[@"artistName"];
  searchResult.artworkURL60 = dictonary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictonary[@"artworkUrl100"];
  searchResult.storeURL = dictonary[@"trackViewUrl"];
  searchResult.kind = dictonary[@"kind"];
  searchResult.currency = dictonary[@"currency"];
  searchResult.price = dictonary[@"price"];
  searchResult.genre = dictonary[@"primaryGenreName"];
  
  return searchResult;
}

- (SearchResult *)parseEBook:(NSDictionary *)dictionary
{
  SearchResult *searchResult = [[SearchResult alloc] init];
  
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"price"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = [(NSArray *)dictionary[@"genres"] componentsJoinedByString:@", "];
  
  return searchResult;
}

@end
