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

//   UISheetActionScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol UISheetActionScreenTheme:
    StyleSheet,
    LayoutSheet {
    var contextEdgeInsets: LayoutPaddings { get }
    var title: TextStyle { get }
    var spacingBetweenTitleAndBody: LayoutMetric { get }
    var body: TextStyle { get }
    var actionSpacing: LayoutMetric { get }
    var actionsEdgeInsets: LayoutPaddings { get }
    var actionContentEdgeInsets: LayoutPaddings { get }

    func getActionStyle(
        _ style: UISheetAction.Style,
        title: String
    ) -> ButtonStyle
}

extension UISheetActionScreenTheme {
    func getActionStyle(
          _ style: UISheetAction.Style,
          title: String
      ) -> ButtonStyle {
          switch style {
          case .default:
              return [
                  .title(title),
                  .font(Typography.bodyMedium()),
                  .titleColor([ .normal(Colors.Button.Primary.text) ]),
                  .backgroundImage([
                      .normal("components/buttons/primary/bg"),
                      .highlighted("components/buttons/primary/bg-highlighted"),
                  ])
              ]
          case .cancel:
              return [
                  .title(title),
                  .font(Typography.bodyMedium()),
                  .titleColor([ .normal(Colors.Button.Secondary.text) ]),
                  .backgroundImage([
                      .normal("components/buttons/secondary/bg"),
                      .highlighted("components/buttons/secondary/bg-highlighted"),
                  ])
              ]
          }
      }
}

struct UISheetActionScreenCommonTheme:
    UISheetActionScreenTheme {
    var contextEdgeInsets: LayoutPaddings
    var title: TextStyle
    var spacingBetweenTitleAndBody: LayoutMetric
    var body: TextStyle
    var actionSpacing: LayoutMetric
    var actionsEdgeInsets: LayoutPaddings
    var actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        contextEdgeInsets = (36, 24, 24, 24)
        title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        spacingBetweenTitleAndBody = 16
        body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyRegular())
        ]
        actionSpacing = 16
        actionsEdgeInsets = (8, 24, 16, 24)
        actionContentEdgeInsets = (16, 24, 16, 24)
    }
}
