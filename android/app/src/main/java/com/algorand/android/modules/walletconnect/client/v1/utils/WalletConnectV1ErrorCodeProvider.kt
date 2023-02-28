@file:Suppress("MagicNumber")
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

package com.algorand.android.modules.walletconnect.client.v1.utils

import com.algorand.android.modules.walletconnect.domain.model.WalletConnectTransactionErrorResponse
import javax.inject.Inject

class WalletConnectV1ErrorCodeProvider @Inject constructor() {

    fun getErrorCode(error: WalletConnectTransactionErrorResponse): Long {
        return when (error) {
            is WalletConnectTransactionErrorResponse.Rejected -> 4001L
            is WalletConnectTransactionErrorResponse.Unauthorized -> 4100L
            is WalletConnectTransactionErrorResponse.Unsupported -> 4200L
            is WalletConnectTransactionErrorResponse.InvalidInput -> 4300L
            is WalletConnectTransactionErrorResponse.UnknownAsset -> 4400L
        }
    }
}
