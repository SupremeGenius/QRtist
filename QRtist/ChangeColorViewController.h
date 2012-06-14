/**
 *  ChangeColorViewController.h
 *  QRtist
 *
 *  View controller for color customization.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "QACode.h"
#import "CustomizePreviewView.h"
#import "ColorPickerView.h"
#import "GradientSelectorView.h"

#import "ColorPickerDelegate.h"

@interface ChangeColorViewController : UIViewController<ColorPickerDelegate> {
    UIScrollView *scrollView;
    
    QACode *code;
    
    ColorPickerView *solidColorPickers;
    GradientSelectorView *gradientChooseView;
    
    CustomizePreviewView *previewView;
    
    UIView *colorSelectView;
    
    NSString *colorProperty;
    UISegmentedControl *colorTypeSegmentedControl;
    
    NSString *gradientArrayProperty;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) QACode *code;

@property (nonatomic, retain) NSString *colorProperty;

@property (nonatomic, retain) IBOutlet UISegmentedControl *colorTypeSegmentedControl;
@property (nonatomic, retain) CustomizePreviewView *previewView;
@property (nonatomic, retain) IBOutlet UIView *colorSelectView;

- (IBAction)swapSolidGradientControls:(id)sender;

@end
