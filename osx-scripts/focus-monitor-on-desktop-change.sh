#!/bin/bash

mon_id=$(chunkc tiling::query --monitor id)
mon_for_desk=$(chunkc tiling::query --monitor-for-desktop $1)

if [[ "$mon_id" != "$mon_for_desk" ]]; then
  chunkc tiling::monitor -f "$mon_for_desk"
fi
