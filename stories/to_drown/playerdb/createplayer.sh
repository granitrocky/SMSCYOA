#!/bin/bash

# Inserting default data into my structure
sqlite3 playerdb "INSERT INTO players (playerID,progress,seen) VALUES ('$1','0','0')";
