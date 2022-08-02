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

//   AccountAssetAscendingTitleAlgorithm.swift

import Foundation

struct AccountAssetAscendingTitleAlgorithm: AccountAssetSortingAlgorithm {
    let id: String
    let name: String

    init() {
        self.id = "cache.value.accountAssetAscendingTitleAlgorithm"
        self.name = "title-alphabetically-a-to-z".localized
    }
}

extension AccountAssetAscendingTitleAlgorithm {
    func getFormula(
        assetPreview: AssetPreviewModel,
        otherAssetPreview: AssetPreviewModel
    ) -> Bool {

        let firstAssetTitle =
        assetPreview.title ??
        assetPreview.subtitle

        let secondAssetTitle =
        otherAssetPreview.title ??
        otherAssetPreview.subtitle

        guard let assetTitle = firstAssetTitle, !assetTitle.isEmptyOrBlank else {
            return false
        }

        guard let otherAssetTitle = secondAssetTitle, !otherAssetTitle.isEmptyOrBlank else {
            return true
        }

        let comparison = assetTitle.localizedCaseInsensitiveCompare(otherAssetTitle)
        return comparison == .orderedAscending
    }
}
