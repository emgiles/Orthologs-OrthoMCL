#!/bin/bash

# Define the Singularity image file path
SINGULARITY_IMAGE="orthomcl.simg"

# Define the path to the OrthoMCL configuration file
CONFIG_FILE="orthomcl.config"

# Run orthomclPairs within the Singularity container
singularity exec --bind $PWD --bind ${PWD}/mysql/run/mysqld:/run/mysqld "$SINGULARITY_IMAGE" orthomclPairs "$CONFIG_FILE" pairs3.log cleanup=no
