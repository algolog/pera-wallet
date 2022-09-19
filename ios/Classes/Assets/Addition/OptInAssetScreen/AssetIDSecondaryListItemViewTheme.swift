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

//   AssetIDSecondaryListItemViewTheme.swift

import Foundation
import MacaroonUIKit

struct AssetIDSecondaryListItemViewTheme: SecondaryListItemViewTheme {
    var contentEdgeInsets: LayoutPaddings
    var title: TextStyle
    var titleMinWidthRatio: LayoutMetric
    var titleMaxWidthRatio: LayoutMetric
    var minimumSpacingBetweenTitleAndAccessory: LayoutMetric
    var accessory: SecondaryListItemValueViewTheme

    init(
        _ family: LayoutFamily
    ) {
        contentEdgeInsets = (10, 24, 10, 24)
        title = []
        titleMinWidthRatio = 0.2
        titleMaxWidthRatio = 0.35
        minimumSpacingBetweenTitleAndAccessory = 12
        accessory = AssetIDSecondaryListItemValueViewTheme()
    }
}

struct AssetIDSecondaryListItemValueViewTheme: SecondaryListItemValueViewTheme {
    var backgroundImage: ImageStyle
    var view: ViewStyle
    var contentEdgeInsets: LayoutPaddings
    var iconLayoutOffset: LayoutOffset
    var title: TextStyle

    init(
        _ family: LayoutFamily
    ) {
        backgroundImage = [
            .image("components/buttons/copy/bg".templateImage),
            .tintColor(Colors.Layer.grayLighter),
            .isInteractable(false)
        ]
        view = [
            .isInteractable(true)
        ]
        contentEdgeInsets = (6, 12, 6, 12)
        iconLayoutOffset = (0, 0)
        title = []
    }
}
