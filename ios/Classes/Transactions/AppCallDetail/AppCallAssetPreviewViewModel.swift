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

//   AppCallAssetPreviewViewModel.swift

import Foundation
import MacaroonUIKit

struct AppCallAssetPreviewViewModel:
    ViewModel {
    private(set) var title: EditText?
    private(set) var accessoryIcon: Image?
    private(set) var subtitle: EditText?

    init(
        asset: StandardAsset
    ) {
        bindTitle(asset)
        bindAccessoryIcon(asset)
        bindSubtitle(asset)
    }
}

extension AppCallAssetPreviewViewModel {
    mutating func bindTitle(
        _ asset: StandardAsset
    ) {
        let name = asset.presentation.name

        title =  .attributedString(
            (name.isNilOrEmpty ? "title-unknown".localized : name!)
                .bodyRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }

    mutating func bindAccessoryIcon(
        _ asset: StandardAsset
    ) {
        if asset.presentation.isVerified {
            accessoryIcon = "icon-verified-shield"
            return
        }
    }

    mutating func bindSubtitle(
        _ asset: StandardAsset
    ) {
        subtitle = .attributedString(
            String(asset.id)
                .footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
}
