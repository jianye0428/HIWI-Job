displayInfo=function(txt)
    if dlgHandle then
        sim.endDialog(dlgHandle)
    end
    dlgHandle=nil
    if txt and #txt>0 then
        dlgHandle=sim.displayDialog('info',txt,sim.dlgstyle_message,false)
        sim.switchThread()
    end
end
forbidThreadSwitches=function(forbid)
    -- Allows or forbids automatic thread switches.
    -- This can be important for threaded scripts. For instance,
    -- you do not want a switch to happen while you have temporarily
    -- modified the robot configuration, since you would then see
    -- that change in the scene display.
    if forbid then
        forbidLevel=forbidLevel+1
        if forbidLevel==1 then
            sim.setThreadAutomaticSwitch(false)
        end
    else
        forbidLevel=forbidLevel-1
        if forbidLevel==0 then
            sim.setThreadAutomaticSwitch(true)
        end
    end
end

findCollisionFreeConfigAndCheckApproach=function(matrix)
    -- Here we search for a robot configuration..
    -- 1. ..that matches the desired pose (matrix)
    -- 2. ..that does not collide in that configuration
    -- 3. ..that does not collide and that can perform the IK linear approach
    sim.setObjectMatrix(ikTarget,-1,matrix)
    -- Here we check point 1 & 2:
    local c=sim.getConfigForTipPose(ikGroup,jh,0.65,10)
    if c then
        -- Here we check point 3:
        local m = matrix
        local path = generateIkPath(c,m,ikSteps)
        if path==nil then
            c=nil
        end
    end
    return c
end

