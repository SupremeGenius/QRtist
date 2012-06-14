/**
 *  EditCustomGraphicViewController.h
 *  QRtist
 *
 *  View Controller that manages the screen that allows for placement and
 *  scaling of custom graphics within a barcode.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "BarcodeDataEditor.h"


@interface EditCustomGraphicViewController : BarcodeDataEditor<UIActionSheetDelegate> {
    UIImage *customGraphic;
    float graphicScale;
@private
    UIImageView *_graphicImageView;
}

@property (nonatomic, retain) UIImage *customGraphic;
@property (nonatomic, assign) float graphicScale;

@property (nonatomic, retain) IBOutlet UIImageView *_barcodeImageView;
@property (nonatomic, retain) IBOutlet UILabel *_scaleLabel;
@property (nonatomic, retain) IBOutlet UISlider *_scaleSlider;

- (IBAction)scaleSliderAction:(UISlider *)slider;
- (IBAction)deleteAction:(id)sender;

@end
