function sysCall_init()
    ownHandle=sim.getObjectHandle("SignalingColumn")
    sim.setShapeColor(ownHandle,nil,sim.colorcomponent_ambient_diffuse,{0,1,0})
    minArrayLength=15 --min number of rays to be reflected before object is detected
    fieldActivationHandle=sim.getCollisionHandle('LaserScannerActivation#')
    exactMode = false
    delayTimer = 0
    delay = 10
end

function sysCall_actuation()
    local activationStatus = false -- indicates if protective field is activated
    if exactMode then
        local scannerData=sim.getStringSignal("measuredDataAtThisTime")
        if scannerData then
            scannerData=sim.unpackFloatTable(scannerData)
            arrayLength=table.getn(scannerData)
            counter = 1
            while (counter < arrayLength and arrayLength > minArrayLength and not activationStatus) do
                x=scannerData[counter]
                y=scannerData[counter+1]
                activationStatus=checkProtectiveField(x,y)
                counter=counter+3
            end
        end
    else
        if sim.readCollision(fieldActivationHandle)==1 then
            delayTimer = delayTimer+1
            if delayTimer > delay then
                activationStatus = true
            end
        else
            delayTimer = 0
        end
    end
    if activationStatus then
        sim.setShapeColor(ownHandle,nil,sim.colorcomponent_ambient_diffuse,{1,0,0})
        sim.setStringSignal("SafetyStop","1")
    else
        sim.setShapeColor(ownHandle,nil,sim.colorcomponent_ambient_diffuse,{0,1,0})
        sim.setStringSignal("SafetyStop","0")
    end
end

function sysCall_sensing()
    -- put your sensing code here
end

function sysCall_cleanup()
    -- do some clean-up here
end

-- You can define additional system calls here:

function checkProtectiveField(x,y)
    d=1 -- distance of protective field
    rotation=math.rad(45) -- rotation of protective field relative to sensor coordinate system
    -- Transform from sensor to world frame by applying rotation:
    x_t = x*math.cos(rotation)+y*math.sin(rotation)
    y_t = -x*math.sin(rotation)+y*math.cos(rotation)
    -- check if transformed points are within protective field:
    if (x_t>0 and y_t>0) then
        return x_t<d
    elseif (x_t<0 and y_t<0) then
        return y_t>-d
    elseif (x_t>0 and y_t <0) then
        return math.sqrt(x_t*x_t+y_t*y_t)<d    
    else
        return false
    end
end