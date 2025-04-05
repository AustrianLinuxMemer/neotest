Recipes already used in Neotest:
================================

To make sure that recipes from other mods won't conflict with Neotest's mods, the crafting recipies are listed per mod:


Format
------

###Shaped recipes:

|`input`|`input`|`input`|...|   |                                  |
|-------|-------|-------|---|---|----------------------------------|
|`input`|`input`|`input`|...| = |`output` \[amount\] \[leftovers\] |
|`input`|`input`|`input`|...|   |                                  |
|  ...  |  ...  |  ...  |...|   |                                  |


The shaped recipe can have any form

###Unshaped recipes:

`input` + `input` + ... = `output` \[amount\] \[leftovers\]


Order of inputs do not matter

###Cook recipes:

`input` -> `output`


There is only one recipe

###Fuel recipes:

Fuel: `input` -> burntime \[leftovers\], ...


Recipes will always use technical names, for a translation from technical names into human names, consult `names.md`


bucket
------

|`group:iron`|            |`group:iron`|   |                 | 
|------------|------------|------------|---|-----------------|
|            |`group:iron`|            | = | `bucket:bucket` |


furnace
-------

|`group:stone`|`group:stone`|`group:stone`|   |                   |
|-------------|-------------|-------------|---|-------------------|
|`group:stone`|             |`group:stone`| = | `furnace:furnace` |
|`group:stone`|`group:stone`|`group:stone`|   |                   |


geology
-------

`geology:iron\_ore` -> `geology:iron\_ingot`

`geology:gold\_ore` -> `geology:gold\_ingot`


Fuel: `group:coal`


glass
-----

`glass:glass` -> `group:sand`


lamp
----

|`glass:glass`|`glass:glass`|`glass:glass`|   |                 |
|-------------|-------------|-------------|---|-----------------|
|`glass:glass`|             |`glass:glass`| = | `lamp:lamp_off` |
|`glass:glass`|`glass:glass`|`glass:glass`|   |                 |

|`glass:glass`|    `glass:glass`    |`glass:glass`|   |                         |
|-------------|---------------------|-------------|---|-------------------------|
|`glass:glass`|`buckets:lava_bucket`|`glass:glass`| = | `lamp:lamp_of_eternity` |
|`glass:glass`|    `glass:glass`    |`glass:glass`|   |                         |


tools
-----

Because tools can be made of different materials, i introduce the following pseudoaliases:

* `tools:material`
* `tools:material_pickaxe`
* `tools:material_shovel`
* `tools:material_axe`

For material, you can plug in for each tool these materials:

|Tool             |Materials                                                                 |
|-----------------|--------------------------------------------------------------------------|
| `tools:pickaxe` | `group:wood`, `group:stone`, `group:iron`, `group:gold`, `group:diamond` |
| `tools:shovel`  | `group:stone`, `group:iron`, `group:gold`, `group:diamond`               |
| `tools:axe`     | `group:stone`, `group:iron`, `group:gold`, `group:diamond`               |

Pickaxes:


|`tools:material`|`tools:material` |`tools:material`|
|----------------|-----------------|----------------|
|                |  `group:stick`  |                | = `tools:material_pickaxe`
|                |  `group:stick`  |                |


Shovel:

|`tools:material`|
|----------------|
| `group:stick`  | = `tools:material_shovel`
| `group:stick`  |


Axes:

|`group:stone`|`group:stone`|
|-------------|-------------|
|`group:stone`|`group:stick`| = `tools:stone_axe`
|             |`group:stick`|

|`group:stone`|`group:stone`|
|-------------|-------------|
|`group:stick`|`group:stone`| = `tools:stone_axe`
|`group:stick`|             |

|`group:iron`|`group:iron` |
|-------------|-------------|
|`group:iron`|`group:stick`| = `tools:iron_axe`
|            |`group:stick`|

|`group:iron` |`group:iron`|
|-------------|------------|
|`group:stick`|`group:iron`| = `tools:iron_axe`
|`group:stick`|            |

|`group:gold`|`group:gold` |
|-------------|------------|
|`group:gold`|`group:stick`| = `tools:gold_axe`
|            |`group:stick`|

|`group:gold` |`group:gold`|
|-------------|------------|
|`group:stick`|`group:gold`| = `tools:gold_axe`
|`group:stick`|            |

|`group:diamond`|`group:diamond`|
|---------------|---------------|
|`group:diamond`| `group:stick` | = `tools:diamond_axe`
|               | `group:stick` |

|`group:diamond`|`group:diamond`|
|---------------|---------------|
| `group:stick` |`group:diamond`| = `tools:diamond_axe`
| `group:stick` |               |


tree
----

For convenience, i will use the pseudoaliase

- `tree:wood`
- `tree:log`
- `tree:sapling`
- `tree:leaves`

instead of the full name of each type of tree

`tree:log` = `tree:wood` \[4\]
`tree:leaves` = `tree:sapling`

Fuel: `tree:wood` -> 30, `tree:log` -> 30, `tree:sapling` -> 5, `tree:leaves` -> 5

|`group:wood`|
|------------|
|`group:wood`| = `tree:stick` \[4\]
