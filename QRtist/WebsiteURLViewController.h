/**
 *  WebsiteURLViewController.h
 *  QRtist
 *
 *  View controller for entering a website URL as a data source for the barcode.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Kevin Geisler <kgeisler@email.arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "BarcodeDataEditor.h"

@interface WebsiteURLViewController : BarcodeDataEditor<UITextFieldDelegate> {
    
    UIScrollView *contentScroll;
    UITextField *urlField;
}
@property (nonatomic, retain) IBOutlet UIScrollView *contentScroll;
@property (nonatomic, retain) IBOutlet UITextField *urlField;

@end
