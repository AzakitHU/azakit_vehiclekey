LANGUAGE = 'en'
Config = {}

KeyPrice = 150 -- The price of creating a key
LockKey = 'U'-- default opening/closing of vehicle
EngineKey = 'G' -- default engine start/stop

ITEM = "vehicle_key"  -- The basic vehicle key item. Meta data will always be added to this.
OWNER = false  -- If this is true, then the owner of the vehicle can open/lock his car without a vehicle_key item

LOCKPICK = true -- if true, the vehicle can be hacked using ox_target and ox_lib
LOCKPICK_DOOR = "lockpick"  -- item needed to break a door
LOCKPICK_ENGINE = "lockpick"  -- item needed to hack engine
LOCKPICK_ENGINE_REMOVE = false -- If true, you will lose the item when hacking the engine

START_NPC = {
    ped = {
        model = "ig_omega",
        coords = vector3(1207.3246, -3122.3772, 4.5403),
        heading = 2.5938
    }
}

Webhook = "https://discord.com/api/webhooks/1193944718019670168/Dp8XKt9UPm61XYBBMkjgIj3x3v5xA4cNq55sAFIYY3ojWa5lh-gnTckMi8sBTYdPVKah" -- Discord Webhook
