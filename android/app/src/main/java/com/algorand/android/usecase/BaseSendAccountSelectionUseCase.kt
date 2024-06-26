/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.models.AccountInformation
import com.algorand.android.models.Result
import com.algorand.android.modules.accountasset.GetAccountAssetUseCase
import com.algorand.android.modules.accountasset.domain.model.AccountAssetDetail
import kotlinx.coroutines.CoroutineScope

open class BaseSendAccountSelectionUseCase(
    private val accountInformationUseCase: AccountInformationUseCase,
    private val getAccountAssetUseCase: GetAccountAssetUseCase
) {

    suspend fun fetchAccountInformation(toAddress: String, coroutineScope: CoroutineScope): Result<AccountInformation> {
        return when (
            val accountInformationResult = accountInformationUseCase.getAccountInformationAndFetchAssets(
                toAddress,
                coroutineScope
            )
        ) {
            is Result.Success -> Result.Success(accountInformationResult.data)
            is Result.Error -> Result.Error(accountInformationResult.exception)
        }
    }

    suspend fun fetchAccountInformationForAsset(toAddress: String, assetId: Long): Result<AccountAssetDetail> {
        return getAccountAssetUseCase(toAddress, assetId)
    }
}
