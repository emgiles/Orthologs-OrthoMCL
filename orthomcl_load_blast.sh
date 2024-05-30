#!/bin/bash

# Define the Singularity image file path
SINGULARITY_IMAGE="orthomcl.simg"

# Define the path to the OrthoMCL configuration file
CONFIG_FILE="orthomcl.config"

# Define the similar sequences file
SIMILAR_SEQ_FILE="similarSequences.txt"

# Run orthomclPairs within the Singularity container
singularity exec --bind $PWD --bind ${PWD}/mysql/run/mysqld:/run/mysqld "$SINGULARITY_IMAGE" orthomclLoadBlast "$CONFIG_FILE" "$SIMILAR_SEQ_FILE"
