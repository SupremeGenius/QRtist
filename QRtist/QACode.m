/**
 *  QACode.m
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

#import "QACode.h"

#define kQACodeDefaultScale  8
#define kQACodeDefaultMargin 5
#define kInvalidStorageID   -1337

#define FTOB(x) (floor(x == 1.0 ? 255 : x * 256.0)) // Converts float (0 <= X <= 255) to byte


const NSString *kQADataBytesKey = @"kQADataBytesKey";
const NSString *kQADataNumberKey = @"kQADataNumberKey";
const NSString *kQADataAlphanumericStringKey = @"kQADataAlphanumericStringKey";
const NSString *kQADataKanjiKanaStringKey = @"kQADataKanjiKanaStringKey";

typedef enum {
    kRoundedRectTopLeft      = 1 << 0,
    kRoundedRectTopRight     = 1 << 1,
    kRoundedRectBottomLeft   = 1 << 2,
    kRoundedRectBottomRight  = 1 << 3
} kRoundedRect_t;


@interface QACode ()

- (void)generateCode;
- (void)printCode;
- (CGImageRef)getQRCodeImage __attribute__((deprecated));
- (CGImageRef)getQRCodeImageCoreGraphics;
- (float)codewordRestorationPercentage;
- (CGSize)sizeForCustomGraphic:(UIImage *)img inBarcodeWithSize:(CGSize)barcodeSize;

@end

@implementation QACode
@synthesize storageID;
@synthesize title, version, style, size, errorCorrectionType, encodingMode;
@synthesize encodedData;
@synthesize backgroundColor, foregroundColor;
@synthesize foregroundGradientColors, backgroundGradientColors;
@synthesize customImage, imageOffset, imageScale;
@synthesize scale, margin;
@synthesize dataType;
@synthesize contactCardID;
@synthesize writtenToDisk;

QRecLevel bridge_ec_level(QRCodeErrorCorrectionType type); // Converts QRCodeErrorCorrectionType type to QRecLevel
QRencodeMode bridge_encode_mode(QRCodeEncodingMode mode);  // Converts QRCodeEncodingMode type to QRencodeMode
unsigned char* get_byte_color_components(CGColorRef color); // Gives color components as bytes from 0..255
CGColorRef monochrome_to_rgb(CGColorRef color);             // Converts `color` to RGB color space

- (void)initialize
{
    storageID = kInvalidStorageID;
    version = 0;
    style = QRCodeStylePlain;
    size = QRCodeSizeM;
    encodedData = [[NSDictionary alloc] init];
    dataType = QRCodeDataTypePlaintext;
    
    backgroundColor = [[UIColor whiteColor] retain];
    foregroundColor = [[UIColor blackColor] retain];
    backgroundGradientColors = nil;
    foregroundGradientColors = nil;
    
    customImage = nil;
    imageOffset = CGPointZero;
    imageScale = 1.0;
    
    scale = kQACodeDefaultScale;
    margin = kQACodeDefaultMargin;
    
    writtenToDisk = NO;
    
    _qrcode = NULL;
    _generatedImage = NULL;
    _dirty = YES;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Untitled";
        self.errorCorrectionType = QRCodeErrorCorrectionTypeH;
        self.encodingMode = QRCodeEncodingModeAlphanumeric;
        
        [self initialize];
    }
    return self;
}

- (id)initWithTitle:(NSString *)codeTitle
    errorCorrectionLevel:(QRCodeErrorCorrectionType)ecLevel
            encodingMode:(QRCodeEncodingMode)encMode
{
    self = [super init];
    if (self) {
        self.title = codeTitle;
        self.errorCorrectionType = ecLevel;
        self.encodingMode = encMode;
        
        [self initialize];
    }
    return self;
}

- (id)initWithContentsOfFile:(NSString *)path error:(NSError **)error
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:path options:nil error:error];
    if (!data) return nil;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id object = [unarchiver decodeObject];
    
    [data release];
    [unarchiver release];
    
    return [object retain];
}

+ (id)barcodeWithContentsOfFile:(NSString *)path error:(NSError **)error
{
    QACode *code = [[QACode alloc] initWithContentsOfFile:path error:error];
    if (!code) return nil;
    
    return [code autorelease];
}


#pragma mark - NSCoding

#define kIDKey                          @"QAStorageID"
#define kTitleKey                       @"QATitle"
#define kVersionKey                     @"QAVersion"
#define kStyleKey                       @"QAStyle"
#define kSizeKey                        @"QASize"
#define kErrorCorrectionTypeKey         @"QAErrorCorrectionType"
#define kEncodingModeTypeKey            @"QAEncodingMode"
#define kDataTypeKey                    @"QADataType"
#define kContactCardIDKey               @"QAContactCardID"
#define kEncodedDataKey                 @"QAEncodedData"
#define kBackgroundColorKey             @"QABackgroundColor"
#define kForegroundColorKey             @"QAForegroundColor"
#define kBackgroundGradientColorsKey    @"QABackgroundGradientColors"
#define kForegroundGradientColorsKey    @"QAForegroundGradientColors"
#define kCustomImageKey                 @"QACustomImage"
#define kImageOffsetKey                 @"QAImageOffset"
#define kImageScaleKey                  @"QAImageScale"
#define kScaleKey                       @"QAScale"
#define kMarginKey                      @"QAMargin"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        [self initialize];
        
        self.storageID = [aDecoder decodeIntegerForKey:kIDKey];
        self.title = [aDecoder decodeObjectForKey:kTitleKey];
        self.version = [aDecoder decodeIntegerForKey:kVersionKey];
        self.style = (QRCodeStyle) [aDecoder decodeIntegerForKey:kStyleKey];
        self.size = (QRCodeSize) [aDecoder decodeIntegerForKey:kSizeKey];
        self.errorCorrectionType = (QRCodeErrorCorrectionType) [aDecoder decodeIntegerForKey:kErrorCorrectionTypeKey];
        self.encodingMode = (QRCodeEncodingMode) [aDecoder decodeIntegerForKey:kEncodingModeTypeKey];
        self.dataType = (QRCodeDataType) [aDecoder decodeIntegerForKey:kDataTypeKey];
        self.contactCardID = (ABRecordID) [aDecoder decodeIntegerForKey:kContactCardIDKey];
        self.encodedData = [aDecoder decodeObjectForKey:kEncodedDataKey];
        self.backgroundColor = [aDecoder decodeObjectForKey:kBackgroundColorKey];
        self.foregroundColor = [aDecoder decodeObjectForKey:kForegroundColorKey];
        self.backgroundGradientColors = [aDecoder decodeObjectForKey:kBackgroundGradientColorsKey];
        self.foregroundGradientColors = [aDecoder decodeObjectForKey:kForegroundGradientColorsKey];
        self.customImage = [[UIImage alloc] initWithData:[aDecoder decodeObjectForKey:kCustomImageKey]];
        self.imageOffset = [[aDecoder decodeObjectForKey:kImageOffsetKey] CGPointValue];
        self.imageScale = [aDecoder decodeFloatForKey:kImageScaleKey];
        self.scale = [aDecoder decodeIntegerForKey:kScaleKey];
        self.margin = [aDecoder decodeIntegerForKey:kMarginKey];
        
        self.writtenToDisk = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.storageID forKey:kIDKey];
    [coder encodeObject:self.title forKey:kTitleKey];
    [coder encodeInteger:self.version forKey:kVersionKey];
    [coder encodeInteger:self.style forKey:kStyleKey];
    [coder encodeInteger:self.size forKey:kSizeKey];
    [coder encodeInteger:self.errorCorrectionType forKey:kErrorCorrectionTypeKey];
    [coder encodeInteger:self.encodingMode forKey:kEncodingModeTypeKey];
    [coder encodeInteger:self.dataType forKey:kDataTypeKey];
    [coder encodeInteger:self.contactCardID forKey:kContactCardIDKey];
    [coder encodeObject:self.encodedData forKey:kEncodedDataKey];
    [coder encodeObject:self.backgroundColor forKey:kBackgroundColorKey];
    [coder encodeObject:self.foregroundColor forKey:kForegroundColorKey];
    [coder encodeObject:self.backgroundGradientColors forKey:kBackgroundGradientColorsKey];
    [coder encodeObject:self.foregroundGradientColors forKey:kForegroundGradientColorsKey];
    [coder encodeObject:[NSValue valueWithCGPoint:self.imageOffset] forKey:kImageOffsetKey];
    [coder encodeFloat:self.imageScale forKey:kImageScaleKey];
    [coder encodeInteger:self.scale forKey:kScaleKey];
    [coder encodeInteger:self.margin forKey:kMarginKey];
    
    if (self.customImage != nil) {
        NSData *imgdata = UIImagePNGRepresentation(self.customImage);
        [coder encodeObject:imgdata forKey:kCustomImageKey];
    }
}


#pragma mark - Accessors
/*
 Lots of accessors are overridden in this class so that they can set the barcode as
 "dirty" when certain properties are changed. This is so that the program can throw
 out the image and/or data cache that it has stored for this barcode and regenerate.
 --Charles
 */

