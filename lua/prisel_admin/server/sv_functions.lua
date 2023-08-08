require("mysqloo")

local db = mysqloo.connect("109.122.198.111", "prisel_v3", "P[kUbSp]L7N1-D1V", "prisel_v3", 3306)

function db:onConnected()
    local sQuery = [[
        CREATE TABLE IF NOT EXISTS player_sanctions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            steamid VARCHAR(255),
            reason TEXT,
            admin_id VARCHAR(255),
            sanction_type INT,
            timestamp TIMESTAMP,
            active BOOLEAN DEFAULT TRUE
        )
    ]]

    local query = db:query(sQuery)

    query:start()
end

function db:onConnectionFailed(err)
end

db:connect()

local PLAYER = FindMetaTable("Player")

function PLAYER:AddSanction(sReason, sAdminID, iSanctionType)
    iSanctionType = iSanctionType or 1

    local steamID = self:SteamID64()

    if not db then
        return
    end

    local sInsertQuery = ([[
        INSERT INTO player_sanctions (steamid, reason, admin_id, sanction_type, timestamp)
        VALUES ('%s', '%s', '%s', %d, NOW())
    ]]):format(self:SteamID64(), db:escape(sReason), db:escape(sAdminID), tonumber(iSanctionType))

    local query = db:query(sInsertQuery)

    local pAdmin = player.GetBySteamID64(sAdminID)

    query.onSuccess = function()
        if IsValid(pAdmin) then
            DarkRP.notify(pAdmin, 0, 4, "Vous avez ajouté une sanction à " .. self:Nick() .. ".")
        end
    end

    query.onError = function(_, err)
        if IsValid(pAdmin) then
            DarkRP.notify(pAdmin, 1, 4, "Une erreur est survenue lors de l'ajout de la sanction à " .. self:Nick() .. ".")
        end
    end

    query:start()
end

function PLAYER:RemoveSanction(iSanctionID)
    local sSteamID64 = self:SteamID64()

    if not db then
        return
    end

    local sRemoveQuery = ([[
        DELETE FROM player_sanctions WHERE id = %d AND steamid = '%s'
    ]]):format(tonumber(iSanctionID), sSteamID64)

    local query = db:query(sRemoveQuery)

    query:start()
end

function PLAYER:GetSanctions(callback)
    local sSteamID64 = self:SteamID64()

    if not db then
        return {}
    end

    local sSelectQuery = ([[
        SELECT * FROM player_sanctions WHERE steamid = '%s'
    ]]):format(sSteamID64)

    local tSanctions = {}

    local query = db:query(sSelectQuery)

    query.onSuccess = function(_, tData)
        tSanctions = tData
        if callback then
            callback(tSanctions, #tSanctions)
        end
    end

    query.onError = function(_, err)
        print(err)
        if callback then
            callback({}, err)
        end
    end

    query:start()
end


function PLAYER:GetSanctionsByType(iSanctionType)
    local sSteamID64 = self:SteamID64()

    if not db then
        return {}
    end

    local sSelectQuery = ([[
        SELECT * FROM player_sanctions WHERE steamid = '%s' AND sanction_type = %d
    ]]):format(sSteamID64, tonumber(iSanctionType))

    local tSanctions = {}

    local query = db:query(sSelectQuery)

    query.onSuccess = function(_, tData)
        for _, row in ipairs(tData) do
            table.insert(tSanctions, row)
        end
    end

    query:start()

    return tSanctions
end

function PLAYER:GetSanctionById(iSanctionId)
    local sSteamID64 = self:SteamID64()

    if not db then
        return nil
    end

    local sSelectQuery = ([[
        SELECT * FROM player_sanctions WHERE steamid = '%s' AND id = %d
    ]]):format(steamID, tonumber(iSanctionId))

    local tSanction = nil

    local query = db:query(sSelectQuery)

    query.onSuccess = function(_, data)
        if #data > 0 then
            tSanction = data[1]
        end
    end

    query:start()

    return tSanction
end

function PLAYER:HasActiveSanctions()
    local sSteamID64 = self:SteamID64()

    if not db then
        return false
    end

    local sSelectQuery = ([[
        SELECT COUNT(*) as count FROM player_sanctions WHERE steamid = '%s' AND active = TRUE
    ]]):format(sSteamID64)

    local bActiveSanction = false

    local query = db:query(sSelectQuery)

    query.onSuccess = function(_, data)
        if data and data[1] and data[1].count > 0 then
            bActiveSanction = true
        end
    end

    query:start()

    return bActiveSanction
end

function PLAYER:MarkSanctionInactive(iSanctionID)
    local sSteamID64 = self:SteamID64()

    if not db then
        return
    end

    local sUpdateQuery = ([[
        UPDATE player_sanctions SET active = FALSE WHERE steamid = '%s' AND id = %d
    ]]):format(sSteamID64, tonumber(iSanctionID))

    local query = db:query(sUpdateQuery)

    query:start()
end

function PLAYER:GetTotalSanctionsCount()
    local sSteamID64 = self:SteamID64()

    if not db then
        return 0
    end

    local sSelectQuery = ([[
        SELECT COUNT(*) as count FROM player_sanctions WHERE steamid = '%s'
    ]]):format(sSteamID64)

    local tTotalSanctions = 0

    local query = db:query(sSelectQuery)

    query.onSuccess = function(_, tData)
        if tData and tData[1] then
            tTotalSanctions = tData[1].count
        end
    end

    query:start()

    return tTotalSanctions
end

function PLAYER:MarkSanctionActive(iSanctionID)
    local sSteamID64 = self:SteamID64()

    if not db then
        return
    end

    local sUpdateQuery = ([[
        UPDATE player_sanctions SET active = TRUE WHERE steamid = '%s' AND id = %d
    ]]):format(sSteamID64, tonumber(iSanctionID))

    local query = db:query(sUpdateQuery)

    query:start()
end

function PLAYER:IsSanctionActive(iSanctionID)
    local sSteamID64 = self:SteamID64()

    if not db then
        return false
    end

    local sSelectQuery = ([[
        SELECT active FROM player_sanctions WHERE steamid = '%s' AND id = %d
    ]]):format(sSteamID64, tonumber(iSanctionID))

    local bActive = false

    local query = db:query(sSelectQuery)

    query.onSuccess = function(_, tData)
        if tData and tData[1] then
            bActive = tData[1].active
        end
    end

    query:start()

    return bActive
end