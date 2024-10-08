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

package com.algorand.android.ui.settings.security

import javax.inject.Inject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.algorand.android.usecase.SecurityUseCase
import dagger.hilt.android.lifecycle.HiltViewModel

@HiltViewModel
class SecurityViewModel @Inject constructor(
    private val securityUseCase: SecurityUseCase
) : ViewModel() {

    private val _isPasswordChosenLiveData = MutableLiveData(securityUseCase.isPinCodeEnabled())
    val isPasswordChosenLiveData: LiveData<Boolean> = _isPasswordChosenLiveData

    private val _isBiometricEnabledLiveData = MutableLiveData(securityUseCase.isBiometricActive())
    val isBiometricEnabledLiveData: LiveData<Boolean> = _isBiometricEnabledLiveData

    fun setBiometricRegistrationPreference(isEnabled: Boolean) {
        securityUseCase.setBiometricRegistrationPreference(isEnabled)
    }

    fun setPasswordPreferencesAsDisabled() {
        securityUseCase.setPasswordPreferencesAsDisabled()
    }

    fun updatePinCodeEnabledFlow(isChecked: Boolean) {
        _isPasswordChosenLiveData.postValue(isChecked)
    }

    fun updateBiometricEnabledFlow(isEnabled: Boolean) {
        _isBiometricEnabledLiveData.postValue(isEnabled)
    }

    fun isPasscodeSet() = _isPasswordChosenLiveData.value ?: false

    fun isBiometricAuthEnabled() = _isBiometricEnabledLiveData.value ?: false
}