- (void)setTitle:(NSString *)t
{
    if (title != nil)
        [title release];
    title = [t retain];
    
    _dirty = YES;
}

- (void)setVersion:(NSUInteger)v
{
    version = v;
    _dirty = YES;
}

- (void)setStyle:(QRCodeStyle)s
{
    style = s;
    _dirty = YES;
}

- (void)setSize:(QRCodeSize)s
{
    size = s;
    _dirty = YES;
}

- (void)setErrorCorrectionType:(QRCodeErrorCorrectionType)ec
{
    errorCorrectionType = ec;
    _dirty = YES;
}

- (void)setEncodingMode:(QRCodeEncodingMode)em
{
    encodingMode = em;
    _dirty = YES;
}

- (void)setEncodedData:(NSDictionary *)ed
{
    if (encodedData != nil)
        [encodedData release];
    encodedData = [ed retain];
    
    _dirty = YES;
}

- (void)setBackgroundColor:(UIColor *)bg
{
    if (backgroundColor != nil)
        [backgroundColor release];
    backgroundColor = [bg retain];
    
    _dirty = YES;
}

- (void)setForegroundColor:(UIColor *)fg
{
    if (foregroundColor != nil)
        [foregroundColor release];
    foregroundColor = [fg retain];
    
    _dirty = YES;
}

