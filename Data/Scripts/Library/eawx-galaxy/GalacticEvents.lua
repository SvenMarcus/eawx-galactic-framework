--******************************************************************************
--     _______ __
--    |_     _|  |--.----.---.-.--.--.--.-----.-----.
--      |   | |     |   _|  _  |  |  |  |     |__ --|
--      |___| |__|__|__| |___._|________|__|__|_____|
--     ______
--    |   __ \.-----.--.--.-----.-----.-----.-----.
--    |      <|  -__|  |  |  -__|     |  _  |  -__|
--    |___|__||_____|\___/|_____|__|__|___  |_____|
--                                    |_____|
--*   @Author:              [TR]Pox
--*   @Date:                2018-03-10T01:31:48+01:00
--*   @Project:             Imperial Civil War
--*   @Filename:            GalacticEvents.lua
--*   @Last modified by:    [TR]Pox
--*   @Last modified time:  2018-03-10T19:30:51+01:00
--*   @License:             This source code may only be used with explicit permission from the developers
--*   @Copyright:           © TR: Imperial Civil War Development Team
--******************************************************************************

require("eawx-std/class")
require("eawx-std/Observable")
require("eawx-crossplot/crossplot")

---@class PlanetOwnerChangedEvent : Observable
PlanetOwnerChangedEvent = class(Observable)

function PlanetOwnerChangedEvent:new(planets)
    self.planets = planets
    crossplot:subscribe("PLANET_OWNER_CHANGED", self.planet_owner_changed, self)
end

function PlanetOwnerChangedEvent:planet_owner_changed(planet_name)
    if not planet_name then
        return
    end

    local planet = self.planets[planet_name]
    self:Notify(planet)
end

---@class ProductionStartedEvent : Observable
ProductionStartedEvent = class(Observable)

function ProductionStartedEvent:new(planets)
    ---@private
    ---@type Planet[]
    self.planets = planets
    crossplot:subscribe("PRODUCTION_STARTED", self.production_started, self)
end

function ProductionStartedEvent:production_started(planet_name, object_type_name)
    local planet = self.planets[planet_name]
    self:Notify(planet, object_type_name)
end

---@class ProductionFinishedEvent : Observable
ProductionFinishedEvent = class(Observable)

function ProductionFinishedEvent:new(planets)
    self.planets = planets
    crossplot:subscribe("PRODUCTION_FINISHED", self.production_finished, self)
end

function ProductionFinishedEvent:production_finished(planet_name, object_type_name)
    local planet = self.planets[planet_name]
    self:Notify(planet, object_type_name)
end

---@class ProductionCanceledEvent : Observable
ProductionCanceledEvent = class(Observable)

function ProductionCanceledEvent:new(planets)
    ---@private
    ---@type Planet[]
    self.planets = planets
    crossplot:subscribe("PRODUCTION_CANCELED", self.production_canceled, self)
end

function ProductionCanceledEvent:production_canceled(planet_name, object_type_name)
    local planet = self.planets[planet_name]
    self:Notify(planet, object_type_name)
end

---@class TacticalBattleStartingEvent : Observable
TacticalBattleStartingEvent = class(Observable)

function TacticalBattleStartingEvent:new()
    crossplot:subscribe("TACTICAL_BATTLE_BEGINNING", self.tactical_battle_starting, self)
end

function TacticalBattleStartingEvent:tactical_battle_starting()
    self:Notify()
end

---@class TacticalBattleEndingEvent : Observable
TacticalBattleEndingEvent = class(Observable)

function TacticalBattleEndingEvent:new()
    crossplot:subscribe("TACTICAL_BATTLE_ENDING", self.tactical_battle_ending, self)
end

function TacticalBattleEndingEvent:tactical_battle_ending()
    self:Notify()
end

---@class GalacticHeroKilledEvent : Observable
GalacticHeroKilledEvent = class(Observable)

function GalacticHeroKilledEvent:new()
    crossplot:subscribe("GALACTIC_HERO_KILLED", self.galactic_hero_killed, self)
end

function GalacticHeroKilledEvent:galactic_hero_killed(hero_name)
    self:Notify(hero_name)
end
