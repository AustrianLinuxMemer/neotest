-- *** WARNING, init2.lua is up for removal, do not use any of it anymore, it is defunct ***

mobs = {
    gravity = vector.new(0, -9.81, 0),
    jump = vector.new(0, 5.5, 0)
}


-- Adaptive pathfinding helper function
function mobs.is_jumpable(pos_node)
    local node_boxes = core.get_node_boxes("collision_box", pos_node)
    local height = 0
    for _, box in ipairs(node_boxes) do
        local current_height = box[5]
        if current_height >= height then height = current_height end
    end
    local node_above = core.get_node(vector.new(pos_node.x, pos_node.y + 1, pos_node.z))
    local def = core.registered_nodes[node_above.name]
    return height <= 0.5 and not def.walkable
end
function mobs.get_dominant_axis(direction)
    local abs_x = math.abs(direction.x)
    local abs_z = math.abs(direction.z)
    if abs_x >= abs_z then
        return "x"
    else
        return "z"
    end
end
function mobs.any_jumpable(direction, moveresult)
    local dominant_axis = mobs.get_dominant_axis(direction)
    for _, collision in ipairs(moveresult.collisions) do
        if collision.axis == dominant_axis and collision.type == "node" then
            local is_jumpable = mobs.is_jumpable(collision.node_pos)
            if is_jumpable then return true end
        end
    end
    return false
end
-- Jump function, if it succeeds, it returns true, otherwise false
function mobs.try_jump(obj, objective, moveresult)
    local direction = vector.direction(obj:get_pos(), objective)
    local any_jumpable = mobs.any_jumpable(direction, moveresult)
    if any_jumpable and moveresult.touching_ground then
        -- Jump succeeded
        obj:add_velocity(mobs.jump)
        return true
    else
        -- Jump failed
        return false
    end
end
-- Adds gravity to object movement
function mobs.exercise_gravity(obj, moveresult)
    if not moveresult.touching_ground then
        obj:set_acceleration(mobs.gravity)
    end
end
-- Set a velocity for reaching the objective (the y component is handled independendly)
function mobs.rotate_facing_direction(obj, direction)
    local angle = math.atan2(direction.z, direction.x) + math.pi
    local rotation_v = vector.new(0, angle, 0)
    obj:set_rotation(rotation_v)
end
function mobs.set_velocity_to_direction(obj, direction)
    local velocity = vector.multiply(direction, 2.13)
    velocity.y = 0
    obj:set_velocity(velocity)
    mobs.rotate_facing_direction(obj, direction)
end
function mobs.get_new_direction(last_direction)
    local directions = {
        vector.new(1, 0, 0),   -- 1: +x
        vector.new(1, 0, -1),  -- 2: +x -z
        vector.new(0, 0, -1),  -- 3: -z
        vector.new(-1, 0, -1), -- 4: -x -z
        vector.new(-1, 0, 0),  -- 5: -x
        vector.new(-1, 0, 1),  -- 6: -x +z
        vector.new(0, 0, 1),   -- 7: +z
        vector.new(1, 0, 1),   -- 8: +x +z
    }
    if last_direction == nil then
        return directions[math.random(1,#directions)]
    else
        local last_index = nil
        for i, direction in ipairs(directions) do
            if vector.equals(last_direction, direction) then
                last_index = i
                break
            end
        end
        if not last_index then
            return directions[math.random(1,#directions)]
        else
            local options = {
                ((last_index - 2) % 8) + 1,
                last_index,
                (last_index % 8) + 1
            }
            return directions[options[math.random(1,#options)]]
        end
    end
end
function mobs.on_activate(self, serialized)
    local data = core.deserialize(serialized)
    self.ticks = 0
    self.last_pos = self.object:get_pos()
    self.stopped = false
    self.stopped_at = 0
    self.stopped_for = 0
    if data ~= nil then
        self.direction = data.direction or mobs.get_new_direction()
        self.last_pos = data.last_pos or self.object:get_pos()
        self.has_jumped = data.has_jumped or false
        self.stopped = data.stopped or false
        self.stopped_at = data.stopped_at or 0
        self.stopped_for = data.stopped_for or 0
    end 
end

function mobs.get_staticdata(self)
    local data = {
        direction = self.direction,
        last_pos = self.last_pos,
        has_jumped = self.has_jumped,
        stopped = self.stopped,
        stopped_at = self.stopped_at,
        stopped_for = self.stopped_for
    }
    return core.serialize(data)
end
-- check if the mob is stuck somewhere
function mobs.is_stuck(obj, last_pos)
    local current_pos = obj:get_pos()
    local diff = vector.abs(vector.subtract(current_pos, last_pos))
    return diff.x <= 0.01 and diff.y <= 0.01 and diff.z <= 0.01
end

function mobs.on_step(self, dtime, moveresult)
    -- Advancing the tick
    self.ticks = self.ticks + 1
    -- Apply Gravity
    mobs.exercise_gravity(self.object, moveresult)
    -- Set a new objective if:
    -- 300 ticks passed
    -- the mob got stuck
    if self.ticks % 3600 == 0 or mobs.is_stuck(self.object, self.last_pos) and not self.stopped then
        self.direction = mobs.get_new_direction(self.direction)
        mobs.set_velocity_to_direction(self.object, self.direction)
    end
    -- Have a 1/300 chance for the mob to stop
    if math.random(1,300) == 10 and not self.stopped then
        local current_velocity = self.object:get_velocity()
        current_velocity.x = 0
        current_velocity.z = 0
        self.object:set_velocity(current_velocity)
        self.stopped = true
        self.stopped_at = self.ticks
        self.stopped_for = math.random(400, 600)
    end
    if self.ticks - self.stopped_at >= self.stopped_for and self.stopped then
        mobs.set_velocity_to_direction(self.object, self.direction)
        self.stopped = false
    end
    -- Only jump when on the ground
    self.has_jumped = mobs.try_jump(self.object, self.direction, moveresult)
    -- At the very end
    
    self.last_pos = self.object:get_pos()
end

function mobs.on_death(self, killer)
    
end

function mobs.register(name, def)
    def.on_activate = mobs.on_activate
    def.get_staticdata = mobs.get_staticdata
    def.on_step = mobs.on_step
    core.register_entity(name, def)
end
function mobs.spawn(name, pos)
    core.add_entity(pos, name)
end


mobs.register("mobs:sheep", {
    initial_properties = {
        visual = "mesh",
        mesh = "sheep.gltf",
        textures = {"sheep.png"},
        hp_max = 10,
        visual_size = {x = 10, y = 10, z = 10},
        collisionbox = {-8/16, 0, -8/16, 8/16, 18/16, 8/16},
        physical = true
    }
})

core.register_chatcommand("spawn", {
    params = "<entity_name> [<x> <y> <z>]",
    description = "Spawns an entity",
    privs = {server = true},
    func = function(name, param)
        local params = string.split(param, " ", false)
        if #params == 1 then
            local player = core.get_player_by_name(name)
            if player == nil then
                return false
            else
                local pos = player:get_pos()
                if core.registered_entities[params[1]] ~= nil then
                    core.add_entity(pos, params[1])
                end
            end
        elseif #params == 4 then
            local x = tonumber(params[2])
            local y = tonumber(params[3])
            local z = tonumber(params[4])
            if x ~= nil and y ~= nil and z ~= nil then
                local pos = vector.new(x, y, z)
                core.add_entity(pos, params[1])
            else
                return false
            end
        end
    end
})