- (void)setBackgroundGradientColors:(NSArray *)bgc
{
    if (backgroundGradientColors != nil)
        [backgroundGradientColors release];
    backgroundGradientColors = [bgc retain];
    
    _dirty = YES;
}

- (void)setForegroundGradientColors:(NSArray *)fgc
{
    if (foregroundGradientColors != nil)
        [foregroundGradientColors release];
    foregroundGradientColors = [fgc retain];
    
    _dirty = YES;
}

- (void)setCustomImage:(UIImage *)ci
{
    if (customImage != nil)
        [customImage release];
    customImage = [ci retain];
    
    _dirty = YES;
}

- (void)setImageOffset:(CGPoint)offset
{
    imageOffset = offset;
    _dirty = YES;
}

- (void)setScale:(NSUInteger)s
{
    scale = s;
    _dirty = YES;
}

- (void)setMargin:(NSUInteger)m
{
    margin = m;
    _dirty = YES;
}


#pragma mark - Image Generation

/* Generate the QRCode's image by filling in a pixel buffer */
- (CGImageRef)getQRCodeImage
{
    if (_generatedImage != NULL && !_dirty)
        return _generatedImage;
    
    if (_dirty)
        [self generateCode];
    
    NSAssert(_qrcode != NULL, @"QRCode structure is NULL when trying to generate image. Aborting.");
    
    unsigned char *bg_components = get_byte_color_components(self.backgroundColor.CGColor);
    unsigned char *fg_components = get_byte_color_components(self.foregroundColor.CGColor);
    
    unsigned char *code_data = _qrcode->data;
    int code_width = _qrcode->width; // The width of the barcode data (not the image)
    int img_width = (code_width * scale) + (margin * 2); // The width of the image, times its scale, plus its left and right margins
    int img_height = img_width; // The height is the same as the width because it's a square image.
    
    unsigned char *img_data = (unsigned char *) malloc((img_width * img_width * 4) + (margin * 4) * 4); // Four bytes per pixel, plus the four margins
    if (img_data == NULL) {
        fprintf(stderr, "ERROR: Could not allocate image data for barcode.\n");
        exit(-1);
    }
    
    // Top Margin
    for (int i = 0; i < img_width * margin * 4; i++) {
        img_data[i] = bg_components[i % 4];
    }
    
    for (int y = margin; y < img_height - margin; y++) {
        // Left Margin
        for (int x = 0; x < margin * 4; x++) {
            img_data[y * img_width * 4 + x] = bg_components[x % 4];
        }
        
        // Barcode Row
        int codeidx_y = (y - margin) / scale;
        for (int x = margin; x < img_width - margin; x++) {
            int codeidx_x = (x - margin) / scale;
            int codeidx = codeidx_y * code_width + codeidx_x;
            int imgidx = (y * img_width + x) * 4;
            
            int pixelon = (code_data[codeidx] & 1 ? 1 : 0); // If the least significant bit is 1, then this part of the code is black
            if (pixelon) {
                for (int i = 0; i < 4; i++)
                    img_data[imgidx + i] = fg_components[i % 4];
            } else {
                for (int i = 0; i < 4; i++)
                    img_data[imgidx + i] = bg_components[i % 4];
            }
        }
        
        // Right Margin
        for (int x = (img_width - margin) * 4; x < img_width * 4; x++) {
            img_data[y * img_width * 4 + x] = bg_components[x % 4];
        }
    }
    
    // Bottom Margin
    for (int i = (img_height - margin) * img_width * 4; i < img_width * img_height * 4; i++) {
        img_data[i] = bg_components[i % 4];
    }
    
    CGColorSpaceRef clrspc = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmpctxt = CGBitmapContextCreate(img_data,        // The image data
                                                 img_width,       // The width of the image
                                                 img_height,      // The height of the image
                                                 8,               // Bits per component (1 byte)
                                                 4 * img_width,   // Bytes per row
                                                 clrspc,          // Color Space
                                                 kCGImageAlphaPremultipliedLast); // Info (alpha is last value)
    CGImageRef result = CGBitmapContextCreateImage(bmpctxt);
    
    CFRelease(clrspc);
    CFRelease(bmpctxt);
    free(img_data);
    free(bg_components);
    free(fg_components);
    
    if (_generatedImage != NULL) {
        CFRelease(_generatedImage);
        _generatedImage = NULL;
    }
    
    _generatedImage = result;
    
    return result;
}

