About Node/Item groups, groupcaps, tool capabilities, etc...
============================================================

I want to go into how Neotest tools interact with blocks types:

Block groups for tools
----------------------

Here are all node groups that tools of this game care about:

- `choppy`: Used for node resembling wood and wood products
- `snappy`: Used for nodes that can be cut by fine tools (currently not used by tools)
- `crumbly`: Used for dirt, sand, gravel, etc...
- `cracky`: Used for stones and ores
- `oddly\_breakable\_by\_hand`: Used for things the player needs to break instantly

Other groups used for crafting are:

In Neotest, instead of using hard dependencies for cross-mod crafting recipes, we use groups to generalize crafting recipes that span items/nodes of different mods

- `wood`: Used for everything wood
- `stick`: Used for sticks
- `stone`: Used for everything stone
- `coal`: Used for Coal and equivalent
- `iron`: Used for Iron Ingots and equivalent
- `gold`: Used Gold Ingots and equivalent
- `diamond`: Used for Diamonds and equivalent
- `gem`: An overarching group that all gems (including diamonds) belong to

For items that wish to not be included in the creative menu, simply set `no_creative` to anything but `nil`