// 
// Copyright 2022 The Matrix.org Foundation C.I.C
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

#if DEBUG && os(iOS)

import MatrixSDKCrypto

/// SAS transaction originating from `MatrixSDKCrypto`
@available(iOS 13.0.0, *)
class MXSASTransactionV2: NSObject, MXSASTransaction {
    
    var state: MXSASTransactionState {
        // State as enum will be moved to MatrixSDKCrypto in the future
        // to avoid the mapping of booleans into state
        if sas.isDone {
            return MXSASTransactionStateVerified
        } else if sas.isCancelled {
            return MXSASTransactionStateCancelled
        } else if sas.canBePresented {
            return MXSASTransactionStateShowSAS
        } else if sas.hasBeenAccepted && !sas.haveWeConfirmed {
            return MXSASTransactionStateIncomingShowAccept
        } else if sas.haveWeConfirmed {
            return MXSASTransactionStateOutgoingWaitForPartnerToAccept
        }
        return MXSASTransactionStateUnknown
    }
    
    var sasEmoji: [MXEmojiRepresentation]? {
        do {
            let indices = try handler.emojiIndexes(sas: sas)
            let emojis = MXDefaultSASTransaction.allEmojiRepresentations()
            return indices.compactMap { idx in
                idx < emojis.count ? emojis[idx] : nil
            }
        } catch {
            log.error("Cannot get emoji indices", context: error)
            return nil
        }
    }
    
    var sasDecimal: String? {
        log.debug("Not implemented")
        return nil
    }
    
    var transactionId: String {
        return sas.flowId
    }
    
    let transport: MXKeyVerificationTransport
    
    var isIncoming: Bool {
        return !sas.weStarted
    }
    
    var otherUserId: String {
        return sas.otherUserId
    }
    
    var otherDeviceId: String {
        return sas.otherDeviceId
    }
    
    var reasonCancelCode: MXTransactionCancelCode? {
        guard let info = sas.cancelInfo else {
            return nil
        }
        return MXTransactionCancelCode(
            value: info.cancelCode,
            humanReadable: info.reason
        )
    }
    
    var error: Error? {
        return nil
    }

    var dmRoomId: String? {
        return sas.roomId
    }

    var dmEventId: String? {
        return transactionId
    }
    
    private var sas: Sas
    private let handler: MXCryptoSASVerifying

    private let log = MXNamedLog(name: "MXSASTransactionV2")
    
    init(sas: Sas, transport: MXKeyVerificationTransport, handler: MXCryptoSASVerifying) {
        self.sas = sas
        self.transport = transport
        self.handler = handler
    }
    
    func processUpdates() -> MXKeyVerificationUpdateResult {
        guard
            let verification = handler.verification(userId: otherUserId, flowId: transactionId),
            case .sasV1(let sas) = verification
        else {
            return .removed
        }
        
        guard self.sas != sas else {
            return .noUpdates
        }
        self.sas = sas
        return .updated
    }
    
    func accept() {
        Task {
            do {
                try await handler.acceptSasVerification(userId: otherUserId, flowId: transactionId)
            } catch {
                log.error("Cannot accept transaction", context: error)
            }
        }
    }
    
    func confirmSASMatch() {
        Task {
            do {
                try await handler.confirmVerification(userId: otherUserId, flowId: transactionId)
            } catch {
                log.error("Cannot confirm transaction", context: error)
            }
        }
    }
    
    func cancel(with code: MXTransactionCancelCode) {
        cancel(with: code) {
            // No-op
        } failure: { [weak self] in
            self?.log.error("Cannot cancel transaction", context: $0)
        }
    }
    
    func cancel(with code: MXTransactionCancelCode, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        Task {
            do {
                try await handler.cancelVerification(userId: otherUserId, flowId: transactionId, cancelCode: code.value)
                await MainActor.run {
                    success()
                }
            } catch {
                await MainActor.run {
                    failure(error)
                }
            }
        }
    }
}

#endif
