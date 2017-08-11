
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

export DTF2
DTF2 = DTF2 or {}

entMeta = FindMetaTable('Player')

PlayerClass =
    GetBuildedSentry: => @GetNWEntity('DTF2.Sentry')
    GetBuildedDispenser: => @GetNWEntity('DTF2.Dispenser')
    GetBuildedTeleporterIn: => @GetNWEntity('DTF2.TeleporterIn')
    GetBuildedTeleporterOut: => @GetNWEntity('DTF2.TeleporterOut')
    
    SetBuildedSentry: (val = NULL) => @SetNWEntity('DTF2.Sentry', val)
    SetBuildedDispenser: (val = NULL) => @SetNWEntity('DTF2.Dispenser', val)
    SetBuildedTeleporterIn: (val = NULL) => @SetNWEntity('DTF2.TeleporterIn', val)
    SetBuildedTeleporterOut: (val = NULL) => @SetNWEntity('DTF2.TeleporterOut', val)

entMeta[k] = v for k, v in pairs PlayerClass

if SERVER
    func = (soundPlay) ->
        return =>
            ply = @GetPlayer()
            -- if IsValid(ply) and ply\IsPlayer()
            if IsValid(ply)
                ply.__DTF2_LastPlayedDestryReplic = ply.__DTF2_LastPlayedDestryReplic or 0
                time = CurTime()
                if ply.__DTF2_LastPlayedDestryReplic < time
                    ply.__DTF2_LastPlayedDestryReplic = time + 1.5
                    ply\EmitSound(soundPlay, 70, 100, 1, CHAN_VOICE)
    
    hook.Add 'TF2SentryDestroyed', 'PlayReplics', func('vo/engineer_autodestroyedsentry01.mp3')
    hook.Add 'TF2DispenserDestroyed', 'PlayReplics', func('vo/engineer_autodestroyeddispenser01.mp3')
    hook.Add 'TF2TeleporterDestroyed', 'PlayReplics', func('vo/engineer_autodestroyedteleporter01.mp3')
