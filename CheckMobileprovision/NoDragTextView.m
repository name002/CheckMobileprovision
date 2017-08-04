//
//  NoDragTextView.m
//  CheckMobileprovision
//
//  Created by elong on 2017/8/4.
//  Copyright © 2017年 QCxy. All rights reserved.
//

#import "NoDragTextView.h"

@implementation NoDragTextView

- (NSArray *)acceptableDragTypes
{
    return nil;
}
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationNone;
}
- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    return NSDragOperationNone;
}

@end
