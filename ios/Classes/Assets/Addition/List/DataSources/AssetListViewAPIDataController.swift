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
//   AssetListViewAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class AssetListViewAPIDataController:
    AssetListViewDataController {
    var eventHandler: ((AssetListViewDataControllerEvent) -> Void)?

    var assets: [AssetDecoration] = []

    private var lastSnapshot: Snapshot?

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)
    private var ongoingEndpoint: EndpointOperatable?

    private let api: ALGAPI
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.assetListViewDataController")

    private let filter: AssetSearchFilter

    private var nextCursor: String?

    private var hasNext: Bool {
        return nextCursor != nil
    }

    init(
        _ api: ALGAPI,
        filter: AssetSearchFilter
    ) {
        self.api = api
        self.filter = filter
    }

}

extension AssetListViewAPIDataController {
    func load(isPaginated: Bool = false) {
        if !isPaginated {
            deliverLoadingSnapshot()
        }

        load(with: nil)
    }

    func search(for query: String?) {
        searchThrottler.performNext {
            [weak self] in

            guard let self = self else {
                return
            }

            self.resetSearch()

            self.load(with: query)
        }
    }

    func resetSearch() {
        nextCursor = nil
    }

    func loadNextPageIfNeeded(for indexPath: IndexPath) {
        guard indexPath.item == assets.count - 3, hasNext else {
            return
        }

        load(with: nil, isPaginated: true)
    }

    private func load(with query: String?, isPaginated: Bool = false) {
        cancelOngoingEndpoint()
        let searchDraft = AssetSearchQuery(status: filter, query: query, cursor: nextCursor)

        ongoingEndpoint =
        api.searchAssets(
            searchDraft,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            switch response {
            case let .success(searchResults):
                guard let self = self else {
                    return
                }

                if isPaginated {
                    let results = self.assets + searchResults.results
                    self.assets = results.uniqued()
                } else {
                    self.assets = searchResults.results.uniqued()
                }

                self.deliverContentSnapshot()
                self.nextCursor = searchResults.nextCursor
            case .failure:
                break
            }
        }
    }

    private func cancelOngoingEndpoint() {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}

extension AssetListViewAPIDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.assets])
            snapshot.appendItems([.loading("1"), .loading("2")], toSection: .assets)
            return snapshot
        }
    }

    private func deliverContentSnapshot() {
        guard !self.assets.isEmpty else {
            deliverNoContentSnapshot()
            return
        }

        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()
            var assetItems: [AssetListViewItem] = []

            for asset in self.assets {
                let viewModel: AssetPreviewViewModel

                if asset.isCollectible {
                    let collectibleAsset = CollectibleAsset(
                        asset: ALGAsset(id: asset.id),
                        decoration: asset
                    )
                    viewModel = AssetPreviewViewModel(
                        CollectibleAssetPreviewAdditionDraft(asset: collectibleAsset)
                    )

                } else {
                    let standardAsset = StandardAsset(
                        asset: ALGAsset(id: asset.id),
                        decoration: asset
                    )
                    viewModel = AssetPreviewViewModel(
                        StandardAssetPreviewAdditionDraft(asset: standardAsset)
                    )
                }
                
                assetItems.append(.asset(viewModel))
            }

            snapshot.appendSections([.assets])
            snapshot.appendItems(
                assetItems,
                toSection: .assets
            )

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.noContent],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }

            let newSnapshot = snapshot()

            self.lastSnapshot = newSnapshot
            self.publish(.didUpdate(newSnapshot))
        }
    }
}

extension AssetListViewAPIDataController {
    private func publish(
        _ event: AssetListViewDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}