- (void)drawRoundedRect:(CGRect)rrect inContext:(CGContextRef)context withRadius:(CGFloat)radius cornerOptions:(unsigned int)options {
	CGContextBeginPath (context);
    
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), 
    maxx = CGRectGetMaxX(rrect);
    
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), 
    maxy = CGRectGetMaxY(rrect);
    
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, (options & kRoundedRectBottomLeft) ? radius : 0);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, (options & kRoundedRectBottomRight) ? radius : 0);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, (options & kRoundedRectTopRight) ? radius : 0);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, (options & kRoundedRectTopLeft) ? radius : 0);
	CGContextClosePath(context);
}

- (void)drawGradientWithColors:(NSArray *)_colors inRect:(CGRect)rect inContext:(CGContextRef)context {
    NSMutableArray *colors = [NSMutableArray array];
    for (UIColor *color in [_colors reverseObjectEnumerator]) {
        // The documentation says that CGGradientCreateWithColors() converts the colorspaces automatically,
        // but it looks like it doesn't! Let's do it ourselves then.
        CGColorRef colorref = [color CGColor];
        CGColorSpaceModel clrspc = CGColorSpaceGetModel(CGColorGetColorSpace(colorref));
        if (clrspc == kCGColorSpaceModelMonochrome)
            colorref = monochrome_to_rgb(colorref);
        
        [colors addObject:(id)colorref];
    }
    
    size_t num_locations = 2; // TEMPORARY! Right now, only support two colors
    CGFloat locations[num_locations];
    CGFloat loc = 1.0 / (num_locations - 1);
    for (int i = 0; i < num_locations; i++) {
        locations[i] = loc * i;
    }
    
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (CFArrayRef)colors, locations);
    CGContextDrawLinearGradient(context, gradient, rect.origin, CGPointMake(0, rect.size.height), num_locations);
    CFRelease(gradient);
}

