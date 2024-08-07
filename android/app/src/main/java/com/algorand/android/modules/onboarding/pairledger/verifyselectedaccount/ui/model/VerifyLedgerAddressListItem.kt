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

package com.algorand.android.modules.onboarding.pairledger.verifyselectedaccount.ui.model

sealed class VerifyLedgerAddressListItem {

    abstract infix fun areItemsTheSame(other: VerifyLedgerAddressListItem): Boolean
    abstract infix fun areContentsTheSame(other: VerifyLedgerAddressListItem): Boolean

    data class VerifiableLedgerAddressItem(
        val address: String,
        val status: VerifiableLedgerAddressItemStatus = VerifiableLedgerAddressItemStatus.PENDING
    ) : VerifyLedgerAddressListItem() {
        override fun areItemsTheSame(other: VerifyLedgerAddressListItem): Boolean {
            return other is VerifiableLedgerAddressItem && address == other.address
        }

        override fun areContentsTheSame(other: VerifyLedgerAddressListItem): Boolean {
            return other is VerifiableLedgerAddressItem && this == other
        }
    }

    object VerifyLedgerHeaderItem : VerifyLedgerAddressListItem() {
        override fun areItemsTheSame(other: VerifyLedgerAddressListItem): Boolean {
            return other is VerifyLedgerHeaderItem
        }

        override fun areContentsTheSame(other: VerifyLedgerAddressListItem): Boolean {
            return other is VerifyLedgerHeaderItem
        }
    }
}
