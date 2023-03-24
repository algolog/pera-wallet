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

package com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui.model

import androidx.annotation.StringRes

data class RekeyToStandardAccountInstructionPreview(
    @StringRes val titleTextResId: Int,
    @StringRes val descriptionTextResId: Int,
    @StringRes val firstDescriptionTextResId: Int,
    @StringRes val secondDescriptionTextRestId: Int,
    @StringRes val thirdDescriptionTextResId: Int,
    @StringRes val actionButtonTextResId: Int
)