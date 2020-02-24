--**************************************************************************************************
--*    _______ __                                                                                  *
--*   |_     _|  |--.----.---.-.--.--.--.-----.-----.                                              *
--*     |   | |     |   _|  _  |  |  |  |     |__ --|                                              *
--*     |___| |__|__|__| |___._|________|__|__|_____|                                              *
--*    ______                                                                                      *
--*   |   __ \.-----.--.--.-----.-----.-----.-----.                                                *
--*   |      <|  -__|  |  |  -__|     |  _  |  -__|                                                *
--*   |___|__||_____|\___/|_____|__|__|___  |_____|                                                *
--*                                   |_____|                                                      *
--*                                                                                                *
--*                                                                                                *
--*       File:              GlobalValueEventBus.lua                                               *
--*       File Created:      Friday, 21st February 2020 10:14                                      *
--*       Author:            [TR] Pox                                                              *
--*       Last Modified:     Saturday, 22nd February 2020 04:38                                    *
--*       Modified By:       [TR] Pox                                                              *
--*       Copyright:         Thrawns Revenge Development Team                                      *
--*       License:           This code may not be used without the author's explicit permission    *
--**************************************************************************************************

require("eawx-std/class")
require("eawx-crossplot/serializer")
require("eawx-crossplot/GlobalValueQueue")

---@class GlobalValueEventBus
GlobalValueEventBus = class()

---@param name string
function GlobalValueEventBus:new(name)
    self.name = (name or tostring(Script))
    self.message_queue = GlobalValueQueue()
    self.subscribers = {}
end

---@param event_name string
function GlobalValueEventBus:subscribe(event_name, listener_function, optional_self)
    local subscription =
        serializer:serialize {
        name = self.name,
        event = event_name
    }

    if not self.subscribers[event_name] then
        self.subscribers[event_name] = {}
    end

    table.insert(
        self.subscribers[event_name],
        {
            func = listener_function,
            optional_self = optional_self
        }
    )

    self.message_queue:queue_value("busid:master:subscribe", subscription)
    DebugMessage("Registered listener for %s", event_name)
end

---@param event_name string
function GlobalValueEventBus:publish(event_name, ...)
    self.message_queue:queue_value(
        "busid:master:publish",
        serializer:serialize {
            event_name = event_name,
            args = arg
        }
    )
end

---@private
function GlobalValueEventBus:process_notifications()
    local notification = GlobalValue.Get("busid:" .. self.name .. ":notify")

    if not notification or notification == "" then
        return
    end

    notification = serializer:deserialize(notification)

    local event_name = notification.event_name
    local args = notification.args

    if not self.subscribers[event_name] then
        return
    end

    for _, subscriber in pairs(self.subscribers[event_name]) do
        if subscriber.optional_self then
            subscriber.func(subscriber.optional_self, unpack(args))
        else
            subscriber.func(unpack(args))
        end
    end

    GlobalValue.Set("busid:" .. self.name .. ":notify", "")
end

function GlobalValueEventBus:update()
    self:process_notifications()
    self.message_queue:process_global_values()
end

---@class MasterGlobalValueEventBus
MasterGlobalValueEventBus = class()

function MasterGlobalValueEventBus:new()
    self.name = "busid:master"

    ---@type table<string, string[]>
    self.subscribers = {}
    self.message_queue = GlobalValueQueue()
end

---@private
function MasterGlobalValueEventBus:process_subscriptions()
    local subscriber = GlobalValue.Get("busid:master:subscribe")

    if not subscriber or subscriber == "" then
        return
    end

    DebugMessage("Registering subscriber in MasterGlobalValueEventBus")

    subscriber = serializer:deserialize(subscriber)

    if type(subscriber) ~= "table" then
        return
    end

    if not (subscriber.name and subscriber.event) then
        return
    end

    if not (type(subscriber.name) == "string" and type(subscriber.event) == "string") then
        return
    end

    if not self.subscribers[subscriber.event] then
        self.subscribers[subscriber.event] = {}
    end

    table.insert(self.subscribers[subscriber.event], subscriber.name)
    GlobalValue.Set("busid:master:subscribe", "")
end

---@private
function MasterGlobalValueEventBus:process_publish_messages()
    local publish_data = GlobalValue.Get("busid:master:publish")

    if not publish_data or publish_data == "" then
        return
    end

    publish_data = serializer:deserialize(publish_data)

    self:publish(publish_data.event_name, unpack(publish_data.args))
    GlobalValue.Set("busid:master:publish", "")
end

---@param event_name string
---@param ... varargs
function MasterGlobalValueEventBus:publish(event_name, ...)
    local subscribers = self.subscribers[event_name]

    if not subscribers then
        return
    end

    for _, subscriber_name in pairs(subscribers) do
        self.message_queue:queue_value(
            "busid:" .. subscriber_name .. ":notify",
            serializer:serialize {
                event_name = event_name,
                args = arg
            }
        )
    end
end

function MasterGlobalValueEventBus:update()
    self:process_subscriptions()
    self:process_publish_messages()
    self.message_queue:process_global_values()
end
