/**
 *  ExportBarcodeViewController.h
 *  QRtist
 *
 *  View Controller that manages the barcode export screen.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "BlueprintNavController.h"
#import "QACode.h"


@interface ExportBarcodeViewController : UIViewController {
    QACode *barcode;
    UILabel *exportFormatLabel;
}

@property (nonatomic, retain) QACode *barcode;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UILabel *exportFormatLabel;
@property (nonatomic, retain) IBOutlet UIView *exportFormatSelectorView;
@property (nonatomic, retain) IBOutlet UILabel *helpLabel;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)jpegButtonAction:(id)sender;
- (IBAction)pngButtonAction:(id)sender;
- (IBAction)pdfButtonAction:(id)sender;

@end
