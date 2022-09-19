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
//  Toggle.swift

import UIKit
import MacaroonUIKit

final class Toggle: UISwitch {
    private lazy var theme = Theme()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func customize(_ theme: Theme) {
        layer.cornerRadius = theme.cornerRadius
        backgroundColor = theme.backgroundColor.uiColor
        onTintColor = theme.onTintColor.uiColor
    }
}

extension Toggle {
    struct Theme: LayoutSheet, StyleSheet {
        let cornerRadius: LayoutMetric
        let backgroundColor: Color
        let onTintColor: Color

        init(_ family: LayoutFamily) {
            cornerRadius = 16
            backgroundColor = Colors.Switches.offBackground
            onTintColor = Colors.Switches.background
        }
    }
}
