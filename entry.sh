#!/bin/bash

# Copy default config file to config dir (user volume) if it doesn't exist
cp -n \
    "$BASE_CONFIG_DIR"/serversettings.xml \
    "$BASE_CONFIG_DIR"/clientpermissions.xml \
    "$BASE_CONFIG_DIR"/permissionpresets.xml \
    "$BASE_CONFIG_DIR"/karmasettings.xml \
    "$CONFIG_DIR"

steamcmd \
    +force_install_dir "${HOME}" \
    +login anonymous \
    +app_update "${STEAM_APP_ID}" \
    +quit

"${HOME}"/DedicatedServer