/* Generate the QRCode's image using Core Graphics */
- (CGImageRef)getQRCodeImageCoreGraphics
{
    if (_generatedImage != NULL && !_dirty)
        return _generatedImage;
    
    if (_dirty)
        [self generateCode];
    
    NSAssert(_qrcode != NULL, @"QRCode structure is NULL when trying to generate image. Aborting.");
    
    unsigned char *code_data = _qrcode->data;
    int code_width = _qrcode->width;
    int img_width = (code_width * scale) + (margin * 2);
    int img_height = img_width;
    
    unsigned char *img_data = (unsigned char *) malloc((img_width * img_width * 4) + (margin * 4 * 4));
    if (img_data == NULL) {
        fprintf(stderr, "ERROR: Could not allocate image data for barcode.\n");
        exit(-1);
    }
    
    CGColorSpaceRef rgbclrspc = CGColorSpaceCreateDeviceRGB();
    CGColorSpaceRef mcclrspc = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx = CGBitmapContextCreate(img_data, 
                                             img_width, 
                                             img_height, 
                                             8, 
                                             4 * img_width, 
                                             rgbclrspc, 
                                             kCGImageAlphaPremultipliedLast);
    CGContextSetStrokeColorSpace(ctx, rgbclrspc);
     
    // Always black
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
    for (int y = 0; y < code_width; y++) {
        float ypos = (float) img_height - ((y+1) * scale) - margin;
        for (int x = 0; x < code_width; x++) {
            float xpos = x * scale + margin;
            int code_idx = y * code_width + x;
            
            BOOL pixelon = (code_data[code_idx] & 1 ? YES : NO);
            if (pixelon) {
                CGRect rect = CGRectMake(xpos, ypos, (CGFloat) scale, (CGFloat) scale);
                if (style == QRCodeStyleDots) {
                    CGContextFillEllipseInRect(ctx, rect);
                } else if (style == QRCodeStyleRoundedEdges) {
                    // Start with all options--we're going to disable them conditionally
                    unsigned options = (kRoundedRectBottomLeft | kRoundedRectBottomRight | kRoundedRectTopLeft | kRoundedRectTopRight);
                    
                    // If there's a pixel to the left of us, don't round the left edge of this dot
                    if (x != 0 && code_data[y * code_width + (x - 1)] & 1) {
                        options ^= (kRoundedRectBottomLeft | kRoundedRectTopLeft);
                    }
                    
                    // If there's a pixel to the right, don't round the right edge
                    if (x != code_width - 1 && code_data[y * code_width + (x + 1)] & 1) {
                        options ^= (kRoundedRectBottomRight | kRoundedRectTopRight);
                    }
                    
                    // If there's a pixel above, then don't round the top
                    if (y != 0 && code_data[(y - 1) * code_width + x] & 1) {
                        // We want to check if this bit's already been disabled, so that we don't
                        // re-enable it again by accident
                        if (options & kRoundedRectTopLeft)
                            options ^= kRoundedRectTopLeft;
                        if (options & kRoundedRectTopRight)
                            options ^= kRoundedRectTopRight;
                    }
                    
                    // If there's a pixel below, don't round the bottom edge
                    if (y != code_width - 1 && code_data[(y + 1) * code_width + x] & 1) {
                        if (options & kRoundedRectBottomLeft)
                            options ^= kRoundedRectBottomLeft;
                        if (options & kRoundedRectBottomRight)
                            options ^= kRoundedRectBottomRight;
                    }
                    
                    [self drawRoundedRect:rect inContext:ctx withRadius:4.0f cornerOptions:options];
                    CGContextDrawPath(ctx, kCGPathFill);
                } else {
                    CGContextFillRect(ctx, rect);
                }
            }
        }
    }
    
    // Draw the foreground into a buffer, save that buffer to a CGImageRef
    CGContextSaveGState(ctx);
    if (CGColorSpaceGetModel(CGColorGetColorSpace(self.foregroundColor.CGColor)) == kCGColorSpaceModelMonochrome) {
        CGContextSetFillColorSpace(ctx, mcclrspc);
    } else {
        CGContextSetFillColorSpace(ctx, rgbclrspc);
    }
    CGContextSetFillColor(ctx, CGColorGetComponents(self.foregroundColor.CGColor));

    
    // Create the mask, save it as a CGImageRef
    CGImageRef foregroundMask = CGBitmapContextCreateImage(ctx);
    
    CGContextClipToMask(ctx, CGRectMake(0, 0, img_width, img_height), foregroundMask);
    
    // Foreground Filling code
    if (foregroundGradientColors != nil && [foregroundGradientColors count] > 1) {
        [self drawGradientWithColors:foregroundGradientColors inRect:CGRectMake(0, 0, img_width, img_height) inContext:ctx];
    } else {
        CGContextFillRect(ctx, CGRectMake(0, 0, img_width, img_height));
    }
    
    CGImageRef foregroundImg = CGBitmapContextCreateImage(ctx);
    
    // Now draw the background
    CGContextRestoreGState(ctx);
    if (CGColorSpaceGetModel(CGColorGetColorSpace(self.backgroundColor.CGColor)) == kCGColorSpaceModelMonochrome) {
        CGContextSetFillColorSpace(ctx, mcclrspc);
    } else {
        CGContextSetFillColorSpace(ctx, rgbclrspc);
    }
    CGContextSetFillColor(ctx, CGColorGetComponents(self.backgroundColor.CGColor));
    
    // Background Filling code
    if (backgroundGradientColors != nil && [backgroundGradientColors count] > 1) {
        [self drawGradientWithColors:backgroundGradientColors inRect:CGRectMake(0, 0, img_width, img_height) inContext:ctx];
    } else {
        CGContextFillRect(ctx, CGRectMake(0, 0, img_width, img_height));
    }
    
    // Once the background has been drawn, draw the foreground on top of it.
    CGContextDrawImage(ctx, CGRectMake(0, 0, img_width, img_height), foregroundImg);
    
    // Draw the custom image, if any
    if (customImage != nil) {
        CGSize sz = [self sizeForCustomGraphic:self.customImage inBarcodeWithSize:CGSizeMake(img_width, img_height)];
        
        CGRect imgrect = CGRectZero;
        imgrect.size.width = sz.width * imageScale;
        imgrect.size.height = sz.height * imageScale;
        imgrect.origin.x = imageOffset.x;
        imgrect.origin.y = (img_height - imageOffset.y - imgrect.size.height);
        CGContextDrawImage(ctx, imgrect, customImage.CGImage);
    }
    
    // Resulting image is the combination of both images.
    CGImageRef result = CGBitmapContextCreateImage(ctx);
    
    CFRelease(rgbclrspc);
    CFRelease(mcclrspc);
    CFRelease(ctx);
    CFRelease(foregroundImg);
    CFRelease(foregroundMask);
    free(img_data);
    
    if (_generatedImage != NULL) {
        CFRelease(_generatedImage);
        _generatedImage = NULL;
    }
    
    _generatedImage = result;
    
    return result;
}

