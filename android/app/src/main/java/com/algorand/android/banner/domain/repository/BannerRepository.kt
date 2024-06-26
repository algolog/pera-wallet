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

package com.algorand.android.banner.domain.repository

import com.algorand.android.banner.domain.model.BannerDetailDTO
import com.algorand.android.models.Result
import kotlinx.coroutines.flow.Flow

interface BannerRepository {

    suspend fun cacheBanner(bannerDetailDto: BannerDetailDTO)

    suspend fun getBanners(deviceId: String): Result<List<BannerDetailDTO>>

    suspend fun getCachedBanner(): Flow<BannerDetailDTO?>

    suspend fun setBannerDismissed(bannerId: Long)

    suspend fun removeDismissedBannerFromCache(bannerId: Long)

    suspend fun getDismissedBannerIdList(): List<Long>

    suspend fun clearBannerCache()

    suspend fun clearDismissedBannerIds()

    companion object {
        const val BANNER_REPOSITORY_INJECTION_NAME = "bannerRepositoryInjection"
    }
}
