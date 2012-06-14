/**
 *  QACode.h
 *  QRtist
 *
 *  Model class for QRCodes. This class is responsible for:
 *      - Generating QRCodes using given data
 *      - Programmatically customizing QRCode appearance
 *      - Serializing QRCodes and writing them to a file
 *      - Storing and cachine the image data that represents the barcode
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *              James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AddressBook/AddressBook.h>
#import "qrenc.h"


typedef enum {
    QRCodeSizeS,
    QRCodeSizeM,
    QRCodeSizeL,
    QRCodeSizeXL
} QRCodeSize;

typedef enum {
    QRCodeErrorCorrectionTypeL,
    QRCodeErrorCorrectionTypeM,
    QRCodeErrorCorrectionTypeQ,
    QRCodeErrorCorrectionTypeH
} QRCodeErrorCorrectionType;

typedef enum {
    QRCodeEncodingModeBytes,
    QRCodeEncodingModeNumeric,
    QRCodeEncodingModeAlphanumeric,
    QRCodeEncodingModeKanjiKana
} QRCodeEncodingMode;

typedef enum {
    QRCodeStylePlain,
    QRCodeStyleDots,
    QRCodeStyleRoundedEdges
} QRCodeStyle;

typedef enum {
    QRCodeDataTypeURL,
    QRCodeDataTypeContactCard,
    QRCodeDataTypePlaintext
} QRCodeDataType;

extern const NSString *kQADataBytesKey;
extern const NSString *kQADataNumberKey;
extern const NSString *kQADataAlphanumericStringKey;
extern const NSString *kQADataKanjiKanaStringKey;

@interface QACode : NSObject<NSCoding> {
    NSInteger storageID;
    
    NSString *title;
    NSUInteger version;
    QRCodeStyle style;
    QRCodeSize size;
    QRCodeErrorCorrectionType errorCorrectionType;
    QRCodeEncodingMode encodingMode;
    QRCodeDataType dataType;
    
    /* QRtist uses KV-coding to simplify the way it stores data */
    NSDictionary *encodedData;
    
    UIColor *backgroundColor;
    UIColor *foregroundColor;
    NSArray *backgroundGradientColors;
    NSArray *foregroundGradientColors;
    
    UIImage *customImage;
    CGPoint imageOffset;
    float imageScale;
    
    NSUInteger scale;
    NSUInteger margin;
    
    ABRecordID contactCardID;
    
    BOOL writtenToDisk;
@private
    QRcode *_qrcode;
    CGImageRef _generatedImage;
    BOOL _dirty;
}

@property (nonatomic, assign) NSInteger storageID;

@property (nonatomic, retain, setter = setTitle:) NSString *title;
@property (nonatomic, assign, setter = setVersion:) NSUInteger version;
@property (nonatomic, assign, setter = setStyle:) QRCodeStyle style;
@property (nonatomic, assign, setter = setSize:) QRCodeSize size;
@property (nonatomic, assign, setter = setErrorCorrectionType:) QRCodeErrorCorrectionType errorCorrectionType;
@property (nonatomic, assign, setter = setEncodingMode:) QRCodeEncodingMode encodingMode;
@property (assign) QRCodeDataType dataType;
@property (assign) ABRecordID contactCardID;

@property (nonatomic, retain, setter = setEncodedData:) NSDictionary *encodedData;

@property (nonatomic, retain, setter = setBackgroundColor:) UIColor *backgroundColor;
@property (nonatomic, retain, setter = setForegroundColor:) UIColor *foregroundColor;
@property (nonatomic, retain, setter = setBackgroundGradientColors:) NSArray *backgroundGradientColors;
@property (nonatomic, retain, setter = setForegroundGradientColors:) NSArray *foregroundGradientColors;

@property (nonatomic, retain, setter = setCustomImage:) UIImage *customImage;
@property (nonatomic, assign, setter = setImageOffset:) CGPoint imageOffset;
@property (nonatomic, assign, setter = setImageScale:) float imageScale;

@property (nonatomic, assign, setter = setScale:) NSUInteger scale;
@property (nonatomic, assign, setter = setMargin:) NSUInteger margin;

@property (nonatomic, assign) BOOL writtenToDisk;

- (id)initWithTitle:(NSString *)codeTitle
    errorCorrectionLevel:(QRCodeErrorCorrectionType)ecLevel
            encodingMode:(QRCodeEncodingMode)encodingMode;
- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error;
+ (id)barcodeWithContentsOfFile:(NSString *)path error:(NSError **)error;

- (UIImage *)imageRepresentation;
- (CGSize)sizeForCustomGraphic:(UIImage *)img;
- (BOOL)writeToFile:(NSString *)path error:(NSError **)error;

@end
