local Weatherbox = {}
function Weatherbox:new(radius, height, center_pos, spawner_template)
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    self.particlespawners = {}
    self.radius = radius
    self.height = height
    self.center_pos = center_pos
    self.spawner_template = spawner_template
    self.active = false
    return instance
end
function Weatherbox:despawn(poslist)
    for _, pos in poslist do
        local particlespawner = self.particlespawners[pos.x][pos.z]
        if particlespawner then
            core.delete_particlespawner(particlespawner)
        end
    end
end
function Weatherbox:spawn(poslist)
    for _, pos in poslist do
        local particlespawner = self.particlespawners[pos.x][pos.z]
        if not particlespawner then
            local box = {
                min = vector.new(pos.x - 0.5, self.height, pos.z - 0.5),
                max = vector.new(pos.x + 0.5, self.height, pos.z + 0.5)
            }
            local spawner = table.copy(self.spawner_template)
            spawner.pos = box
            local id = core.add_particlespawner(spawner)
            self.particlespawners[pos.x][pos.z] = id
        end
    end
end
function Weatherbox:set_active(active)
    self.active = active
end
function Weatherbox:set_spawner_template(template)
    self.spawner_template = template
end
function Weatherbox:move(new_center_pos)
    local new_poslist = {}
    for x = new_center_pos.x - self.radius, new_center_pos.x + self.radius do
        for z = new_center_pos.z - self.radius, new_center_pos.z + self.radius do
            table.insert(new_poslist, vector.new(x, 0, z))
        end
    end
    self.center_pos = new_center_pos
    self:despawn(new_poslist)
    self:spawn(new_poslist)    
end
function Weatherbox:recalculate()
    
end
function Weatherbox:on_player_move(newpos)
    if self.active then
        self:move(newpos)
    end
end
function Weatherbox:on_node_mod()
    if self.active then
        self:recalculate()
    end
end
function Weatherbox:kill()
    for _, row in ipairs(self.particlespawners) do
        for _, id in ipairs(row) do
            core.delete_particlespawner(id)
        end
    end
end
return Weatherbox