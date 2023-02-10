-- Date 28.01.2023

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
function SyncClientServerEvent.new(vehicle, vOne, vTwo, vThree, vFour, vFive, isVarioTM)
    local self = SyncClientServerEvent.emptyNew()
    self.vOne = vOne
    self.vTwo = vTwo
    self.vThree = vThree
    self.vFour = vFour
    self.vFive = vFive
    -- self.check = check
    self.isVarioTM = isVarioTM
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
    -- self.check = streamReadBool(streamId)
    self.isVarioTM = streamReadBool(streamId)
    self:run(connection)
end


---Called on server side on join
-- @param integer streamId streamId
-- @param integer connection connection
function SyncClientServerEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.vehicle)
    streamWriteInt32(streamId, self.vOne, self.vTwo, self.vThree, self.vFour, self.vFive)
    streamWriteBool(streamId, self.isVarioTM)
	-- streamWriteUIntN(streamId, self.vOne, 1)  -- what does it do?
end


---Run action on receiving side
-- @param integer connection connection
function SyncClientServerEvent:run(connection)
    if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then
        CVTaddon.SyncClientServer(self.vehicle, self.vOne, self.vTwo, self.vThree, self.vFour, self.vFive, self.isVarioTM)
		
		if not connection:getIsServer() then
			g_server:broadcastEvent(SyncClientServerEvent.new(self.vehicle, self.vOne, self.vTwo, self.vThree, self.vFour, self.vFive, self.isVarioTM), nil, connection, self.vehicle)
		end
    end
end

