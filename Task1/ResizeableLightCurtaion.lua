-- This is a customization script. It is intended to be used to customize a scene in
-- various ways, mainly when simulation is not running. When simulation is running,
-- do not use customization scripts, but rather child scripts if possible

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
    model=sim.getObjectAssociatedWithScript(sim.handle_self)
    h=sim.getObjectHandle('ConcretBlock')
    left_foot=sim.getObjectHandle('ConcretBlock_left')
    right_foot=sim.getObjectHandle('ConcretBlock_right')
    pointerElement=sim.getObjectHandle('LaserPointer')
    dummy_pointer=sim.getObjectHandle('Dummy') 
    dist=0.04
end

function sysCall_cleanup()
    hideDlg()
end
function sysCall_nonSimulation()
    local s=sim.getObjectSelection()
    if s and #s>=1 and s[1]==model then
        showDlg()        
    else
        hideDlg()
    end
end
function sysCall_beforeSimulation()
    hideDlg()
end

function sysCall_beforeSimulation()
    hideDlg()
end

--parameterize the distance between the laserscanner
function sliderDistChange(ui,id,newVal)
    --clear the laserscanner when the length of lichtvorhang was changed
    local child=sim.getObjectChild(dummy_pointer,0)
    while child~=-1 do
        sim.removeObject(child)
        child=sim.getObjectChild(dummy_pointer,0)
    end
    --
    dist=newVal/1000
    simUI.setSliderValue(ui,8,dist*1000)
    size_left_foot=sim.getObjectSizeValues(left_foot)
    zCnt=math.floor(100*(size_left_foot[3]/2)/(dist*100))
    local allPointers={}  
    for i=1,zCnt,1 do
        --copy and paste the laserscanner array
        local c=sim.copyPasteObjects({pointerElement},1)
        local pointer=c[1]
        allPointers[#allPointers+1]=pointer
        --determine the postion of laserscanner array
        sim.setObjectPosition(pointer,left_foot,{0,0.01,-size_left_foot[3]/4+dist*i})
        
        sim.setObjectParent(pointer,dummy_pointer,true)
    end
    sim.setObjectPosition(pointerElement,left_foot,{0,0.01,-size_left_foot[3]/4+dist})
    
end

--scale the parameter in X direction when the value in X achse on UI was set
function sliderXChange(ui,id,newVal)
    sizeX=minMaxSize[1]+(minMaxSize[2]-minMaxSize[1])*newVal/100
    size=sim.getObjectSizeValues(h)
    size_left_foot=sim.getObjectSizeValues(left_foot)
    --scale the X size value of the Lichtvorhang
    if (sizeX~=size[1]) then
        s=sizeX/size[1]
        sim.scaleObject(h,s,1,1)
        size[1]=sizeX
        simUI.setSliderValue(ui,2,100*(size[1]-minSize)/maxSize)
    end
    sim.setObjectPosition(pointerElement,left_foot,{0,0.01,-size_left_foot[3]/4+dist})
end
function sliderYChange(ui,id,newVal)
    --clear the laserscanner when the length of lichtvorhang was changed
    local child=sim.getObjectChild(dummy_pointer,0)
    while child~=-1 do
        sim.removeObject(child)
        child=sim.getObjectChild(dummy_pointer,0)
    end
    --
    sizeY=minMaxSize[1]+(minMaxSize[2]-minMaxSize[1])*newVal/100
    size=sim.getObjectSizeValues(h)
    size_left_foot=sim.getObjectSizeValues(left_foot)
    --scale the Y size value of the Lichtvorhang
    if (sizeY~=size[2]) then
        s=sizeY/size[2]
        sim.scaleObject(h,1,s,1)
        size[2]=sizeY
        simUI.setSliderValue(ui,4,100*(size[2]-minSize)/maxSize)
    end
    sim.setObjectPosition(right_foot,h,{0,(size[2]-s*0.0675)/2,0}) 
    sim.setObjectPosition(left_foot,h,{0,-(size[2]-s*0.0675)/2,0})
    sim.setObjectPosition(pointerElement,left_foot,{0,0.01,-size_left_foot[3]/4+dist})
    zCnt=math.floor(100*(size_left_foot[3]/2)/(dist*100))
    --change the position(length) of laserscanner when the Y size value was changed
    local allPointers={}  
    for i=1,zCnt,1 do
        --copy and paste the laserscanner array
        local c=sim.copyPasteObjects({pointerElement},1)
        local pointer=c[1]
        allPointers[#allPointers+1]=pointer
        --determine the postion of laserscanner array
        sim.setObjectPosition(pointer,left_foot,{0,0.01,-size_left_foot[3]/4+dist*i})
        sim.setObjectParent(pointer,dummy_pointer,true)
    end
end
function sliderZChange(ui,id,newVal)
    ----clean the laserscanner when the height of lichtvorhang was changed
    local child=sim.getObjectChild(dummy_pointer,0)
    while child~=-1 do
        sim.removeObject(child)
        child=sim.getObjectChild(dummy_pointer,0)
    end
    --
    sizeZ=minMaxSize[1]+(minMaxSize[2]-minMaxSize[1])*newVal/100
    size=sim.getObjectSizeValues(h)
    sizeHeight=sim.getObjectPosition(h,-1)
    size_left_foot=sim.getObjectSizeValues(left_foot)
    --scale the Z size value of the Lichtvorhang
    if (sizeZ~=size[3]) then
        s=sizeZ/size[3]
        sim.scaleObject(h,1,1,s)
        sim.scaleObject(left_foot,1,1,s)
        sim.scaleObject(right_foot,1,1,s)
        sizeHeight[3]=sizeZ/4
        sim.setObjectPosition(h,-1,sizeHeight)
        size[3]=sizeZ
        simUI.setSliderValue(ui,6,100*(size[3]-minSize)/maxSize)
    end
    size=sim.getObjectSizeValues(h)
    p=sim.getObjectPosition(left_foot,-1)
    q=sim.getObjectPosition(right_foot,-1)
    p[3]=size[3]/4
    q[3]=size[3]/4
    sim.setObjectPosition(left_foot,-1,p)
    sim.setObjectPosition(right_foot,-1,q)
    sim.setObjectPosition(pointerElement,left_foot,{0,0.01,-size_left_foot[3]/4+dist})
    --change the position(height) of laserscanner when the Z size value was changed
    zCnt=math.floor(100*(size_left_foot[3]/2)/(dist*100))
    local allPointers={}
    for i=1,zCnt,1 do
        --copy and paste the laserscanner array
        local c=sim.copyPasteObjects({pointerElement},1)
        local pointer=c[1]
        allPointers[#allPointers+1]=pointer
        --determine the postion of laserscanner array
        sim.setObjectPosition(pointer,left_foot,{0,0.01,-size_left_foot[3]/4+dist*i})
        sim.setObjectParent(pointer,dummy_pointer,true)       
    end
end

--function to show the UI window
function showDlg()
    if not ui then
        minSize=0.2
        maxSize=2
        minMaxSize={minSize,maxSize}
        --create the UI 
        xml=[[
    <ui closeable="true" title="Cubic Customizer" resizable="true" on-close="closeEventHandler" activate="false">
        <group layout="form" flat="true">
            <label text="X-size (m): " id="1"/>
            <hslider minimum="0" maximum="100" on-change="sliderXChange" id="2"/>
            <label text="Y-size (m): " id="3"/>
            <hslider minimum="0" maximum="100" on-change="sliderYChange" id="4"/>
            <label text="Z-size (m): " id="5"/>
            <hslider minimum="0" maximum="100" on-change="sliderZChange" id="6"/>
            <label text="Distance (m): " id="7"/>
            <hslider minimum="20" maximum="100" on-change="sliderDistChange" id="8"/>
        </group>
        <label text="" style="* {margin-left: 400px;}"/>
    </ui>
    ]]
        ui=simUI.create(xml)
        size=sim.getObjectSizeValues(h)
        position=sim.getObjectPosition(pointerElement,-1)
        simUI.setSliderValue(ui,2,100*(size[1]-minSize)/maxSize)
        simUI.setSliderValue(ui,4,100*(size[2]-minSize)/maxSize)
        simUI.setSliderValue(ui,6,100*(size[3]-minSize)/maxSize)
        simUI.setSliderValue(ui,8,position[3]*1000)
    end
end
--function to delete the script when the window is closed
function closeEventHandler(h)
    sim.removeScript(sim.handle_self)
end
--function to hide the UI window
function hideDlg()
    if ui then
        simUI.destroy(ui)
        ui=nil
    end
end

-- You can define additional system calls here:
--[[
function sysCall_beforeSimulation()
end

function sysCall_actuation()
end

function sysCall_sensing()
end

function sysCall_suspend()
end

function sysCall_suspended()
end

function sysCall_resume()
end

function sysCall_afterSimulation()
end

function sysCall_beforeInstanceSwitch()
end

function sysCall_afterInstanceSwitch()
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
    for i=1,#inData.objectHandles,1 do
        print("Object with handle "..inData.objectHandles[i].." was created")
    end
end

function sysCall_beforeMainScript()
    -- Can be used to step a simulation in a custom manner.
    local outData={doNotRunMainScript=false} -- when true, then the main script won't be executed
    return outData
end
--]]
