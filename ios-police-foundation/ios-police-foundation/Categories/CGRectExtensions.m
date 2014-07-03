//
//  CGRectExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/30/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "CGRectExtensions.h"

CGRect CGRectSetWidth(CGRect rect, CGFloat width) {
    return CGRectMake(rect.origin.x, rect.origin.y, width, rect.size.height);
}

CGRect CGRectSetHeight(CGRect rect, CGFloat height) {
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height);
}

CGRect CGRectSetSize(CGRect rect, CGSize size) {
    return CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height);
}

CGRect CGRectSetX(CGRect rect, CGFloat x) {
    return CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height);
}

CGRect CGRectSetY(CGRect rect, CGFloat y) {
    return CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
}

CGRect CGRectSetOrigin(CGRect rect, CGPoint origin) {
    return CGRectMake(origin.x, origin.y, rect.size.width, rect.size.height);
}