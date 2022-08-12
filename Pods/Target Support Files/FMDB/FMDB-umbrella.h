#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "fmdb/FMDatabase.h"
#import "fmdb/FMDatabaseAdditions.h"
#import "fmdb/FMDatabasePool.h"
#import "fmdb/FMDatabaseQueue.h"
#import "fmdb/FMDB.h"
#import "fmdb/FMResultSet.h"

FOUNDATION_EXPORT double FMDBVersionNumber;
FOUNDATION_EXPORT const unsigned char FMDBVersionString[];

