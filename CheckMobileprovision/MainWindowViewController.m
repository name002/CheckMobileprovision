//
//  MainWindowViewController.m
//  CheckMobileprovision
//
//  Created by elong on 2017/8/3.
//  Copyright © 2017年 QCxy. All rights reserved.
//

#import "MainWindowViewController.h"
#import "MobileprovisionInfo.h"
#import "NoDragTextView.h"

@interface MainWindowViewController ()

@property (copy) NSMutableArray<MobileprovisionInfo *> *mobileprovisionFilesInfo;

/**
 *  信息
 */
@property (unsafe_unretained) IBOutlet NoDragTextView *entitlementsInfoView;

@end

@implementation MainWindowViewController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    //拖放操作是基于NSView 及其子视图的，首先视图需要注册自己支持拖放操作。如果是主窗口支持拖放，则
    [self.window registerForDraggedTypes:@[NSColorPboardType, NSFilenamesPboardType]];
    //如果主窗口上有子视图，子视图要支持拖放，则子视图也需要注册，否则只有主窗口界面部分可支持拖放，进入子视图区域则不支持
    
//    self.window.contentView
}

//如果是主窗口，则在其控制器类中通过以下方法响应：
// drag and drop support
// when dragging is entered the window's area
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    NSLog(@"drag and drop,type=%@",[pboard types]);
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        }
        else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
        else
            return NSDragOperationGeneric;
    }
    else if([[pboard types] containsObject:NSFileContentsPboardType]){
        NSLog(@"contents");
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

// drag and drop action
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSLog(@"accepting");
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        // if user choose cue, we have to let user grant access to its parent directory
        NSMutableArray *fileURLs = [[NSMutableArray alloc]init];
        for(NSString *file in files){
            [fileURLs addObject:[NSURL fileURLWithPath:file]];
        }
        NSLog(@"drag file=%@",files[0]);
        
        [self handleArchiveFileWithPath:files];
    }
    return YES;
}
//如果是子视图，则需要从它派生出子类，在该类中通过以上方法响应拖放


/**
 *  处理给定mobileprovision文件路径，获取 mobileprovision 对象
 *
 *  @param filePaths mobileprovision 文件路径
 */
- (void)handleArchiveFileWithPath:(NSArray *)filePaths {
    self.mobileprovisionFilesInfo = [NSMutableArray arrayWithCapacity:1];
    for(NSString *filePath in filePaths){
        MobileprovisionInfo *mobileprovisionInfo = [[MobileprovisionInfo alloc] init];
        
        NSString *fileName = filePath.lastPathComponent;
        //支持 xcarchive 文件和 dSYM 文件。
        if ([fileName hasSuffix:@".mobileprovision"]){
            mobileprovisionInfo.filePath = filePath;
            mobileprovisionInfo.fileName = fileName;
            
            
            NSString *commandString = [NSString stringWithFormat:@"security cms -D -i \"%@\"",filePath];
            NSString *output = [self runCommand:commandString];
            
            output = [self string:output replaceStr:@""];
            
            NSData* plistData = [output dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *error;
            NSPropertyListFormat format;
            NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
            
            [_entitlementsInfoView setString:plist.description];
            
            mobileprovisionInfo.content = plist;
            
            NSDictionary *entitlements = plist[@"Entitlements"];
            if (entitlements) {
                mobileprovisionInfo.entitlements = entitlements;
            }
            
            if(!plist){
                NSLog(@"Error: %@",error);
            }
        }else{
            continue;
        }
    }
}

- (NSString  *)string:(NSString *)string  replaceStr:(NSString *)replaceStr{
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:
                                              @"\\<data>.*?\\</data>"
                                                                                       options:0 error:nil];
    
    
    string  = [regularExpression stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:replaceStr];
    return string;
}

- (NSData *)dataFomerunCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = @[@"-c",[NSString stringWithFormat:@"%@", commandToRun]];
    //    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    return data;
}


- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = @[@"-c",
                           [NSString stringWithFormat:@"%@", commandToRun]];
    //    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}


@end
