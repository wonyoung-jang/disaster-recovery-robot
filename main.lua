--This code was created by modifying the bubblenRob-lua tutorial file in CoppeliaSimEdu
-- INITIALIZE FUNCTION
function sysCall_init()
    num_To_Detect = 0
    avoidanceTurn = false
    sim = require('sim')
    simUI = require('simUI')
    simVision = require('simVision')
    bubbleRobBase = sim.getObject('.') -- this is bubbleRob's handle
    leftMotor = sim.getObject("./leftMotor") -- Handle of the left motor
    rightMotor = sim.getObject("./rightMotor") -- Handle of the right motor
    noseSensor = sim.getObject('./sensingNoseToDetect') -- Handle Obstacle sensor
    peopleSensor = sim.getObject('./DetectPeople') -- Handle People sensor
    minMaxSpeed = {50 * math.pi / 180, 300 * math.pi / 180} -- Min and max speeds for each motor
    backUntilTime = -1 -- Tells whether bubbleRob is in forward or backward mode

    -- GRAPH UI
    robotCollection = sim.createCollection(0)
    sim.addItemToCollection(robotCollection, sim.handle_tree, bubbleRobBase, 0)
    distanceSegment = sim.addDrawingObject(sim.drawing_lines, 4, 0, -1, 1, {0, 1, 0})
    robotTrace = sim.addDrawingObject(sim.drawing_linestrip + sim.drawing_cyclic, 2, 0, -1, 200, {1, 1, 0}, nil, nil, {1, 1, 0})
    graph = sim.getObject('./graph')
    distStream = sim.addGraphStream(graph,'bubbleRob clearance','m',0,{1, 0, 0})
    
    -- Create the custom UI:
    xml = '<ui title="'..sim.getObjectAlias(bubbleRobBase, 1)..' speed" closeable = "false" resizeable = "false" activate = "false">'..[[ <hslider minimum="0" maximum="100" on-change="speedChange_callback" id="1"/> <label text="" style="* {margin-left: 300px;}"/> </ui> ]]

    -- SPEED UI
    ui = simUI.create(xml)
    speed = (minMaxSpeed[1] + minMaxSpeed[2]) * 0.5
    simUI.setSliderValue(ui, 1, 100 * (speed - minMaxSpeed[1]) / (minMaxSpeed[2] - minMaxSpeed[1]))
    end


-- SENSING FUNCTION
function sysCall_sensing()
    local result, distData = sim.checkDistance(robotCollection, sim.handle_all)

    if result > 0 then
        sim.addDrawingObjectItem(distanceSegment, nil)
        sim.addDrawingObjectItem(distanceSegment, distData)
        sim.setGraphStreamValue(graph, distStream, distData[7])
    end

    local p = sim.getObjectPosition(bubbleRobBase)
    sim.addDrawingObjectItem(robotTrace, p)
    end


-- SPEED CHANGE FUNCTION
function speedChange_callback(ui, id, newVal)
    speed = minMaxSpeed[1] + (minMaxSpeed[2] - minMaxSpeed[1]) * newVal / 100
    end


-- ACTUATION FUNCTION
function sysCall_actuation()
    -- Read the specific object-detecting proximity sensor
    local result_to_detect, __, __, detectedObjectHandle = sim.readProximitySensor(noseSensor)

    -- If we detected a specific object (debris or infrastructure), initiate avoidance behavior
    if (result_to_detect > 0 and detectedObjectHandle) then

        -- Check if objectAlias is not nil
        if sim.getObjectAlias(detectedObjectHandle) == 'DebrisToDetect' then
            num_To_Detect = num_To_Detect + 1
            print("Debris we want is detected!: Num: " .. tostring(num_To_Detect) .." - " ..
            tostring(sim.getObjectAlias(detectedObjectHandle)))
            sim.setObjectColor(noseSensor, 0, sim.colorcomponent_ambient_diffuse, {0, 1, 0}) -- Green
            
            -- Change color to red to indicate detection
            sim.setShapeColor(bubbleRobBase, nil, sim.colorcomponent_ambient_diffuse, {1, 0, 0})
            
            -- Initiate avoidance behavior
            backUntilTime = sim.getSimulationTime() + 3 -- Back up for 3 seconds
            avoidanceTurn = true -- Flag to turn after backing up
            avoidanceState = "backingUp" -- Set initial avoidance state
        elseif sim.getObjectAlias(detectedObjectHandle) == 'InfraToDetect' then
            num_To_Detect = num_To_Detect + 1
            print("Infrastructure we want is detected!: Num: " .. tostring(num_To_Detect) .." - " ..
            tostring(sim.getObjectAlias(detectedObjectHandle)))
            sim.setObjectColor(noseSensor, 0, sim.colorcomponent_ambient_diffuse, {0, 1, 0}) 
            
            -- Change color to red to indicate detection
            sim.setShapeColor(bubbleRobBase, nil, sim.colorcomponent_ambient_diffuse, {1, 0, 0})
            
            -- Initiate avoidance behavior
            backUntilTime = sim.getSimulationTime() + 3 -- Back up for 3 seconds
            avoidanceTurn = true -- Flag to turn after backing up
            avoidanceState = "backingUp" -- Set initial avoidance state
        else
        end
    end
    
    -- Handle the avoidance behavior
    if avoidanceTurn then
        if avoidanceState == "backingUp" then
            if sim.getSimulationTime() <= backUntilTime then
                -- Continue backing up
                sim.setJointTargetVelocity(leftMotor, -speed / 2)
                sim.setJointTargetVelocity(rightMotor, -speed / 2)
            else
                -- Once done backing up, start turning
                avoidanceState = "turning"
                backUntilTime = sim.getSimulationTime() + 1 -- Turn for 10 second
            end
        elseif avoidanceState == "turning" then
            if sim.getSimulationTime() <= backUntilTime then
                -- Continue turning
                sim.setJointTargetVelocity(leftMotor, speed / 2)
                sim.setJointTargetVelocity(rightMotor, -speed / 2)
            else
                -- Reset avoidance flags and color once turning is done
                avoidanceTurn = false
                avoidanceState = nil
                sim.setShapeColor(bubbleRobBase, nil, sim.colorcomponent_ambient_diffuse, {0, 1, 0})
            end
        end
    return
    end

    -- Normal movement (move forward)
    sim.setJointTargetVelocity(leftMotor, speed)
    sim.setJointTargetVelocity(rightMotor, speed)
    local result_to_detect_people, __, __, detectedPeopleHandle = sim.readProximitySensor(peopleSensor)
        if result_to_detect_people > 0 then
            if sim.getObjectAlias(detectedPeopleHandle) == 'Bill' then
                -- Stop the robot
                sim.setJointTargetVelocity(leftMotor, 0)
                sim.setJointTargetVelocity(rightMotor, 0)
                -- Get Bill's location
                local billPosition = sim.getObjectPosition(detectedPeopleHandle, -1) -- -1 to get the absolute position
                -- Print Bill's location
                print("Bill detected at position: X = " .. billPosition[1] .. ", Y = " .. billPosition[2] .. ", Z = " .. billPosition[3])
            return
            end
        end
    end


-- CLEANUP FUNCTION
function sysCall_cleanup()
    simUI.destroy(ui)
    end
