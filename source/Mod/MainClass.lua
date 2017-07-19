-- Using the CAS namespace.
use 'CAS'

-- Initializing the main class.
local MainClass = class()

--------------------
-- Static methods --
--------------------

--- Hello world!
--
MainClass.main = function()
  Console.parse('sv_gamemode', 1)
  Console.parse('mp_randomspawn', 1)
  Console.parse('mp_infammo', 1)
end

-------------------
MainClass.player = {}
MainClass.weapons = {
  ItemType.laser,
  ItemType.rocketlauncher,
  ItemType.grenadelauncher,
  ItemType.ak47,
  ItemType.galil,
  ItemType.mp5,
  ItemType.tmp,
  ItemType.m3,
  ItemType.p228,
  ItemType.knife
}
MainClass.hooks = {
  -- On join, creating a data table for this player.
  join = Hook('join', function(player)
    MainClass.player[player] = {
      kills = 0,
      level = 1
    }
  end),

  -- On leave, removing the data table of this player.
  leave = Hook('leave', function(player)
    MainClass.player[player] = nil
  end),

  -- On startround, reset everyone's values.
  startround_prespawn = Hook('startround_prespawn', function(mode)
    for _, player in pairs(Player.getPlayers()) do
      MainClass.player[player].kills = 0
      MainClass.player[player].level = 1
    end

    DynObjectType.barricade:spawn(1, 1, 0, 1, false)
  end),
  spawn = Hook('spawn', function(player)
    -- Remove knife.
    player:strip(ItemType.knife)
    -- Equip with weapon for the current level.
    return MainClass.weapons[MainClass.player[player].level]
  end),
  kill = Hook('kill', function(killer, victim, weapon, x, y, object)
    -- Add a kill to the killer.
    MainClass.player[killer].kills = MainClass.player[killer].kills + 1
    -- Check for the next level.
    if MainClass.player[killer].kills >= 3 then
      -- Reset kills.
      MainClass.player[killer].kills = 0
      -- Level up.
      MainClass.player[killer].level = MainClass.player[killer].level + 1
      -- Check for the win.
      if MainClass.player[killer].level > #MainClass.weapons then
        -- Congratulate the player.
        Game.messageToChat(Color.green, killer:getName() .. ' has won the game!')
        -- Restart the round.
        Console.parse('restart')
      else
        if killer:getHealth() > 0 then
          -- Equip the new weapon.
          killer:equip(MainClass.weapons[MainClass.player[killer].level])
          -- Strip the old one.
          killer:strip(MainClass.weapons[MainClass.player[killer].level - 1])
        end
      end
    end

    -- Display info.
    killer:messageToChat('Level: ' .. MainClass.player[killer].level .. '; kills: ' .. MainClass.player[killer].kills)
  end),

  -- No buying.
  buy = Hook('buy', function()
    return 1
  end),

  -- No collecting.
  walkover = Hook('walkover', function(player, item, itemType)
    if itemType:getType() >= 61 and itemType:getType() <= 68 then
      return 0
    end

    return 1
  end),

  -- No dropping.
  drop = Hook('drop', function()
    return 1
  end),

  -- No death dropping.
  die = Hook('die', function()
    return 1
  end)
}

-------------------------
-- Returning the class --
-------------------------
return MainClass
