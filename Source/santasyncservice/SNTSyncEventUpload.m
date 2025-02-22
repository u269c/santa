/// Copyright 2015 Google Inc. All rights reserved.
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
///
///    Unless required by applicable law or agreed to in writing, software
///    distributed under the License is distributed on an "AS IS" BASIS,
///    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///    See the License for the specific language governing permissions and
///    limitations under the License.

#import "Source/santasyncservice/SNTSyncEventUpload.h"

#import <MOLCertificate/MOLCertificate.h>
#import <MOLXPCConnection/MOLXPCConnection.h>

#import "Source/common/SNTConfigurator.h"
#import "Source/common/SNTFileInfo.h"
#import "Source/common/SNTLogging.h"
#import "Source/common/SNTStoredEvent.h"
#import "Source/common/SNTSyncConstants.h"
#import "Source/common/SNTXPCControlInterface.h"
#import "Source/santasyncservice/NSData+Zlib.h"
#import "Source/santasyncservice/SNTSyncLogging.h"
#import "Source/santasyncservice/SNTSyncState.h"

@implementation SNTSyncEventUpload

- (NSURL *)stageURL {
  NSString *stageName = [@"eventupload" stringByAppendingFormat:@"/%@", self.syncState.machineID];
  return [NSURL URLWithString:stageName relativeToURL:self.syncState.syncBaseURL];
}

- (BOOL)sync {
  dispatch_semaphore_t sema = dispatch_semaphore_create(0);
  [[self.daemonConn remoteObjectProxy] databaseEventsPending:^(NSArray *events) {
    if (events.count) {
      [self uploadEvents:events];
    }
    dispatch_semaphore_signal(sema);
  }];
  return (dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER) == 0);
}

- (BOOL)uploadEvents:(NSArray *)events {
  NSMutableArray *uploadEvents = [[NSMutableArray alloc] init];

  NSMutableSet *eventIds = [NSMutableSet setWithCapacity:events.count];
  for (SNTStoredEvent *event in events) {
    [uploadEvents addObject:[self dictionaryForEvent:event]];
    if (event.idx) [eventIds addObject:event.idx];
    if (uploadEvents.count >= self.syncState.eventBatchSize) break;
  }

  if (!self.syncState.cleanSync || [[SNTConfigurator configurator] enableCleanSyncEventUpload]) {
    NSDictionary *r = [self performRequest:[self requestWithDictionary:@{kEvents : uploadEvents}]];
    if (!r) return NO;

    // A list of bundle hashes that require their related binary events to be uploaded.
    self.syncState.bundleBinaryRequests = r[kEventUploadBundleBinaries];

    SLOGI(@"Uploaded %lu events", uploadEvents.count);
  }

  // Remove event IDs. For Bundle Events the ID is 0 so nothing happens.
  [[self.daemonConn remoteObjectProxy] databaseRemoveEventsWithIDs:[eventIds allObjects]];

  // See if there are any events remaining to upload
  if (uploadEvents.count < events.count) {
    NSRange nextEventsRange = NSMakeRange(uploadEvents.count, events.count - uploadEvents.count);
    NSArray *nextEvents = [events subarrayWithRange:nextEventsRange];
    return [self uploadEvents:nextEvents];
  }

  return YES;
}

