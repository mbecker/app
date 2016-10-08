//
//  NSArray+Diffing.m
//  AsyncDisplayKit
//
//  Created by Levi McCallum on 1/29/16.
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//

#import "NSArray+Diffing.h"
#import "ASAssert.h"

@implementation NSArray (Diffing)

- (void)asdk_diffWithArray:(NSArray *)array insertions:(NSIndexSet **)insertions deletions:(NSIndexSet **)deletions
{
  [self asdk_diffWithArray:array insertions:insertions deletions:deletions compareBlock:^BOOL(id lhs, id rhs) {
    return [lhs isEqual:rhs];
  }];
}

- (void)asdk_diffWithArray:(NSArray *)array insertions:(NSIndexSet **)insertions deletions:(NSIndexSet **)deletions compareBlock:(BOOL (^)(id lhs, id rhs))comparison
{
  NSAssert(comparison != nil, @"Comparison block is required");
  NSIndexSet *commonIndexes = [self _asdk_commonIndexesWithArray:array compareBlock:comparison];
  
  if (insertions) {
    NSArray *commonObjects = [self objectsAtIndexes:commonIndexes];
    NSMutableIndexSet *insertionIndexes = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0, j = 0; i < commonObjects.count || j < array.count;) {
      if (i < commonObjects.count && j < array.count && comparison(commonObjects[i], array[j])) {
        i++; j++;
      } else {
        [insertionIndexes addIndex:j];
        j++;
      }
    }
    *insertions = insertionIndexes;
  }
  
  if (deletions) {
    NSMutableIndexSet *deletionIndexes = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < self.count; i++) {
      if (![commonIndexes containsIndex:i]) {
        [deletionIndexes addIndex:i];
      }
    }
    *deletions = deletionIndexes;
  }
}

- (NSIndexSet *)_asdk_commonIndexesWithArray:(NSArray *)array compareBlock:(BOOL (^)(id lhs, id rhs))comparison
{
  NSAssert(comparison != nil, @"Comparison block is required");
  
  NSInteger selfCount = self.count;
  NSInteger arrayCount = array.count;
  
  // Allocate the diff map in the heap so we don't blow the stack for large arrays.
  NSInteger (*lengths)[arrayCount+1] = NULL;
  size_t lengthsSize = ((selfCount+1) * sizeof(*lengths));
  // Would rather use initWithCapacity: to skip the zeroing, but TECHNICALLY
  // `mutableBytes` is only guaranteed to be non-NULL if the data object has a non-zero length.
  NS_VALID_UNTIL_END_OF_SCOPE NSMutableData *lengthsData = [[NSMutableData alloc] initWithLength:lengthsSize];
  lengths = lengthsData.mutableBytes;
  if (lengths == NULL) {
    ASDisplayNodeFailAssert(@"Failed to allocate memory for diffing with size %tu", lengthsSize);
    return nil;
  }
  
  for (NSInteger i = 0; i <= selfCount; i++) {
    id selfObj = i > 0 ? self[i-1] : nil;
    for (NSInteger j = 0; j <= arrayCount; j++) {
      if (i == 0 || j == 0) {
        lengths[i][j] = 0;
      } else if (comparison(selfObj, array[j-1])) {
        lengths[i][j] = 1 + lengths[i-1][j-1];
      } else {
        lengths[i][j] = MAX(lengths[i-1][j], lengths[i][j-1]);
      }
    }
  }
  
  NSMutableIndexSet *common = [NSMutableIndexSet indexSet];
  NSInteger i = selfCount, j = arrayCount;
  while(i > 0 && j > 0) {
    if (comparison(self[i-1], array[j-1])) {
      [common addIndex:(i-1)];
      i--; j--;
    } else if (lengths[i-1][j] > lengths[i][j-1]) {
      i--;
    } else {
      j--;
    }
  }
  
  return common;
}

@end
