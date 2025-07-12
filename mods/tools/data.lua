-- Groupcap table, to easily adjust the tools as needed, no hard-coding the properties of each tool, use these tables instead


local S = core.get_translator("mods:tools")
local groupcap_table = {
    pickaxes = {
        wood = {cracky = {times={[3]=1.60}, uses=10, maxlevel=1}},
        stone = {cracky = {times={[2]=2.0, [3]=1.00}, uses=20, maxlevel=1}},
        iron = {cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2}},
        gold = {cracky = {times={[1]=2.0, [2]=0.8, [3]=0.4}, uses=5, maxlevel=2}},
        diamond = {cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3}}
    },
    shovels = {
        stone = {crumbly = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1}},
        iron = {crumbly = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=30, maxlevel=2}},
        gold = {crumbly = {times={[1]=1.10, [2]=0.5, [3]=0.3}, uses=5, maxlevel=2}},
        diamond = {crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3}}
    },
    axes = {
        stone = {choppy={times={[1]=3.00, [2]=2.00, [3]=1.30}, uses=20, maxlevel=1}},
        iron = {choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=3}},
        gold = {choppy={times={[1]=1.05, [2]=0.45, [3]=0.25}, uses=5, maxlevel=3}},
        diamond = {choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=3}}
    },
    swords = {
    },
    shears = {snappy = {times = {[1] = 0.1, [2] = 0.1, [3] = 0.1}, uses = 20}}
}

local damage_groups = {
    pickaxes = {
        wood = {fleshy = 1},
        stone = {fleshy = 2},
        iron = {fleshy = 3},
        gold = {fleshy = 4},
        diamond = {fleshy = 5}
    },
    shovels = {
        stone = {fleshy = 1},
        iron = {fleshy = 2},
        gold = {fleshy = 3},
        diamond = {fleshy = 4}
    },
    axes = {
        stone = {fleshy = 3},
        iron = {fleshy = 4},
        gold = {fleshy = 5},
        diamond = {fleshy = 6}
    },
    swords = {
        stone = {fleshy = 5},
        iron = {fleshy = 6},
        gold = {fleshy = 7},
        diamond = {fleshy = 8}
    },
    shears = {fleshy = 1}
}
local tools = {
    planks = {
        pickaxe = {
            description = "Wooden pickaxe",
            inventory_image = "pickaxe_wood.png",
            tool_capabilities = {
                full_punch_interval = 1.2,
                max_drop_level=0,
                groupcaps={
                    cracky = groupcap_table.pickaxes.wood.cracky,
                },
                damage_groups = damage_groups.pickaxes.wood,
            },
            groups = {tool_wood=1, pickaxe=1}
        }
    },
    stone = {
        pickaxe = {
            description = "Stone pickaxe",
            inventory_image = "pickaxe_stone.png",
            tool_capabilities = {
                full_punch_interval = 1.3,
                groupcaps = {
                    cracky = groupcap_table.pickaxes.stone.cracky        
                },
                damage_groups = damage_groups.pickaxes.stone
            },
            groups = {tool_stone=1, pickaxe=1}
        },
        axe = {
            description = "Stone Axe",
            inventory_image = "axe_stone.png",
            tool_capabilities = {
                full_punch_interval = 1.2,
                max_drop_level=0,
                groupcaps={
                    choppy = groupcap_table.axes.stone.choppy,
                },
                damage_groups = damage_groups.axes.stone,
            },
            groups = {tool_stone = 1, axe = 1}
        },
        shovel = {
            description = "Stone Shovel",
            inventory_image = "shovel_stone.png",
            wield_image = "shovel_stone.png^[transformR90",
            tool_capabilities = {
                full_punch_interval = 1.4,
                max_drop_level=0,
                groupcaps={
                    crumbly = groupcap_table.shovels.stone.crumbly,
                },
                damage_groups = damage_groups.shovels.stone,
            },
            groups = {tool_stone=1, shovel=1}
        }
    },
    iron = {
        pickaxe = {
            description = "Iron pickaxe",
            inventory_image = "pickaxe_iron.png",
            tool_capabilities = {
                full_punch_interval = 1.0,
                max_drop_level=1,
                groupcaps={
                    cracky = groupcap_table.pickaxes.iron.cracky,
                },
                damage_groups = damage_groups.pickaxes.iron,
            },
            groups = {tool_iron=1, pickaxe=1}
        },
        axe = {
            description = "Iron Axe",
            inventory_image = "axe_iron.png",
            tool_capabilities = {
                full_punch_interval = 1.0,
                max_drop_level=1,
                groupcaps={
                    choppy=groupcap_table.axes.iron.choppy,
                },
                damage_groups = damage_groups.axes.iron,
            },
            groups = {tool_iron=1, axe=1}
        },
        shovel = {
            description = "Iron Shovel",
            inventory_image = "shovel_iron.png",
            wield_image = "shovel_iron.png^[transformR90",
            tool_capabilities = {
                full_punch_interval = 1.1,
                max_drop_level=1,
                groupcaps={
                    crumbly = groupcap_table.shovels.iron.crumbly,
                },
                damage_groups = damage_groups.shovels.iron,
            },
            groups = {tool_iron=1, shovel=1}
        },
        shears = {
            description = "Shears",
            inventory_image = "shears.png",
            tool_capabilities = {
                full_punch_interval = 3,
                max_drop_level = 0,
                groupcaps = {
                    snappy = groupcap_table.shears.snappy,
                },
                damage_groups = damage_groups.shears,
            },
            groups = {tool_iron=1, shears=1}
        }
    },
    gold = {
        pickaxe = {
            description = "Golden pickaxe",
            inventory_image = "pickaxe_gold.png",
            tool_capabilities = {
                full_punch_interval = 1.0,
                max_drop_level=1,
                groupcaps={
                    cracky = groupcap_table.pickaxes.gold.cracky,
                },
                damage_groups = damage_groups.pickaxes.gold,
            },
            groups = {tool_gold=1, pickaxe=1}
        },
        axe = {
            description = "Gold Axe",
            inventory_image = "axe_gold.png",
            tool_capabilities = {
                full_punch_interval = 1.0,
                max_drop_level=1,
                groupcaps={
                    choppy=groupcap_table.axes.gold.choppy,
                },
                damage_groups = damage_groups.axes.gold,
            },
            groups = {tool_gold=1, axe=1}
        },
        shovel = {
            description = "Gold Shovel",
            inventory_image = "shovel_gold.png",
            wield_image = "shovel_gold.png^[transformR90",
            tool_capabilities = {
                full_punch_interval = 1.1,
                max_drop_level=1,
                groupcaps={
                    crumbly = groupcap_table.shovels.gold.crumbly,
                },
                damage_groups = damage_groups.shovels.gold,
            },
            groups = {tool_gold=1, shovel=1}
        },
    },
    diamond = {
        pickaxe = {
            description = "Diamond pickaxe",
            inventory_image = "pickaxe_diamond.png",
            tool_capabilities = {
                full_punch_interval = 0.9,
                max_drop_level=3,
                groupcaps={
                    cracky = groupcap_table.pickaxes.diamond.cracky,
                },
                damage_groups = damage_groups.pickaxes.diamond,
            },
            groups = {tool_diamond=1, pickaxe=1}
        },
        axe = {
            description = "Diamond Axe",
            inventory_image = "axe_diamond.png",
            tool_capabilities = {
                full_punch_interval = 0.9,
                max_drop_level=1,
                groupcaps={
                    choppy=groupcap_table.axes.iron.choppy,
                },
                damage_groups = damage_groups.axes.diamond,
            },
            groups = {tool_diamond=1,axe=1}
        },
        shovel = {
            description = "Diamond Shovel",
            inventory_image = "shovel_diamond.png",
            wield_image = "shovel_diamond.png^[transformR90",
            tool_capabilities = {
                full_punch_interval = 1.0,
                max_drop_level=1,
                groupcaps={
                    crumbly = groupcap_table.shovels.diamond.crumbly,
                },
                damage_groups = damage_groups.shovels.diamond,
            },
            groups = {tool_diamond=1, shovel=1}
        }
    }
}

