//
//  FontTest.m
//  Themoji
//
//  Created by Felix Krause on 07/02/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

#import "FontRendering.h"

@implementation FontRendering

+ (CTFontRef)highResolutionEmojiFontSize:(CGFloat)size
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Apple Color Emoji" withExtension:@"ttf"];
    NSData *contents = [NSData dataWithContentsOfURL:url];
    CGFontRef cgfont = CGFontCreateWithDataProvider(CGDataProviderCreateWithCFData((CFDataRef) contents));
    return CTFontCreateWithGraphicsFont(cgfont, size, nil, nil);// 256
}

+ (UIFont *)highResolutionEmojiUIFontSize:(CGFloat)size
{
    return (UIFont *)[self highResolutionEmojiFontSize:size];
}

+ (UIImage *)testImageForEmojiString:(NSString *)emojiString
{
    CTFontRef ctFont = [self highResolutionEmojiFontSize:256.0];

    UniChar *characters = malloc(sizeof(UniChar) * [emojiString length]);
    [emojiString getCharacters:characters range:NSMakeRange(0, [emojiString length])];
    
    CGGlyph *glyphs = malloc(sizeof(CGGlyph) * [emojiString length]);
    CTFontGetGlyphsForCharacters(ctFont, characters, glyphs, [emojiString length]);
    
    CGRect bounds = CTFontGetBoundingRectsForGlyphs(ctFont, kCTFontOrientationHorizontal, glyphs, NULL, 1);
    CGPoint point = CGPointApplyAffineTransform(bounds.origin, CGAffineTransformMakeScale(-1, -1));
    
    CGFloat size = 256.0f;
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