- (CGSize)sizeForCustomGraphic:(UIImage *)img inBarcodeWithSize:(CGSize)barcodeSize
{
    float barcode_width = barcodeSize.width;
    float barcode_height = barcodeSize.height;
    
    float img_width, img_height;
    float new_width, new_height;
    
    img_width = img.size.width;
    img_height = img.size.height;
    
    float percentage = [self codewordRestorationPercentage];
    float imgratio = percentage * (barcode_width * barcode_height);
    float aspect = MAX(img_width, img_height) / MIN(img_width, img_height);
    float dimension = sqrt(imgratio / aspect) * 0.8;
    if (img_width < img_height) {
        new_width = dimension;
        new_height = dimension * aspect;
    } else if (img_width > img_height) {
        new_width = dimension * aspect;
        new_height = dimension;
    } else {
        new_width = new_height = dimension;
    }
    
    return CGSizeMake(new_width, new_height);
}

- (CGSize)sizeForCustomGraphic:(UIImage *)img
{
    CGSize barcode_sz = [[self imageRepresentation] size];
    return [self sizeForCustomGraphic:img inBarcodeWithSize:barcode_sz];
}

- (UIImage *)imageRepresentation
{
    CGImageRef imgref = [self getQRCodeImageCoreGraphics];
    return [UIImage imageWithCGImage:imgref];
}