findSeveralCollisionFreeConfigsAndCheckApproach=function(matrix,trialCnt,maxConfigs)
    -- Here we search for several robot configurations...
    -- 1. ..that matches the desired pose (matrix)
    -- 2. ..that does not collide in that configuration
    -- 3. ..that does not collide and that can perform the IK linear approach
    forbidThreadSwitches(true)
    sim.setObjectMatrix(ikTarget,-1,matrix)
    local cc=getConfig()
    local cs={}
    local l={}
    for i=1,trialCnt,1 do
        local c=findCollisionFreeConfigAndCheckApproach(matrix)
        if c then
            local dist=getConfigConfigDistance(cc,c)
            local p=0
            local same=false
            for j=1,#l,1 do
                if math.abs(l[j]-dist)<0.001 then
                    -- we might have the exact same config. Avoid that
                    same=true
                    for k=1,#jh,1 do
                        if math.abs(cs[j][k]-c[k])>0.01 then
                            same=false
                            break
                        end
                    end
                end
                if same then
                    break
                end
            end
            if not same then
                cs[#cs+1]=c
                l[#l+1]=dist
            end
        end
        if #l>=maxConfigs then
            break
        end
    end
    forbidThreadSwitches(false)
    if #cs==0 then
        cs=nil
    end
    return cs
end

getConfig=function()
    -- Returns the current robot configuration
    local config={}
    for i=1,#jh,1 do
        config[i]=sim.getJointPosition(jh[i])
    end
    return config
end

setConfig=function(config)
    -- Applies the specified configuration to the robot
    if config then
        for i=1,#jh,1 do
            sim.setJointPosition(jh[i],config[i])
        end
    end
end

getConfigConfigDistance=function(config1,config2)
    -- Returns the distance (in configuration space) between two configurations
    local d=0
    for i=1,#jh,1 do
        local dx=(config1[i]-config2[i])*metric[i]
        d=d+dx*dx
    end
    return math.sqrt(d)
end

getPathLength=function(path)
    -- Returns the length of the path in configuration space
    local d=0
    local l=#jh
    local pc=#path/l
    for i=1,pc-1,1 do
        local config1={path[(i-1)*l+1],path[(i-1)*l+2],path[(i-1)*l+3],path[(i-1)*l+4],path[(i-1)*l+5]}
        local config2={path[i*l+1],path[i*l+2],path[i*l+3],path[i*l+4],path[i*l+5]}
        d=d+getConfigConfigDistance(config1,config2)
    end
    return d
end

followPath=function(path)
    -- Follows the specified path points. Each path point is a robot configuration. Here we don't do any interpolation
    if path then
        local l=#jh
        local pc=#path/l
        for i=1,pc,1 do
            local config={path[(i-1)*l+1],path[(i-1)*l+2],path[(i-1)*l+3],path[(i-1)*l+4],path[(i-1)*l+5]}
            setConfig(config)
            sim.switchThread()
        end
    end
end

findPath=function(startConfig,goalConfigs,cnt)
    -- Here we do path planning between the specified start and goal configurations. We run the search cnt times,
    -- and return the shortest path, and its length
    local task=simOMPL.createTask('task')
    simOMPL.setAlgorithm(task,simOMPL.Algorithm.RRT)
    local j1_space=simOMPL.createStateSpace('j1_space',simOMPL.StateSpaceType.joint_position,jh[1],{-60*math.pi/180},{170*math.pi/180},1)
    local j2_space=simOMPL.createStateSpace('j2_space',simOMPL.StateSpaceType.joint_position,jh[2],{-10*math.pi/180},{170*math.pi/180},2)
    local j3_space=simOMPL.createStateSpace('j3_space',simOMPL.StateSpaceType.joint_position,jh[3],{-60*math.pi/180},{90*math.pi/180},3)
    local j4_space=simOMPL.createStateSpace('j4_space',simOMPL.StateSpaceType.joint_position,jh[4],{-150*math.pi/180},{60*math.pi/180},0)
    local j5_space=simOMPL.createStateSpace('j5_space',simOMPL.StateSpaceType.joint_position,jh[5],{-90*math.pi/180},{90*math.pi/180},0)
    simOMPL.setStateSpace(task,{j1_space,j2_space,j3_space,j4_space,j5_space})
    --simOMPL.setCollisionPairs(task,collisionPairs)
    simOMPL.setStartState(task,startConfig)
    simOMPL.setGoalState(task,goalConfigs[1])
    for i=2,#goalConfigs,1 do
        simOMPL.addGoalState(task,goalConfigs[i])
    end
    local path=nil
    local l=999999999999
    forbidThreadSwitches(true)
    for i=1,cnt,1 do
        local res,_path=simOMPL.compute(task,4,-1,10)
        if res and _path then
            local _l=getPathLength(_path)
            if _l<l then
                l=_l
                path=_path
            end
        end
    end
    forbidThreadSwitches(false)
    simOMPL.destroyTask(task)
    return path,l
end

findShortestPath=function(startConfig,goalConfigs,searchCntPerGoalConfig)
    -- This function will search for several paths between the specified start configuration,
    -- and several of the specified goal configurations. The shortest path will be returned
    forbidThreadSwitches(true)
    local thePath=findPath(startConfig,goalConfigs,searchCntPerGoalConfig)
    forbidThreadSwitches(false)
    return thePath
end

generateIkPath=function(startConfig,goalPose,steps)
    -- Generates (if possible) a linear, collision free path between a robot config and a target pose
    forbidThreadSwitches(true)
    local currentConfig=getConfig()
    setConfig(startConfig)
    sim.setObjectMatrix(ikTarget,-1,goalPose)
    local c=sim.generateIkPath(ikGroup,jh,steps)
    setConfig(currentConfig)
    forbidThreadSwitches(false)
    return c
end
function sysCall_threadmain()
    -- Initialization phase:
    joint1=sim.getObjectHandle("Bill_rightShoulderJoint_F")
    joint2=sim.getObjectHandle("Bill_rightShoulderJoint_A")
    joint3=sim.getObjectHandle("Bill_rightShoulderJoint_R")
    joint4=sim.getObjectHandle("Bill_rightElbowJoint")
    joint5=sim.getObjectHandle("Bill_rightPalmJoint")
    jh={joint1,joint2,joint3,joint4,joint5}
    ikGroup=sim.getIkGroupHandle('rightArmIK')
    ikTarget=sim.getObjectHandle('rightArm_target')
    
    --collisionPairs={sim.getCollectionHandle('leftArm'),sim.getObjectHandle('Mesh17')}
    target=sim.getObjectHandle('testTarget')
    metric={0.5,1,1,0.5,0.1}
    forbidLevel=0
    ikShift=0.1
    ikSteps=5
    
    while true do
        -- This is the main loop. We move from one target to the next
        local theTarget=target
        -- m is the transformation matrix or pose of the current target:
        local m=sim.getObjectMatrix(theTarget,-1)
    
        local c=findSeveralCollisionFreeConfigsAndCheckApproach(m,10,10)
        sim.switchThread() -- in order see the change before next operation locks
        local path=findShortestPath(getConfig(),c,6)
        followPath(path)
    end
end
function sysCall_cleanup()
    -- Put some clean-up code here
end

-- See the user manual or the available code snippets for additional callback functions and details