- (NSDictionary *)dictionaryForEvent:(SNTStoredEvent *)event {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-literal-conversion"
#define ADDKEY(dict, key, value) \
  if (value) dict[key] = value
  NSMutableDictionary *newEvent = [NSMutableDictionary dictionary];

  ADDKEY(newEvent, kFileSHA256, event.fileSHA256);
  ADDKEY(newEvent, kFilePath, [event.filePath stringByDeletingLastPathComponent]);
  ADDKEY(newEvent, kFileName, [event.filePath lastPathComponent]);
  ADDKEY(newEvent, kExecutingUser, event.executingUser);
  ADDKEY(newEvent, kExecutionTime, @([event.occurrenceDate timeIntervalSince1970]));
  ADDKEY(newEvent, kLoggedInUsers, event.loggedInUsers);
  ADDKEY(newEvent, kCurrentSessions, event.currentSessions);

  switch (event.decision) {
    case SNTEventStateAllowUnknown: ADDKEY(newEvent, kDecision, kDecisionAllowUnknown); break;
    case SNTEventStateAllowBinary: ADDKEY(newEvent, kDecision, kDecisionAllowBinary); break;
    case SNTEventStateAllowCertificate:
      ADDKEY(newEvent, kDecision, kDecisionAllowCertificate);
      break;
    case SNTEventStateAllowScope: ADDKEY(newEvent, kDecision, kDecisionAllowScope); break;
    case SNTEventStateAllowTeamID: ADDKEY(newEvent, kDecision, kDecisionAllowTeamID); break;
    case SNTEventStateAllowSigningID: ADDKEY(newEvent, kDecision, kDecisionAllowSigningID); break;
    case SNTEventStateBlockUnknown: ADDKEY(newEvent, kDecision, kDecisionBlockUnknown); break;
    case SNTEventStateBlockBinary: ADDKEY(newEvent, kDecision, kDecisionBlockBinary); break;
    case SNTEventStateBlockCertificate:
      ADDKEY(newEvent, kDecision, kDecisionBlockCertificate);
      break;
    case SNTEventStateBlockScope: ADDKEY(newEvent, kDecision, kDecisionBlockScope); break;
    case SNTEventStateBlockTeamID: ADDKEY(newEvent, kDecision, kDecisionBlockTeamID); break;
    case SNTEventStateBlockSigningID: ADDKEY(newEvent, kDecision, kDecisionBlockSigningID); break;
    case SNTEventStateBundleBinary:
      ADDKEY(newEvent, kDecision, kDecisionBundleBinary);
      [newEvent removeObjectForKey:kExecutionTime];
      break;
    default: ADDKEY(newEvent, kDecision, kDecisionUnknown);
  }

  ADDKEY(newEvent, kFileBundleID, event.fileBundleID);
  ADDKEY(newEvent, kFileBundlePath, event.fileBundlePath);
  ADDKEY(newEvent, kFileBundleExecutableRelPath, event.fileBundleExecutableRelPath);
  ADDKEY(newEvent, kFileBundleName, event.fileBundleName);
  ADDKEY(newEvent, kFileBundleVersion, event.fileBundleVersion);
  ADDKEY(newEvent, kFileBundleShortVersionString, event.fileBundleVersionString);
  ADDKEY(newEvent, kFileBundleHash, event.fileBundleHash);
  ADDKEY(newEvent, kFileBundleHashMilliseconds, event.fileBundleHashMilliseconds);
  ADDKEY(newEvent, kFileBundleBinaryCount, event.fileBundleBinaryCount);

  ADDKEY(newEvent, kPID, event.pid);
  ADDKEY(newEvent, kPPID, event.ppid);
  ADDKEY(newEvent, kParentName, event.parentName);

  ADDKEY(newEvent, kQuarantineDataURL, event.quarantineDataURL);
  ADDKEY(newEvent, kQuarantineRefererURL, event.quarantineRefererURL);
  ADDKEY(newEvent, kQuarantineTimestamp, @([event.quarantineTimestamp timeIntervalSince1970]));
  ADDKEY(newEvent, kQuarantineAgentBundleID, event.quarantineAgentBundleID);

  NSMutableArray *signingChain = [NSMutableArray arrayWithCapacity:event.signingChain.count];
  for (NSUInteger i = 0; i < event.signingChain.count; ++i) {
    MOLCertificate *cert = [event.signingChain objectAtIndex:i];

    NSMutableDictionary *certDict = [NSMutableDictionary dictionary];
    ADDKEY(certDict, kCertSHA256, cert.SHA256);
    ADDKEY(certDict, kCertCN, cert.commonName);
    ADDKEY(certDict, kCertOrg, cert.orgName);
    ADDKEY(certDict, kCertOU, cert.orgUnit);
    ADDKEY(certDict, kCertValidFrom, @([cert.validFrom timeIntervalSince1970]));
    ADDKEY(certDict, kCertValidUntil, @([cert.validUntil timeIntervalSince1970]));

    [signingChain addObject:certDict];
  }
  newEvent[kSigningChain] = signingChain;
  ADDKEY(newEvent, kTeamID, event.teamID);
  ADDKEY(newEvent, kSigningID, event.signingID);

  return newEvent;
#undef ADDKEY
#pragma clang diagnostic pop
}

@end
