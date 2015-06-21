//
//  DELog.h
//  DEKit
//
//  Created by Douglas Ellis on 6/20/15.
//  Copyright (c) 2015 Doug Ellis. All rights reserved.
//
//
//  DELog is an object which provides a general purpose interface to logging
//  for applications.
//

#ifndef DEKit_DELog_h
#define DEKit_DELog_h

#endif

typedef enum _DELogLevelType : NSUInteger {
    DELOG_Base = 0,     /* Lowest value, allows us to set DELog to view all */
    DELOG_Debug,        /* This is a debug message */
    DELOG_Tracei,       /* Trace with indentation (upon entering a method) */
    DELOG_Trace,        /* Trace at current level of indentation (inside method) */
    DELOG_Traceo,       /* Trace with indentation (before exiting a method) */
    DELOG_Msg,          /* This is for general messages */
    DELOG_Warn,         /* Warning message */
    DELOG_Error,        /* Error messages */
    DELOG_Fatal,        /* Fatal error message */
    DELOG_Last          /* Last value */
} DELogLevelType;

@interface DELog : NSObject


/*
 *  This method gives access to the one and only instance of this class.
 *  The first time it is invoked, the shared instance is created.
 */
+ (DELog *)sharedInstance;

@property id delegate;
@property BOOL loggingEnabled;
@property DELogLevelType logLevel;
@property NSString *logFileName;

- (void)logAt:(DELogLevelType)level msg:(NSString *)pattern, ...;
- (void)vlogAt:(DELogLevelType)level pat:(NSString *)pattern vals:(va_list)ap;

/*
 *  Convenience Methods
 */
- (void)logDebug:(NSString *)pattern, ...;
- (void)logTracei:(NSString *)pattern, ...;
- (void)logTrace:(NSString *)pattern, ...;
- (void)logTraceo:(NSString *)pattern, ...;
- (void)logMsg:(NSString *)pattern, ...;
- (void)logWarn:(NSString *)pattern, ...;
- (void)logError:(NSString *)pattern, ...;
- (void)logFatal:(NSString *)pattern, ...;

@end



