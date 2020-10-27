--if you wish to execute code contained in an external file instead,
-- use the require-directive, e.g.:
--
-- require 'myExternalFile'
--
-- Above will look for <V-REP executable path>/myExternalFile.lua or
-- <V-REP executable path>/lua/myExternalFile.lua
-- (the file can be opened in this editor with the popup menu over
-- the file name)

function sysCall_init()
    upperBodyJointHandle1=sim.getObjectHandle('Bill_upperBodyJoint1')
    upperBodyJointHandle2=sim.getObjectHandle('Bill_upperBodyJoint2')
    upperBodyJointHandle3=sim.getObjectHandle('Bill_upperBodyJoint3')
    counter=0
    upperBodyBendDegree1_forward=sim.getScriptSimulationParameter(sim.handle_self,'upperBodyBendDegree1_forwards')
    upperBodyBendDegree1_backward=sim.getScriptSimulationParameter(sim.handle_self,'upperBodyBendDegree1_backwards')
    upperBodyBendDegree1=(upperBodyBendDegree1_forward+upperBodyBendDegree1_backward)/2
    upperBodyBendDegree2=sim.getScriptSimulationParameter(sim.handle_self,'upperBodyBendDegree2')
    upperBodySpinDegree=sim.getScriptSimulationParameter(sim.handle_self,'upperBodySpinDegree')
end

function sysCall_actuation()
    counter=counter+sim.getSimulationTimeStep()
    jointPositionValue1=(math.sin(counter)-upperBodyBendDegree1/upperBodyBendDegree1_forward)*upperBodyBendDegree1*math.pi/180
    sim.setJointPosition(upperBodyJointHandle1,jointPositionValue1)
    jointPositionValue2=(math.cos(counter))*upperBodyBendDegree2*math.pi/180
    sim.setJointPosition(upperBodyJointHandle2,jointPositionValue2)
    jointPositionValue3=(math.cos(counter))*upperBodySpinDegree*math.pi/180
    sim.setJointPosition(upperBodyJointHandle3,jointPositionValue3)
end

function sysCall_sensing()
    -- put your sensing code here
end

function sysCall_cleanup()
    -- do some clean-up here
end
