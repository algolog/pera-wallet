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
//   PinLimitViewModel.swift

import MacaroonUIKit

struct PinLimitViewModel: ViewModel {
    private(set) var remainingTime: EditText?

    init(_ remainingTimeInSeconds: Int) {
        bindRemainingTime(remainingTimeInSeconds)
    }
}

extension PinLimitViewModel {
    private mutating func bindRemainingTime(_ remainingTimeInSeconds: Int) {
        guard let remainingTimeInSeconds =
                remainingTimeInSeconds.convertSecondsToHoursMinutesSeconds() else {
            return
        }

        remainingTime = .attributedString(
            remainingTimeInSeconds
                .largeTitleMonoRegular(
                    alignment: .center
                )
        )
    }
}
