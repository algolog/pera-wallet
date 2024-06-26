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
 */

package com.algorand.android.ui.accountselection.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemContactSimpleBinding
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.utils.extensions.setContactIconDrawable

class AccountSelectionContactItemViewHolder(
    private val binding: ItemContactSimpleBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: BaseAccountSelectionListItem.BaseAccountItem.ContactItem) {
        with(binding) {
            contactDisplayNameTextView.text = item.displayName
            contactImageView.setContactIconDrawable(item.imageUri, R.dimen.account_icon_size_large)
        }
    }

    companion object {
        fun create(parent: ViewGroup): AccountSelectionContactItemViewHolder {
            val binding = ItemContactSimpleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountSelectionContactItemViewHolder(binding)
        }
    }
}
