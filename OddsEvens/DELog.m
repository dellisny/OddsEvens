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

@property NSFileHandle *de_logFile;
@property DELogLevelType de_logLevel;
@property NSString *de_logFileName;
@property BOOL de_logEnabled;
@property NSDateFormatter *de_formatter;

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
    _de_logEnabled=NO;
    _de_logFile=nil;
    _de_formatter=[[NSDateFormatter alloc] init];
    [_de_formatter setDateFormat:@"y-M-d H:m:s:ms"];
    [self setLogLevel:DELOG_Last];
    [self setLogFileName:nil];
    return self;
}


- (DELogLevelType)logLevel {
    return _de_logLevel;
}

- (void)setLogLevel:(DELogLevelType)level {
    _de_logLevel=level;
    if (level>=DELOG_Last) {
        [self setLoggingEnabled:NO];
    } else {
        [self setLoggingEnabled:YES];
    }
}


- (BOOL)loggingEnabled
{
    return _de_logEnabled;
}

- (void)setLoggingEnabled:(BOOL)flag
{
    _de_logEnabled=flag;
    if (_de_logEnabled) {
        if (_de_logFileName) {
            [self openLogFile];
        }
    }
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
    NSDate *date;
    static int indent=0;
    
    if ((!_de_logEnabled) || (level < _de_logLevel) || (level >= DELOG_Last)) {
        return;
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
    
    if (_de_logEnabled && level >= _de_logLevel && level < DELOG_Last) {
        
        NSLog(@"%@",logString);
       
        // Send to File
        if (_de_logFile) {
            date=[NSDate date];
            dateString=[_de_formatter stringFromDate:date];
            
            logString=[NSString stringWithFormat:@"%@(%5.5s) %@ %@\n",
                       indentString, levelMap[level], dateString, baseString];
            
            NSData *dataForFile=[NSData dataWithBytes:[logString cStringUsingEncoding:NSUTF8StringEncoding]
                                               length:[logString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];

            [_de_logFile writeData:dataForFile];
            [_de_logFile synchronizeFile];

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
    
    // If we alrady have file open, return
    if (_de_logFile) {
        return;
    }
    
    result=[[NSFileManager defaultManager] isWritableFileAtPath:_de_logFileName];
    if (!result) {
        result=[[NSFileManager defaultManager] createFileAtPath:_de_logFileName contents:nil attributes:nil];
        if (!result) {
            //[NSException raise:@"DEFileCreateionException"
            //            format:@"Failed to create log file (%@)", _de_logFileName];
            _de_logFile=nil;
            return;
        }
    }
    
    _de_logFile=[NSFileHandle fileHandleForWritingAtPath:_de_logFileName];
    if (!_de_logFile) {
        //[NSException raise:@"DEFileOpenException"
        //            format:@"Failed to open log file (%@)", _de_logFileName];
        _de_logFile=nil;
        return;
    }
    [_de_logFile seekToEndOfFile];
}

- (void)truncateLog {
    if (_de_logFile) {
        [_de_logFile truncateFileAtOffset:0];
    }
}

- (void)setLogFileName:(NSString *)aFile {
    
    [self setDe_logFileName:[NSString stringWithFormat:@"/tmp/%@_%@.log",
                             [[NSProcessInfo processInfo] processName],
                             [[NSProcessInfo processInfo] globallyUniqueString]]];

    if (aFile != _de_logFileName) {
        if (_de_logFile) {
            [_de_logFile closeFile];
            _de_logFile=nil;
        }
    }
}

- (NSString *)logFileName {
    return _de_logFileName;
}

@end
