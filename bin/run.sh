#!/bin/bash
killall skynet
sh master.sh
sh sql.sh
sh login.sh
sh game_1.sh
sh game_2.sh
sh ai.sh
