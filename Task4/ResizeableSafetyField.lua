function sysCall_init()
    model=sim.getObjectAssociatedWithScript(sim.handle_self)
    field_1=sim.getObjectHandle('ApproximatedScannerField1') 
    field_2=sim.getObjectHandle('ApproximatedScannerField2')
    field_3=sim.getObjectHandle('ApproximatedScannerField3')
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


function sliderScaleFactorChange(ui,id,newVal)

    size=minMaxSize[1]+(minMaxSize[2]-minMaxSize[1])*newVal/100
    size_1=sim.getObjectSizeValues(field_1)
    size_2=sim.getObjectSizeValues(field_2)
    size_3=sim.getObjectSizeValues(field_3)
    --scale the Y size value of the Lichtvorhang
    if (size~=size_1[2]) then
        s=size/size_1[2]

        sim.scaleObject(field_1,1,s,1)
        sim.scaleObject(field_2,s,1,1)
        sim.scaleObject(field_3,s,s,1)
        size_1[1]=size
        size_2[2]=size
        size_3[1]=size
        size_3[2]=size
        simUI.setSliderValue(ui,2,100*(size_1[2]-minSize)/maxSize)
    end
    position_field_1=sim.getObjectPosition(field_1,-1)
    position_field_2=sim.getObjectPosition(field_2,-1)
    position_field_3=sim.getObjectPosition(field_3,-1)
    sim.setObjectPosition(field_1,-1,{position_field_1[1],-size_1[2]*0.5,position_field_1[3]})
    sim.setObjectPosition(field_2,-1,{-1-0.5*size_2[1],position_field_2[2],position_field_2[3]})
    sim.setObjectPosition(field_3,-1,{-1-0.5*size_2[1],-size_1[2]*0.5,position_field_3[3]})

end
--function to show the UI window
function showDlg()
    if not ui then
        minSize=0.1
        maxSize=10
        minMaxSize={minSize,maxSize}
        --create the UI 
        xml=[[
    <ui closeable="true" title="Customizer" resizable="true" on-close="closeEventHandler" activate="false">
        <group layout="form" flat="true">
            <label text="rate:" id="1"/>
            <hslider minimum="1" maximum="20" on-change="sliderScaleFactorChange" id="2"/>
        </group>
        <label text="" style="* {margin-left: 400px;}"/>
    </ui>
    ]]
        ui=simUI.create(xml)
        size_1=sim.getObjectSizeValues(field_1)
        simUI.setSliderValue(ui,2,100*(size_1[1]-minSize)/maxSize)
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
