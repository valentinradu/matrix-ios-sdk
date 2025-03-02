/*
 Copyright 2020 The Matrix.org Foundation C.I.C
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXSecretStorage.h"

@class MXSession;
@class MXEncryptedSecretContent;

NS_ASSUME_NONNULL_BEGIN

@interface MXSecretStorage ()

/**
 Constructor.
 
 @param mxSession the related 'MXSession' instance.
 */
- (instancetype)initWithMatrixSession:(MXSession *)mxSession  processingQueue:(dispatch_queue_t)processingQueue;

- (nullable MXEncryptedSecretContent *)encryptedZeroStringWithPrivateKey:(NSData*)privateKey iv:(nullable NSData*)iv error:(NSError**)error;

- (nullable MXEncryptedSecretContent *)encryptSecret:(NSString*)unpaddedBase64Secret withSecretId:(nullable NSString*)secretId privateKey:(NSData*)privateKey iv:(nullable NSData*)iv error:(NSError**)error;

- (nullable NSString *)decryptSecretWithSecretId:(NSString*)secretId
                                   secretContent:(MXEncryptedSecretContent*)secretContent
                                  withPrivateKey:(NSData*)privateKey
                                           error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