unsigned char* get_byte_color_components(CGColorRef color)
{
    const CGFloat *components = CGColorGetComponents(color);
    CGColorSpaceModel clrspc = CGColorSpaceGetModel(CGColorGetColorSpace(color));
    
    unsigned char *new_components = (unsigned char *) malloc(4);
    if (new_components == NULL) {
        fprintf(stderr, "ERROR: Could not allocate memory for color components.\n");
        exit(-1);
    }
    
    if (clrspc == kCGColorSpaceModelMonochrome && CGColorGetNumberOfComponents(color) == 2) {
        memset(&new_components[0], FTOB(components[0]), 3);
        new_components[3] = FTOB(components[1]);
    } else if (clrspc == kCGColorSpaceModelRGB && CGColorGetNumberOfComponents(color) >= 3) {
        new_components[0] = FTOB(components[0]);
        new_components[1] = FTOB(components[1]);
        new_components[2] = FTOB(components[2]);
        
        if (CGColorGetNumberOfComponents(color) >= 4)
            new_components[3] = FTOB(components[3]);
        else
            new_components[3] = 255;
    }
    
    return new_components;
}

CGColorRef monochrome_to_rgb(CGColorRef color) {
    const CGFloat *components = CGColorGetComponents(color);
    CGColorSpaceModel clrspc = CGColorSpaceGetModel(CGColorGetColorSpace(color));
    if (clrspc == kCGColorSpaceModelRGB)
        return color;
    
    float new_components[4];
    
    for (int i = 0; i < 3; i++)
        new_components[i] = components[0];
    new_components[3] = components[1];
    
    CGColorSpaceRef rgbclrspc = CGColorSpaceCreateDeviceRGB();
    CGColorRef result = CGColorCreate(rgbclrspc, new_components);
    CFRelease(rgbclrspc);
    
    return result;
}


#pragma mark - Code Generation

- (void)generateCode
{
    if (self.encodedData != nil) {
        QRcode *newCode;
        QRecLevel level = bridge_ec_level(errorCorrectionType);
        
        switch (self.encodingMode) {
            case QRCodeEncodingModeBytes:
            {
                NSData *data = [encodedData objectForKey:kQADataBytesKey];
                //NSAssert(data != nil, @"Object for key %@ does not exist in QACode object 0x%d", kQADataBytesKey, self);
                
                QRinput *input = QRinput_new();
                QRinput_append(input, QR_MODE_8, [data length], (unsigned char*)[data bytes]);
                QRinput_setVersion(input, version);
                QRinput_setErrorCorrectionLevel(input, level);
                
                newCode = QRcode_encodeInput(input);
                QRinput_free(input);
                
                break;
            }
            case QRCodeEncodingModeNumeric:
            {
                NSNumber *number = [encodedData objectForKey:kQADataNumberKey];
                //NSAssert(number != nil, @"Object for key %@ does not exist in QACode object 0x%d", kQADataNumberKey, self);
                
                const char *str = [[number stringValue] UTF8String];
                newCode = QRcode_encodeString8bit(str, version, level);
                
                break;
            }
            case QRCodeEncodingModeAlphanumeric:
            {
                NSString *str = [encodedData objectForKey:kQADataAlphanumericStringKey];
                //NSAssert(str != nil, @"Object for key %@ does not exist in QACode object 0x%d", kQADataAlphanumericStringKey, self);
                
                const char *utf8str = [str UTF8String];
                newCode = QRcode_encodeString8bit(utf8str, version, level);
                
                break;
            }
            case QRCodeEncodingModeKanjiKana:
            {
                NSString *str = [encodedData objectForKey:kQADataKanjiKanaStringKey];
                //NSAssert(str != nil, @"Object for key %@ does not exist in QACode object 0x%d", kQADataKanjiKanaStringKey, self);
                
                const char *utf8str = [str UTF8String];
                newCode = QRcode_encodeString(utf8str, version, level, QR_MODE_KANJI, 0);
                
                break;
            }
            default:
                break;
        }
        
        if (_qrcode != NULL) {
            QRcode_free(_qrcode);
            _qrcode = NULL;
        }
        
        _qrcode = newCode;
        _dirty = NO;
    }
}

