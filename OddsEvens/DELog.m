//
//  DELog.m
//  DEKit
//
//  Created by Douglas Ellis on 6/20/15.
//  Copyright (c) 2015 Doug Ellis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DELog.h"

@interface DELog ()

@property NSFileHandle *logFile;
@property NSDateFormatter *formatter;

- (void)openLogFile;
- (void)truncateLog;

@end

static const char *levelMap[]={
    "BASE",
    "DEBUG",
    "TRACE",
    "TRACE",
    "TRACE",
    "MSG",
    "WARN",
    "ERROR",
    "FATAL",
    "LAST"};

@implementation DELog

+ (DELog *)sharedInstance {
    static id theInstance=nil;
    
    if (!theInstance) {
        theInstance=[[DELog alloc] init];
    }
    
    return theInstance;
}

- init {
    self=[super init];
    _loggingEnabled=NO;
    _logFile=nil;
    _formatter=[[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"y-M-d H:m:s:ms"];
    [self setLogLevel:DELOG_Last];
    [self setLogFileName:nil];
    return self;
}


- (void)logAt:(DELogLevelType)level msg:(NSString *)pattern, ...
{
    va_list ap;
    
    va_start (ap, pattern);
    [self vlogAt:level pat:pattern vals:ap];
    va_end (ap);
}

#define INDENT 2
- (void)vlogAt:(DELogLevelType)level pat:(NSString *)pattern vals:(va_list)ap
{
    NSString *baseString, *indentString;
    NSString *dateString, *logString;
    //NSDate *date;
    static int indent=0;
    
    if ((!_loggingEnabled) || (level < _logLevel) || (level >= DELOG_Last)) {
        return;
    }
    
    // Open the file if it isn't open
    if (!_logFile) {
        [self openLogFile];
    }
    
    // Manage indentation
    if (level == DELOG_Tracei) {
        indent++;
    }
    
    // Construct all the pieces
    indentString=[NSString stringWithFormat:@"%*.*s", indent*INDENT, indent*INDENT, ""];
    baseString=[[NSString alloc] initWithFormat:pattern arguments:ap];

    
    logString=[NSString stringWithFormat:@"%@(%5.5s) %@\n",
               indentString, levelMap[level], baseString];
    
    if (_loggingEnabled && level >= _logLevel && level < DELOG_Last) {
        
        NSLog(@"%@",logString);
       
        // Send to File
        if (_logFile) {
            
            //date=[NSDate date];
            //dateString=[_formatter stringFromDate:date];
            dateString=@"";
            
            logString=[NSString stringWithFormat:@"%@(%5.5s) %@ %@\n",
                       indentString, levelMap[level], dateString, baseString];
            
            NSData *dataForFile=[NSData dataWithBytes:[logString cStringUsingEncoding:NSUTF8StringEncoding]
                                               length:[logString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];

            [_logFile writeData:dataForFile];
            [_logFile synchronizeFile];

        }
    }
    
    // Manage indentation
    if (level == DELOG_Traceo && indent > 0) {
        indent--;
    }
}


// Convenience Methods
- (void)logDebug:(NSString *)pattern, ...
{
    va_list ap;
    
    va_start (ap, pattern);
    [self vlogAt:DELOG_Debug pat:pattern vals:ap];
    va_end (ap);
}

- (void)logTracei:(NSString *)pattern, ...;
{
    va_list ap;
    
    va_start (ap, pattern);
    [self vlogAt:DELOG_Tracei pat:pattern vals:ap];
    va_end (ap);
}

- (void)logTrace:(NSString *)pattern, ...;
{
    va_list ap;
    
    va_start (ap, pattern);
    [self vlogAt:DELOG_Trace pat:pattern vals:ap];
    va_end (ap);
}

- (void)logTraceo:(NSString *)pattern, ...;
{
    va_list ap;
    
    va_start (ap, pattern);
    [self vlogAt:DELOG_Traceo pat:pattern vals:ap];
    va_end (ap);
}

- (void)logMsg:(NSString *)pattern, ...;
{
    va_list ap;
    
    va_start (ap, pattern);
    [self vlogAt:DELOG_Msg pat:pattern vals:ap];
    va_end (ap);
}

- (void)logWarn:(NSString *)pattern, ...;
{
    va_list ap;
    
    va_start (ap, pattern);
    [self vlogAt:DELOG_Warn pat:pattern vals:ap];
    va_end (ap);
}

- (void)logError:(NSString *)pattern, ...;
{
    va_list ap;
    
    va_start (ap, pattern);
    [self vlogAt:DELOG_Error pat:pattern vals:ap];
    va_end (ap);
}

- (void)logFatal:(NSString *)pattern, ...;
{
    va_list ap;
    
    va_start (ap, pattern);
    [self vlogAt:DELOG_Fatal pat:pattern vals:ap];
    va_end (ap);
}

- (void)openLogFile
{
    BOOL result;
    
    // if the filename is nil, use default
    if (!_logFileName) {
        [self setLogFileName:[NSString stringWithFormat:@"/tmp/%@_%@.log",
                              [[NSProcessInfo processInfo] processName],
                              [[NSProcessInfo processInfo] globallyUniqueString]]];
    }
    
    // if we already had a file open, close it
    if (_logFile) {
        [_logFile closeFile];
    }
    
    // Create the file
    result=[[NSFileManager defaultManager] isWritableFileAtPath:_logFileName];
    if (!result) {
        result=[[NSFileManager defaultManager] createFileAtPath:_logFileName contents:nil attributes:nil];
        if (!result) {
            NSLog(@"Error creating file (%@)",_logFileName);
            _logFile=nil;
            return;
        }
    }
    
    // Open the file
    _logFile=[NSFileHandle fileHandleForWritingAtPath:_logFileName];
    if (!_logFile) {
        NSLog(@"Error opening file (%@)",_logFileName);
        _logFile=nil;
        return;
    }
    [_logFile seekToEndOfFile];
}

- (void)truncateLog {
    if (_logFile) {
        [_logFile truncateFileAtOffset:0];
    }
}


@end
