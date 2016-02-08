//
//  FontTest.m
//  Themoji
//
//  Created by Felix Krause on 07/02/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

#import "FontTest.h"

@implementation FontTest

+ (UIImage *)testImageForEmojiString:(NSString *)emojiString withFont:(CTFontRef)ctFont {
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
