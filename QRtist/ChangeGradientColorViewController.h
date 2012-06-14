/**
 *  ChangeGradientColorViewController.h
 *  QRtist
 *
 *  View controller changing gradient colors.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "QACode.h"
#import "ColorPickerView.h"
#import "ColorPickerDelegate.h"
#import "CustomizePreviewView.h"


@interface ChangeGradientColorViewController : UIViewController<ColorPickerDelegate> {
    ColorPickerView *colorPickerView;
    UIScrollView *scrollView;
    
    int gradientColorIndex;
    NSString *colorProperty;
    
    QACode *code;
    
    NSMutableArray *colors;
    
    CustomizePreviewView *previewView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) QACode *code;

@property (assign) int gradientColorIndex;
@property (nonatomic, retain) NSString *colorProperty;

@property (nonatomic, retain) CustomizePreviewView *previewView;

@end
