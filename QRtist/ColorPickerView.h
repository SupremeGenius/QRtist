/**
 *  ColorPickerView.h
 *  QRtist
 *
 *  View subclass for picking a color. Contains three sliders: red,
 *  green, and blue values.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "ColorPickerDelegate.h"

#define kRedSlider 3334
#define kGreenSlider 3335
#define kBlueSlider 3336

@interface ColorPickerView : UIView {
    UISlider *redSlider;
    UISlider *greenSlider;
    UISlider *blueSlider;
    
    UIColor *currentColor;
    
    id<ColorPickerDelegate> delegate;
}
@property (nonatomic, retain) IBOutlet UISlider *redSlider;
@property (nonatomic, retain) IBOutlet UISlider *greenSlider;
@property (nonatomic, retain) IBOutlet UISlider *blueSlider;

@property (nonatomic, retain) UIColor *currentColor;

@property (assign) id<ColorPickerDelegate> delegate;


- (IBAction)valueChanged:(id)sender;

@end
