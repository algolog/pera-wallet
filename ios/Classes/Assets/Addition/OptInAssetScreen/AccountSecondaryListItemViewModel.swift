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

//   AccountSecondaryListItemViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AccountSecondaryListItemViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: SecondaryListItemValueViewModel?

    init(
        account: Account
    ) {
        bindTitle()
        accessory = AccountSecondaryListItemValueViewModel(account: account)
    }
}

extension AccountSecondaryListItemViewModel {
    private mutating func bindTitle() {
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))

        title = "title-account"
            .localized
            .attributed(attributes)
    }
}

struct AccountSecondaryListItemValueViewModel: SecondaryListItemValueViewModel {
    var icon: ImageStyle?
    var title: TextProvider?

    init(account: Account) {
        bindIcon(account)
        bindTitle(account: account)
    }
}

extension AccountSecondaryListItemValueViewModel {
    private mutating func bindTitle(account: Account) {
        let name: String
        let lineBreakMode: NSLineBreakMode
        if let accountName = account.name.unwrapNonEmptyString() {
            name = accountName
            lineBreakMode = .byTruncatingTail
        } else {
            name = account.address.shortAddressDisplay
            lineBreakMode = .byTruncatingMiddle
        }

        var attributes = Typography.bodyRegularAttributes(lineBreakMode:lineBreakMode)
        attributes.insert(.textColor(Colors.Text.main))

        title = name.attributed(attributes)
    }

    private mutating func bindIcon(
        _ account: Account
    ) {
        let image = account.typeImage
        let resizedImage =
            image
                .convert(to: CGSize((24, 24)))
                .unwrap(or: image)

        icon = [
            .image(resizedImage),
            .contentMode(.left)
        ]
    }
}
