# RexshackGaming
- discord : https://discord.gg/eW3ADkf4Af
- youtube : https://www.youtube.com/channel/UCikEgGfXO-HCPxV5rYHEVbA
- github : https://github.com/Rexshack-RedM

# Dependancies
- rsg-core

# Installation
- ensure that the dependancies are added and started
- add rsg-hunting to your resources folder
- add items to your "\rsg-core\shared\items.lua"
- add images to your "\rsg-inventory\html\images"
- add the following table to your database : rsg-hunting.sql

# add to rsg-npc config
```lua
    {   -- hunting camp 1
        model = `casp_hunting02_males_01`,
        coords = vector4(181.16, 340.88, 120.62, 153.50),
    },
    {   -- hunting camp 2
        model = `casp_hunting02_males_01`,
        coords = vector4(2137.70, -631.67, 42.72, 320.75),
    },
```

# Starting the resource
- add the following to your server.cfg file : ensure rsg-hunting