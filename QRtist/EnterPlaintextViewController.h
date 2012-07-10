/**
 *  EnterPlaintextViewController.h
 *  QRtist
 *
 *  View controller for entering plain text as a data source for the barcode.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *              Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "BarcodeDataEditor.h"

@interface EnterPlaintextViewController : BarcodeDataEditor<UITextViewDelegate> {
    
    UITextView *textView;
    UIScrollView *contentScroll;
}
@property (nonatomic, retain) IBOutlet UIScrollView *contentScroll;
@property (nonatomic, retain) IBOutlet UITextView *textView;

@end