- (float)codewordRestorationPercentage
{
    float result;
    
    // Error correction info from http://en.wikipedia.org/wiki/QRcode
    switch (errorCorrectionType) {
        case QRCodeErrorCorrectionTypeL:
            result = 0.07;
            break;
        case QRCodeErrorCorrectionTypeM:
            result = 0.15;
            break;
        case QRCodeErrorCorrectionTypeQ:
            result = 0.25;
            break;
        case QRCodeErrorCorrectionTypeH:
            result = 0.30;
            break;
        default:
            result = 0.0;
            break;
    }
    
    return result;
}


#pragma mark - Saving/Loading

- (BOOL)writeToFile:(NSString *)path error:(NSError **)error
{    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self];
    [archiver finishEncoding];
    
    BOOL result; NSError *l_error = nil;
    result = [data writeToFile:path options:NSDataWritingAtomic error:&l_error];
    if (l_error != nil) {
        *error = l_error;
    }
    
    if (result)
        [self setWrittenToDisk:YES];
    else
        [self setWrittenToDisk:NO];
    
    return result;
}


#pragma mark - qrencode Type Bridging Functions

QRecLevel bridge_ec_level(QRCodeErrorCorrectionType type)
{
    QRecLevel retval;
    switch (type) {
        case QRCodeErrorCorrectionTypeH:
            retval = QR_ECLEVEL_H;
            break;
        case QRCodeErrorCorrectionTypeL:
            retval = QR_ECLEVEL_L;
            break;
        case QRCodeErrorCorrectionTypeM:
            retval = QR_ECLEVEL_M;
            break;
        case QRCodeErrorCorrectionTypeQ:
            retval = QR_ECLEVEL_Q;
            break;
        default:
            break;
    }
    
    return retval;
}

QRencodeMode bridge_encode_mode(QRCodeEncodingMode mode)
{
    QRencodeMode retval;
    switch (mode) {
        case QRCodeEncodingModeAlphanumeric:
            retval = QR_MODE_AN;
            break;
        case QRCodeEncodingModeBytes:
            retval = QR_MODE_8;
            break;
        case QRCodeEncodingModeKanjiKana:
            retval = QR_MODE_KANJI;
            break;
        case QRCodeEncodingModeNumeric:
            retval = QR_MODE_NUM;
            break;
        default:
            break;
    }
    
    return retval;
}


#pragma mark - Debug Methods

- (void)printCode
{
    if (_dirty)
        [self generateCode];
    
    unsigned char *data = _qrcode->data;
    int width = _qrcode->width;
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < width; j++) {
            unsigned char cur = data[i*width + j];
            printf("%c", (cur & 1 ? 'X' : ' '));
        }
        printf("\n");
    }
}


#pragma mark - Memory Management

- (void)dealloc
{
    [title release];
    [backgroundColor release];
    [foregroundColor release];
    
    if (backgroundGradientColors)
        [backgroundGradientColors release];
    if (foregroundGradientColors)
        [foregroundGradientColors release];
    if (customImage)
        [customImage release];
    
    [encodedData release];
    
    if (_qrcode != NULL)
        QRcode_free(_qrcode);
    if (_generatedImage != NULL)
        CFRelease(_generatedImage);
    
    [super dealloc];
}

@end
