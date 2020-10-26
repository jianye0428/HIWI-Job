-- if you wish to execute code contained in an external file instead,
-- use the require-directive, e.g.:
--
-- require 'myExternalFile'
--
-- Above will look for <V-REP executable path>/myExternalFile.lua or
-- <V-REP executable path>/lua/myExternalFile.lua
-- (the file can be opened in this editor with the popup menu over
-- the file name)

function sysCall_init()
    sensor1=sim.getObjectHandle('LaserPointer_sensor#1')
    sensor7=sim.getObjectHandle('LaserPointer_sensor#7')
end
function sysCall_sensing()
    res1,dist1,pt1=sim.readProximitySensor(sensor1)
    res7,dist7,pt7=sim.readProximitySensor(sensor7)
    if dist1<0.88 then
        t1=sim.getSimulationTime()-sim.getSimulationTime()%0.01        
        --print(t1-t1%0.01)
        --print(dist2)
    end
     if dist7<0.88 then
        t7=sim.getSimulationTime()-sim.getSimulationTime()%0.01
        --print(t2-t2%0.01)
        --print(dist2)
    end
    if t1~= nil and t7 ~= nil and t1<t7 then 
        print(123)
        sim.setStringSignal("SafetyStop","1")
    end
    if t1~=nil and t7~= nil and t1>t7 then
        print(456)
        sim.setStringSignal("SafetyStop","0")
    end
    
end
function sysCall_actuation()
    sim.setStringSignal("SafetyStop","0")
    
end
function sysCall_suspend()
  
end
function sysCall_cleanup()
    -- do some clean-up here
end

-- You can define additional system calls here:
--[[
function sysCall_suspend()
end

function sysCall_resume()
end

function sysCall_dynCallback(inData)
end

function sysCall_jointCallback(inData)
    return outData
end

function sysCall_contactCallback(inData)
    return outData
end

function sysCall_beforeCopy(inData)
    for key,value in pairs(inData.objectHandles) do
        print("Object with handle "..key.." will be copied")
    end
end

function sysCall_afterCopy(inData)
    for key,value in pairs(inData.objectHandles) do
        print("Object with handle "..key.." was copied")
    end
end

function sysCall_beforeDelete(inData)
    for key,value in pairs(inData.objectHandles) do
        print("Object with handle "..key.." will be deleted")
    end
    -- inData.allObjects indicates if all objects in the scene will be deleted
end

function sysCall_afterDelete(inData)
    for key,value in pairs(inData.objectHandles) do
        print("Object with handle "..key.." was deleted")
    end
    -- inData.allObjects indicates if all objects in the scene were deleted
end

function sysCall_afterCreate(inData)
    for key,value in pairs(inData.objectHandles) do
        print("Object with handle "..value.." was created")
    end
end
--]]
