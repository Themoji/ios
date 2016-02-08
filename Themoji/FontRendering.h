//
//  FontTest.h
//  Themoji
//
//  Created by Felix Krause on 07/02/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface FontRendering : NSObject

+ (CTFontRef)highResolutionEmojiFontSize:(CGFloat)size;
+ (UIFont *)highResolutionEmojiUIFontSize:(CGFloat)size;
+ (UIImage *)testImageForEmojiString:(NSString *)emojiString;

@end