local farming_present = core.get_modpath("farming") ~= nil

if farming_present then
    groupcap_table.hoes = {
        stone = {crumbly = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1}},
        iron = {crumbly = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=30, maxlevel=2}},
        gold = {crumbly = {times={[1]=1.10, [2]=0.5, [3]=0.3}, uses=5, maxlevel=2}},
        diamond = {crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3}}
    }
    damage_groups.hoes = {
        stone = {fleshy = 1},
        iron = {fleshy = 2},
        gold = {fleshy = 3},
        diamond = {fleshy = 4}
    }
    tools.stone.hoe = {
        description = "Stone Hoe",
        inventory_image = "hoe_stone.png",
        tool_capabilities = {
            full_punch_interval = 1.3,
            groupcaps = {
                crumbly = groupcap_table.hoes.stone.crumbly       
            },
            damage_groups = damage_groups.hoes.stone
        },
        groups = {tool_stone=1, hoe=1},
        on_use = farming.tilt_land
    }
    tools.iron.hoe = {
        description = "Iron hoe",
        inventory_image = "hoe_iron.png",
        tool_capabilities = {
            full_punch_interval = 1.0,
            max_drop_level=1,
            groupcaps={
                crumbly = groupcap_table.hoes.iron.crumbly,
            },
            damage_groups = damage_groups.hoes.iron,
        },
        groups = {tool_iron=1, hoe=1},
        on_use = farming.tilt_land
    }
    tools.gold.hoe = {
        description = "Golden hoe",
        inventory_image = "hoe_gold.png",
        tool_capabilities = {
            full_punch_interval = 1.0,
            max_drop_level=1,
            groupcaps={
                crumbly = groupcap_table.hoes.gold.crumbly,
            },
            damage_groups = damage_groups.hoes.gold,
        },
        groups = {tool_gold=1, hoe=1},
        on_use = farming.tilt_land
    }
    tools.diamond.hoe = {
        description = "Diamond hoe",
        inventory_image = "hoe_diamond.png",
        tool_capabilities = {
            full_punch_interval = 0.9,
            max_drop_level=3,
            groupcaps={
                crumbly = groupcap_table.hoes.diamond.crumbly,
            },
            damage_groups = damage_groups.hoes.diamond,
        },
        groups = {tool_diamond=1, hoe=1},
        on_use = farming.tilt_land
    }
end

return tools