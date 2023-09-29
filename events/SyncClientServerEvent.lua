-- Date: 28.01.2023
-- edit: 28.04.2023
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
function SyncClientServerEvent.new(vehicle, vOne, vTwo, vThree, vFour, vFive, autoDiffs, lastDirection, isVarioTM, isTMSpedal, PedalResolution, rpmDmax, rpmrange, CVTconfig)
    local self = SyncClientServerEvent.emptyNew()
    self.vOne = vOne
    self.vTwo = vTwo
    self.vThree = vThree
    self.vFour = vFour
    self.vFive = vFive
    self.autoDiffs = autoDiffs
    self.lastDirection = lastDirection
    self.isVarioTM = isVarioTM
    self.isTMSpedal = isTMSpedal
    self.PedalResolution = PedalResolution
    self.rpmDmax = rpmDmax
    self.rpmrange = rpmrange
    self.CVTconfig = CVTconfig
    -- self.mcRPMvar = mcRPMvar
    self.vehicle = vehicle
    return self
end


---Called on client side on join
-- @param integer streamId streamId
-- @param integer connection connection
function SyncClientServerEvent:readStream(streamId, connection)
    self.vehicle = NetworkUtil.readNodeObject(streamId)
	-- self.vOne = streamReadUIntN(streamId, 1)
    self.vOne = streamReadInt32(streamId)
    self.vTwo = streamReadInt32(streamId)
    self.vThree = streamReadInt32(streamId)
    self.vFour = streamReadInt32(streamId)
    self.vFive = streamReadInt32(streamId)
    self.autoDiffs = streamReadInt32(streamId)
    self.lastDirection = streamReadInt32(streamId)
    self.isVarioTM = streamReadBool(streamId)
    self.isTMSpedal = streamReadInt32(streamId)
    self.PedalResolution = streamReadInt32(streamId)
    self.rpmDmax = streamReadInt32(streamId)
    self.rpmrange = streamReadInt32(streamId)
    self.CVTconfig = streamReadInt32(streamId)
    -- self.mcRPMvar = streamReadFloat32(streamId)
    self:run(connection)
end


---Called on server side on join
-- @param integer streamId streamId
-- @param integer connection connection
function SyncClientServerEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.vehicle)
    streamWriteInt32(streamId, self.vOne, self.vTwo, self.vThree, self.vFour, self.vFive, self.autoDiffs, self.lastDirection, self.isVarioTM, self.isTMSpedal, self.PedalResolution, self.rpmDmax, self.rpmrange, self.CVTconfig)
    streamWriteBool(streamId, self.isVarioTM)
    -- streamWriteFloat32(streamId, self.mcRPMvar)
	-- streamWriteUIntN(streamId, self.vOne, 1)  -- what does it do?
end


---Run action on receiving side
-- @param integer connection connection
function SyncClientServerEvent:run(connection)
    if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then
        CVTaddon.SyncClientServer(self.vehicle, self.vOne, self.vTwo, self.vThree, self.vFour, self.vFive, self.autoDiffs, self.lastDirection, self.isVarioTM, self.isTMSpedal, self.PedalResolution, self.rpmDmax, self.rpmrange, self.CVTconfig)
		
		if not connection:getIsServer() then
			g_server:broadcastEvent(SyncClientServerEvent.new(self.vehicle, self.vOne, self.vTwo, self.vThree, self.vFour, self.vFive, selfautoDiffs, self.lastDirection, self.isVarioTM, self.isTMSpedal, self.PedalResolution, self.rpmDmax, self.rpmrange, self.CVTconfig), nil, connection, self.vehicle)
		end
    end
end

