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

//   AssetsFilterSelectionViewControllerTheme.swift

import Foundation
import MacaroonUIKit

struct AssetsFilterSelectionViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    let minimumHorizontalSpacing: LayoutMetric
    let contentEdgeInsets: LayoutPaddings
    
    let title: TextStyle
    let titleMaxWidthRatio: LayoutMetric
    let titleMinHeight: LayoutMetric
    
    let description: TextStyle
    let descriptionTopMargin: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.minimumHorizontalSpacing = 8
        self.contentEdgeInsets = (40, 24, 16, 24)
        
        self.title = [
            .text(Self.getTitle()),
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        self.titleMaxWidthRatio = 0.7
        self.titleMinHeight = 32
        
        self.description = [
            .text(Self.getDescription()),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.descriptionTopMargin = 8
    }
}

extension AssetsFilterSelectionViewControllerTheme {
    private static func getTitle() -> EditText {
        return .attributedString(
            "asset-filter-selection-toggle-title"
                .localized
                .bodyRegular()
        )
    }
    
    private static func getDescription() -> EditText {
        return .attributedString(
            "asset-filter-selection-toggle-description"
                .localized
                .footnoteRegular()
        )
    }
}