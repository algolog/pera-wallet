/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.modules.assets.profile.about.ui.mapper

import com.algorand.android.modules.assets.profile.about.ui.model.AssetAboutPreview
import com.algorand.android.modules.assets.profile.about.ui.model.BaseAssetAboutListItem
import javax.inject.Inject

class AssetAboutPreviewMapper @Inject constructor() {

    fun mapToAssetAboutPreviewInitialState(): AssetAboutPreview {
        return AssetAboutPreview(assetAboutListItems = emptyList(), isLoading = true)
    }

    fun mapToAssetAboutPreview(assetAboutListItems: List<BaseAssetAboutListItem>): AssetAboutPreview {
        return AssetAboutPreview(assetAboutListItems = assetAboutListItems, isLoading = false)
    }
}
