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

+ (UIImage *)testImageForEmojiString:(NSString *)emojiString withFont:(CTFontRef)ctFont;

@end
