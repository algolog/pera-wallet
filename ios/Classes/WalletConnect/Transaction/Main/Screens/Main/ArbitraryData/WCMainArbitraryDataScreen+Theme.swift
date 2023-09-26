// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCMainArbitraryDataScreen+Theme.swift

import Foundation
import MacaroonUIKit
import UIKit

extension WCMainArbitraryDataScreen {
    struct Theme: LayoutSheet, StyleSheet {
        let backgroundColor: UIColor
        let fragmentRadius: LayoutMetric
        let fragmentTopInset: LayoutMetric
        let dappViewTopInset: LayoutMetric
        let dappViewLeadingInset: LayoutMetric

        init(_ family: LayoutFamily) {
            self.fragmentRadius = 10
            self.fragmentTopInset = 200
            self.backgroundColor = .black
            self.dappViewTopInset = 32
            self.dappViewLeadingInset = 24
        }
    }
}
