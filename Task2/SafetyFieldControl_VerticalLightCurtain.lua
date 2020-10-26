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
    billbase=sim.getCollectionHandle('bill')
    laserpointer=sim.getCollectionHandle('laserpointer')
    cylinder=sim.getObjectHandle('Cylinder')
    sensor2=sim.getObjectHandle('LaserPointer_sensor#7')
    counter=0
    sensor={}
    for i=1,7,1 do
        sensor[i]=sim.getObjectHandle('LaserPointer_sensor#'..i)
    end
end
function sysCall_sensing()
    res={}
    dist={}
    pt={}
    res_test = 0 
    for i=1,7,1 do
        res[i],dist[i],pt[i]=sim.checkProximitySensor(sensor[i],billbase)
    end
    if res[1]==1 or res[2]==1 or res[3]==1 or res[4]==1 or res[5]==1 or res[6]==1 or res[7]==1 then
        res_test = 1
    end
    if res[1]==0 and res[2]==0 and res[3]==0 and res[4]==0 and res[5]==0 and res[6]==0 and res[7]==0 then
        res_test = 0
    end
    if (oldres_test == 0 and res_test == 1) then
        counter=counter+1
        print(counter)
    end
    oldres_test=res_test
end
function sysCall_actuation()
    if counter%2 == 0 then
         sim.setStringSignal("SafetyStop","0")
    end
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
