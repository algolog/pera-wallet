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

package com.algorand.android.modules.assets.filter.data.local

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject

class AssetFilterDisplayOptedInNFTLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<Boolean>(sharedPreferences) {

    override val key: String
        get() = ASSET_FILTER_DISPLAY_OPTED_IN_NFT_KEY

    override fun getData(defaultValue: Boolean): Boolean {
        return sharedPref.getBoolean(key, defaultValue)
    }

    override fun getDataOrNull(): Boolean? {
        return with(sharedPref) {
            if (contains(ASSET_FILTER_DISPLAY_OPTED_IN_NFT_KEY)) {
                getBoolean(ASSET_FILTER_DISPLAY_OPTED_IN_NFT_KEY, false)
            } else {
                null
            }
        }
    }

    override fun saveData(data: Boolean) {
        saveData { it.putBoolean(key, data) }
    }

    companion object {
        private const val ASSET_FILTER_DISPLAY_OPTED_IN_NFT_KEY = "asset_filter_display_opted_in_nft_key"
    }
}
