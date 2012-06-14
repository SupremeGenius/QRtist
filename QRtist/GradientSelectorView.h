/**
 *  GradientSelectorView.h
 *  QRtist
 *
 *  View controller for gradient customization.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "QACode.h"
#import "CustomizePreviewView.h"

#define kTopColorButton 555
#define kBottomColorButton 556

@interface GradientSelectorView : UIView {
    
    UIView *topColorPreview;
    UIView *bottomColorView;
    UIButton *topColorButton;
    UIButton *bottomColorButton;
    
    UINavigationController *navigationController;
    
    NSString *colorProperty;
    
    QACode *code;
    CustomizePreviewView *previewView;
}

@property (nonatomic, retain) IBOutlet UIView *topColorPreview;
@property (nonatomic, retain) IBOutlet UIView *bottomColorView;
@property (nonatomic, retain) IBOutlet UIButton *topColorButton;
@property (nonatomic, retain) IBOutlet UIButton *bottomColorButton;

@property (nonatomic, retain) NSString *colorProperty;

@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, retain) QACode *code;
@property (nonatomic, retain) CustomizePreviewView *previewView;

- (IBAction)selectedColor:(id)sender;

@end
