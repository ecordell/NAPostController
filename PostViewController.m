//
//  NAPostViewController.m
//  Landscapes
//
//  Created by Evan Cordell on 8/2/11.
//  Copyright 2011 NewAperio. All rights reserved.
//

#import "PostViewController.h"

const CGFloat kDefaultPortraitKeyboardHeight      = 216;
const CGFloat kDefaultLandscapeKeyboardHeight     = 160;
const CGFloat kDefaultPadPortraitKeyboardHeight   = 264;
const CGFloat kDefaultPadLandscapeKeyboardHeight  = 352;
const CGFloat kMarginX = 5;
const CGFloat kMarginY = 5;

@implementation PostViewController

@synthesize textView = _textView, delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                       target: self
                                                       action: @selector(cancel)] autorelease];
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle: @"Done"
                                          style: UIBarButtonItemStyleDone
                                         target: self
                                         action: @selector(save)] autorelease];
        //This needs to be up here so we can set the text value after init
        _textView = [[UITextView alloc] init];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    self.view.frame = [UIScreen mainScreen].applicationFrame;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizesSubviews = YES;
    
    _innerView = [[UIView alloc] init];
    _innerView.backgroundColor = [UIColor blackColor];
    _innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _innerView.autoresizesSubviews = YES;
    [self.view addSubview:_innerView];
    
    _screenView = [[UIView alloc] init];
    _screenView.backgroundColor = [UIColor clearColor];
    _screenView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _screenView.autoresizesSubviews = YES;
    [self.view addSubview:_screenView];
    
    
    _textView.delegate = self;
    _textView.textColor = [UIColor blackColor];
    _textView.contentInset = UIEdgeInsetsMake(0, 4, 0, 4);
    _textView.keyboardAppearance = UIKeyboardAppearanceAlert;
    _textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_textView];
    
    _navigationBar = [[UINavigationBar alloc] init];
    _navigationBar.barStyle = UIBarStyleBlackOpaque;
    _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_navigationBar pushNavigationItem:self.navigationItem animated:NO];
    [_innerView addSubview:_navigationBar];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_defaultText) {
        _textView.text = _defaultText;
        
    } else {
        _defaultText = [_textView.text retain];
    }
    _innerView.frame = self.view.bounds;
    [_navigationBar sizeToFit];
    [self layoutTextEditor];
    [_textView becomeFirstResponder];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2];
    self.view.frame = [UIScreen mainScreen].applicationFrame;
    _innerView.frame = self.view.bounds;
    [self layoutTextEditor];
    [UIView commitAnimations];
}

- (void)dismiss {    
    if ([_delegate respondsToSelector:@selector(postController:didSaveText:)]) {
        [_delegate postController:self didSaveText:_textView.text];
    }
    
    [_textView resignFirstResponder];
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)save {
    BOOL shouldDismiss = YES;
    if ([_delegate respondsToSelector:@selector(postController:willSaveText:)]) {
        shouldDismiss = [_delegate postController:self willSaveText:_textView.text];
    }
    
    if (shouldDismiss) {
        [self dismiss];
    } 
}

- (void)cancel {
    if (![[_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]
        && !(_defaultText && [_defaultText isEqualToString:_textView.text])) {
        UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:@"Cancel"
                                                                   message:@"Are you sure you want to cancel?"
                                                                  delegate:self 
                                                         cancelButtonTitle:@"Yes"
                                                         otherButtonTitles:@"No", nil] autorelease];
        [cancelAlertView show];
        
    } else {
        [self dismiss];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self dismiss];
    }
}

- (void)layoutTextEditor {
    CGFloat keyboard = [self keyboardHeightForOrientation:self.interfaceOrientation];
    CGFloat bottom = _navigationBar.frame.origin.y + _navigationBar.frame.size.height;
    _screenView.frame = CGRectMake(0, bottom,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height - (keyboard+_navigationBar.frame.size.height));
    
    _textView.frame = CGRectMake(kMarginX, kMarginY+_navigationBar.frame.size.height,
                                 _screenView.frame.size.width - kMarginX*2,
                                 _screenView.frame.size.height - kMarginY*2);
    _textView.hidden = NO;
    _textView.layer.cornerRadius = 10;
}


- (CGFloat)keyboardHeightForOrientation:(UIInterfaceOrientation)orientation {
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsPortrait(orientation) ? kDefaultPortraitKeyboardHeight
        : kDefaultLandscapeKeyboardHeight;
    } else {
        return UIInterfaceOrientationIsPortrait(orientation) ? kDefaultPadPortraitKeyboardHeight
        : kDefaultPadLandscapeKeyboardHeight;
    }
}

-(void)dealloc {
    [_innerView release];
    [_screenView release];
    [_textView release];
    [_navigationBar release];
}

@end
