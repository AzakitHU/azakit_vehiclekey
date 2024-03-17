# Vehicle key and lock
Create unique keys for vehicles and even give them to your partner so that he can also open/lock the vehicle.

* Easy configuration
* You can only create a key for your own vehicle
* The keys are unique, the vehicle registration number is stored in meta data
* You can open/lock your own vehicle even without a key. This can be set in the configuration file.
* Configurable price
* Configurable keybindings. Default letter [U].

# Preview
https://www.youtube.com/watch?v=0QgNZFyCHgI

# Install
- Download the [repository](https://github.com/AzakitHU/azakit_vehiclekey).
- Add the **azakit_vehiclekey** to your resources folder.
- Add `ensure azakit_vehiclekey` to your **server.cfg**.

# OX Inventory Items
	['vehicle_key'] = {
		label = 'vehicle key',
		weight = 15,
		stack = true,
		close = true,
		description = nil
	},

# Requirements
- ESX
- ox_lib
- ox_target
- ox_inventory
- esx_vehicleshop (The script reads the vehicle registration number from the owned_vehicles mysql table.)

# Documentation
You can find [Discord](https://discord.gg/DmsF6DbCJ9).
