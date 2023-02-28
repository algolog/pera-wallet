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

package com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto

import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionEntity
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionDTO
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import javax.inject.Inject

class WalletConnectSessionDTOMapper @Inject constructor(
    private val peerMetaDTOMapper: WalletConnectPeerMetaDTOMapper,
    private val sessionMetaDTOMapper: WalletConnectSessionMetaDTOMapper
) {

    fun mapToSessionDTO(entity: WalletConnectSessionEntity): WalletConnectSessionDTO {
        return with(entity) {
            WalletConnectSessionDTO(
                id = id,
                peerMeta = peerMetaDTOMapper.mapToPeerMetaDTO(peerMeta),
                wcSession = sessionMetaDTOMapper.mapToSessionMetaDTO(wcSession),
                dateTimeStamp = dateTimeStamp,
                isConnected = isConnected,
                isSubscribed = isSubscribed,
                fallbackBrowserGroupResponse = fallbackBrowserGroupResponse
            )
        }
    }

    fun mapToSessionDTO(
        sessionResult: WalletConnect.Session.Settle.Result,
        sessionMeta: WalletConnect.Session.Meta.Version1
    ): WalletConnectSessionDTO {
        return with(sessionResult) {
            WalletConnectSessionDTO(
                id = session.sessionIdentifier.getIdentifier().toLong(),
                peerMeta = peerMetaDTOMapper.mapToPeerMetaDTO(session.peerMeta),
                wcSession = sessionMetaDTOMapper.mapToSessionMetaDTO(sessionMeta),
                dateTimeStamp = session.creationDateTimestamp,
                isConnected = session.isConnected,
                isSubscribed = session.isSubscribed,
                fallbackBrowserGroupResponse = session.fallbackBrowserGroupResponse
            )
        }
    }
}
