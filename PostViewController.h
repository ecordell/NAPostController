//
//  NAPostViewController.h
//  Landscapes
//
//  Created by Evan Cordell on 8/2/11.
//  Copyright 2011 NewAperio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class PostViewController;
@protocol PostControllerDelegate <NSObject>
@optional

- (BOOL)postController:(PostViewController*)postController willSaveText:(NSString*)text;

- (CGRect)postController:(PostViewController*)postController willAnimateTowards:(CGRect)rect;

- (void)postController: (PostViewController*)postController
           didSaveText: (NSString*)text;

- (void)postControllerDidCancel:(PostViewController*)postController;

@end

@interface PostViewController : UIViewController <UITextViewDelegate> {
@protected
    NSString*         _defaultText;

    UIView*           _innerView;
    
    UINavigationBar*  _navigationBar;
    
    UIView*           _screenView;
    UITextView*       _textView;
    
    id<PostControllerDelegate> _delegate;
}

@property (nonatomic, retain) UITextView*       textView;
@property (nonatomic, assign) id<PostControllerDelegate> delegate;

- (void)save;

- (void)cancel;

- (void)layoutTextEditor;

- (CGFloat)keyboardHeightForOrientation:(UIInterfaceOrientation)orientation;

@end


