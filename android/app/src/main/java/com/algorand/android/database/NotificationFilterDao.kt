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

package com.algorand.android.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.algorand.android.models.NotificationFilter
import kotlinx.coroutines.flow.Flow

@Dao
interface NotificationFilterDao {
    @Query("SELECT * FROM notificationfilter")
    fun getAllAsFlow(): Flow<List<NotificationFilter>>

    @Query("SELECT * FROM notificationfilter WHERE public_key = :publicKey")
    fun getNotificationFilterForUser(publicKey: String): List<NotificationFilter>

    @Query("DELETE FROM notificationfilter WHERE public_key = :publicKey")
    suspend fun deleteByPublicKey(publicKey: String)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(notificationFilter: NotificationFilter)
}
