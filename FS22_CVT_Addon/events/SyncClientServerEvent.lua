-- Date: 28.01.2023
-- edit: 01.10.2023
SyncClientServerEvent = {}

local SyncClientServerEvent_mt = Class(SyncClientServerEvent, Event)
InitEventClass(SyncClientServerEvent, "SyncClientServerEvent")

---Create instance of Event class
-- @return table self instance of class event
function SyncClientServerEvent.emptyNew()
    local self = Event.new(SyncClientServerEvent_mt)
    return self
end

---Create new instance of event
-- @param table vehicle vehicle
-- @param integer state state
function SyncClientServerEvent.new(vehicle, vOne, vTwo, vThree, CVTCanStart, vFive, autoDiffs, isVarioTM, isTMSpedal, CVTconfig, warnHeat, critHeat, warnDamage, critDamage, CVTdamage, HandgasPercent, ClutchInputValue)
    local self = SyncClientServerEvent.emptyNew()
    self.vOne = vOne
    self.vTwo = vTwo
    self.vThree = vThree
    self.CVTCanStart = CVTCanStart
    self.vFive = vFive
    self.autoDiffs = autoDiffs
    -- self.lastDirection = lastDirection
    self.isVarioTM = isVarioTM
    self.isTMSpedal = isTMSpedal
    -- self.moveRpmL = moveRpmL -- placeholder
    -- self.rpmDmax = rpmDmax
    -- self.rpmrange = rpmrange
    self.CVTconfig = CVTconfig
    self.warnHeat = warnHeat
    self.critHeat = critHeat
    self.warnDamage = warnDamage
    self.critDamage = critDamage
    self.CVTdamage = CVTdamage
    self.HandgasPercent = HandgasPercent --
    self.ClutchInputValue = ClutchInputValue
    self.vehicle = vehicle
    return self
end


---Called on client side on join
-- @param integer streamId streamId
-- @param integer connection connection
function SyncClientServerEvent:readStream(streamId, connection)
    self.vehicle = NetworkUtil.readNodeObject(streamId)
    self.vOne = streamReadInt32(streamId)
    self.vTwo = streamReadInt32(streamId)
    self.vThree = streamReadInt32(streamId)
    self.CVTCanStart = streamReadBool(streamId)
    self.vFive = streamReadInt32(streamId)
    self.autoDiffs = streamReadInt32(streamId)
    -- self.lastDirection = streamReadInt32(streamId)
    self.isVarioTM = streamReadBool(streamId)
    self.isTMSpedal = streamReadInt32(streamId)
    -- self.moveRpmL = streamReadFloat32(streamId)
    -- self.rpmDmax = streamReadInt32(streamId)
    -- self.rpmrange = streamReadInt32(streamId)
    self.CVTconfig = streamReadInt32(streamId)
    self.warnHeat = streamReadInt32(streamId)
    self.critHeat = streamReadInt32(streamId)
	self.warnDamage = streamReadInt32(streamId)
    self.critDamage = streamReadInt32(streamId)
    self.CVTdamage = streamReadFloat32(streamId)
    self.HandgasPercent = streamReadFloat32(streamId)
    self.ClutchInputValue = streamReadFloat32(streamId)
    self:run(connection)
end


---Called on server side on join
-- @param integer streamId streamId
-- @param integer connection connection
function SyncClientServerEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.vehicle)
    -- streamWriteInt32(streamId, self.vOne, self.vTwo, self.vThree, self.CVTCanStart, self.vFive, self.autoDiffs, self.lastDirection, self.isVarioTM, self.isTMSpedal, self.PedalResolution, self.rpmDmax, self.rpmrange, self.CVTconfig)
    streamWriteInt32(streamId, self.vOne)
	streamWriteInt32(streamId, self.vTwo)
    streamWriteInt32(streamId, self.vThree)
    streamWriteBool(streamId, self.CVTCanStart)
    streamWriteInt32(streamId, self.vFive)
    streamWriteInt32(streamId, self.autoDiffs)
    -- streamWriteInt32(streamId, self.lastDirection)
	streamWriteBool(streamId, self.isVarioTM)
    streamWriteInt32(streamId, self.isTMSpedal)
    -- streamWriteFloat32(streamId, self.moveRpmL)
    -- streamWriteInt32(streamId, self.rpmDmax)
    -- streamWriteInt32(streamId, self.rpmrange)
    streamWriteInt32(streamId, self.CVTconfig)
    streamWriteInt32(streamId, self.warnHeat)				--
    streamWriteInt32(streamId, self.critHeat)				--
    streamWriteInt32(streamId, self.warnDamage)				--
    streamWriteInt32(streamId, self.critDamage)				--
	streamWriteFloat32(streamId, self.CVTdamage)
    streamWriteFloat32(streamId, self.HandgasPercent)
    streamWriteFloat32(streamId, self.ClutchInputValue)
end


---Run action on receiving side
-- @param integer connection connection
function SyncClientServerEvent:run(connection)
    if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then
        CVTaddon.SyncClientServer(self.vehicle, self.vOne, self.vTwo, self.vThree, self.CVTCanStart, self.vFive, self.autoDiffs, self.isVarioTM, self.isTMSpedal, self.CVTconfig, self.warnHeat, self.critHeat, self.warnDamage, self.critDamage, self.CVTdamage, self.HandgasPercent, self.ClutchInputValue)
		if not connection:getIsServer() then --
			g_server:broadcastEvent(SyncClientServerEvent.new(self.vehicle, self.vOne, self.vTwo, self.vThree, self.CVTCanStart, self.vFive, self.autoDiffs, self.isVarioTM, self.isTMSpedal, self.CVTconfig, self.warnHeat, self.critHeat, self.warnDamage, self.critDamage, self.CVTdamage, self.HandgasPercent, self.ClutchInputValue), nil, connection, self.vehicle)
		end
    end
end

