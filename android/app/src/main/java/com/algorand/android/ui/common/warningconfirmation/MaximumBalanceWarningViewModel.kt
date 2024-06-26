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

package com.algorand.android.ui.common.warningconfirmation

import javax.inject.Inject
import com.algorand.android.core.BaseViewModel
import com.algorand.android.utils.AccountCacheManager
import dagger.hilt.android.lifecycle.HiltViewModel
import java.math.BigInteger

@HiltViewModel
class MaximumBalanceWarningViewModel @Inject constructor(
    private val accountCacheManager: AccountCacheManager
) : BaseViewModel() {

    fun getMinimumBalance(address: String): BigInteger {
        return accountCacheManager.getMinBalanceOfAccount(address)
    }

    fun getAccountName(address: String) = accountCacheManager.getAccountName(address).orEmpty()

    fun getAssetCountWithoutAlgoOfAnAccount(address: String): Int {
        val assetCount = accountCacheManager.getAccountAssetCount(address) ?: return 0
        return assetCount - 1
    }
}
