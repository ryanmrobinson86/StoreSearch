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
#import "GradientView.h"

@interface DetailViewController () <UIGestureRecognizerDelegate>

@end

@implementation DetailViewController
{
  GradientView *_gradientView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
  [self.artworkImageView cancelImageRequestOperation];
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
  
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [formatter setCurrencyCode:self.searchResult.currency];
  
  NSString *priceText;
  if ([self.searchResult.price floatValue] == 0.0f) {
    priceText = @"Free";
  } else {
    priceText = [formatter stringFromNumber:self.searchResult.price];
  }
  [self.priceButton setTitle:priceText forState:UIControlStateNormal];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  return (touch.view == self.view);
}

- (IBAction)close:(id)sender
{
  [self dismissFromParentViewController];
}

- (IBAction)openInStore:(id)sender
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.searchResult.storeURL]];
}

- (void)dismissFromParentViewController
{
  [self willMoveToParentViewController:nil];
  
  [UIView animateWithDuration:0.3 animations:^{
    CGRect rect = self.view.bounds;
    rect.origin.y += rect.size.height;
    self.view.frame = rect;
    _gradientView.alpha = 0.0f;
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [_gradientView removeFromSuperview];
  }];
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{
  _gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
  
  [parentViewController.view addSubview:_gradientView];
  
  self.view.frame = parentViewController.view.bounds;
  [parentViewController.view addSubview:self.view];
  [parentViewController addChildViewController:self];
  
  CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  
  bounceAnimation.duration = 0.4;
  bounceAnimation.delegate = self;
  
  bounceAnimation.values = @[ @0.7, @1.2, @0.9, @1.0];
  bounceAnimation.keyTimes = @[ @0.0, @0.333, @0.667, @1.0];
  
  bounceAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  
  [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
  
  CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fadeAnimation.fromValue = @0.0f;
  fadeAnimation.toValue = @1.0f;
  fadeAnimation.duration = 0.2f;
  [_gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  [self didMoveToParentViewController:self.parentViewController];
}

@end
