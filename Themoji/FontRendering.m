//
//  FontTest.m
//  Themoji
//
//  Created by Felix Krause on 07/02/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

#import "FontRendering.h"

@implementation FontRendering

+ (CFDataRef)rawFile {
    static NSData *cachedData = nil;
    if (cachedData) {
        return (__bridge CFDataRef)cachedData;
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Apple Color Emoji" withExtension:@"ttf"];
    cachedData = [NSData dataWithContentsOfURL:url];
    return (__bridge CFDataRef)cachedData;
}

+ (CTFontRef)highResolutionEmojiFontSize:(CGFloat)size
{
    CGFontRef cgfont = CGFontCreateWithDataProvider(CGDataProviderCreateWithCFData([self rawFile]));
    return CTFontCreateWithGraphicsFont(cgfont, size, nil, nil);// 256
}

+ (UIFont *)highResolutionEmojiUIFontSize:(CGFloat)size
{
    return (UIFont *)[self highResolutionEmojiFontSize:size];
}

+ (UIImage *)render:(NSString *)emojiString size:(CGFloat)size
{
    // size should be maximum of 256.0f

    CTFontRef ctFont = [self highResolutionEmojiFontSize:size];

    UniChar *characters = malloc(sizeof(UniChar) * [emojiString length]);
    [emojiString getCharacters:characters range:NSMakeRange(0, [emojiString length])];
    
    CGGlyph *glyphs = malloc(sizeof(CGGlyph) * [emojiString length]);
    CTFontGetGlyphsForCharacters(ctFont, characters, glyphs, [emojiString length]);
    
    CGRect bounds = CTFontGetBoundingRectsForGlyphs(ctFont, kCTFontOrientationHorizontal, glyphs, NULL, 1);
    CGPoint point = CGPointApplyAffineTransform(bounds.origin, CGAffineTransformMakeScale(-1, -1));
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bitmapBounds = (CGRect){ CGPointZero, CGSizeMake(size, size) };
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, CGRectGetHeight(bitmapBounds)));
    CTFontDrawGlyphs(ctFont, glyphs, &point, 1, context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
