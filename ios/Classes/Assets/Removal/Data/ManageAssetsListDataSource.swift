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

//   ManageAssetsListDataSource.swift

import Foundation
import UIKit

final class ManageAssetsListDataSource: UICollectionViewDiffableDataSource<ManageAssetSearchSection, ManageAssetSearchItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case let .asset(item):
                let cell = collectionView.dequeue(AssetPreviewWithActionCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case let .pendingAsset(item):
                let cell = collectionView.dequeue(PendingAssetPreviewCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            case .empty(let item):
                let cell = collectionView.dequeue(NoContentCell.self, at: indexPath)
                cell.bindData(item)
                return cell
            }
        }
        
        collectionView.register(AssetPreviewWithActionCell.self)
        collectionView.register(PendingAssetPreviewCell.self)
        collectionView.register(NoContentCell.self)
    }
}
