fx_version "adamant"
game "gta5"
lua54 'yes'

name         'azakit_vehiclekey'
version      '1.0.0'
author 'Azakit'
description 'Vehicle key and lock'

client_scripts {
    'config.lua',
	"locales/*",
    '@es_extended/locale.lua',
    'client/*'
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
	"locales/*",
	'config.lua',
    'server/*'
}

shared_scripts {
    '@ox_lib/init.lua',
	'@es_extended/imports.lua',
}

dependencies {
    'es_extended',
    'mysql-async'
}