//
//  DetailViewController.m
//  StoreSearch
//
//  Created by Ryan Robinson on 7/20/14.
//  Copyright (c) 2014 RyanRobinson. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DetailViewController () <UIGestureRecognizerDelegate>

@end

@implementation DetailViewController

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
  
  UIImage *image = [[UIImage imageNamed:@"PriceButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
  
  image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  
  [self.priceButton setBackgroundImage:image forState:UIControlStateNormal];
  
  self.view.tintColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
  
  self.popupView.layer.cornerRadius = 10.0f;
  
  UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
  gestureRecognizer.cancelsTouchesInView = NO;
  gestureRecognizer.delegate = self;
  [self.view addGestureRecognizer:gestureRecognizer];
  
  if (self.searchResult != nil) {
    [self updateUI];
  }
}

- (void)updateUI
{
  [self.artworkImageView setImageWithURL:[NSURL URLWithString:self.searchResult.artworkURL100] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
  
  self.nameLabel.text = self.searchResult.name;
  self.artistLabel.text = self.searchResult.artistName;
  self.kindLabel.text = [self.searchResult kindForDisplay];
  self.genreLabel.text = self.searchResult.genre;
  self.priceButton.titleLabel.text = [NSString stringWithFormat:@"%@%.2f",[self.searchResult symbolForCurrency], [self.searchResult.price doubleValue]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  return (touch.view == self.view);
}

- (IBAction)close:(id)sender
{
  [self willMoveToParentViewController:nil];
  [self.view removeFromSuperview];
  [self removeFromParentViewController];
}

- (NSString *)kindForDisplay:(NSString *)kind
{
  if ([kind isEqualToString:@"album"]) {
    return @"Album";
  } else if ([kind isEqualToString:@"audiobook"]) {
    return @"Audiobook";
  } else if ([kind isEqualToString:@"book"]) {
    return @"Book";
  } else if ([kind isEqualToString:@"ebook"]) {
    return @"E-Book";
  } else if ([kind isEqualToString:@"feature-movie"]) {
    return @"Movie";
  } else if ([kind isEqualToString:@"music-video"]) {
    return @"Music Video";
  } else if ([kind isEqualToString:@"podcast"]) {
    return @"Podcast";
  } else if ([kind isEqualToString:@"software"]) {
    return @"App";
  } else if ([kind isEqualToString:@"song"]) {
    return @"Song";
  } else if([kind isEqualToString:@"tv-episode"]) {
    return @"TV Episode";
  }
  return kind;
}

@end
