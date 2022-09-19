// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   WCSessionRejectedEvent.swift

import Foundation
import MacaroonVendors

struct WCSessionRejectedEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        topic: String,
        dappName: String,
        dappURL: String
    ) {
        self.name = .wcSessionRejected
        self.metadata = [
            .wcSessionTopic: topic,
            .dappName: dappName,
            .dappURL: dappURL
        ]
    }
}

extension AnalyticsEvent where Self == WCSessionRejectedEvent {
    static func wcSessionRejected(
        topic: String,
        dappName: String,
        dappURL: String
    ) -> Self {
        return WCSessionRejectedEvent(
            topic: topic,
            dappName: dappName,
            dappURL: dappURL
        )
    }
}
