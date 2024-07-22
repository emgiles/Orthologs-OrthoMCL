#!/bin/bash

# Loop through all files ending with uniquegenes_named_groups_1.5.txt
for input_file in *uniquegenes_named_groups_1.5.txt; do
  # Generate output file name by appending '_filtered' before the extension
  output_file="${input_file%.txt}_filtered.txt"

  # Clear the output file if it already exists
  > $output_file

  # Read each line from the input file
  while IFS= read -r line; do
    # Split the line into fields by spaces
    fields=($line)

    # Loop through each field
    for item in "${fields[@]}"; do
      # Check if the item matches the pattern
      if [[ $item =~ \|g[0-9]+\.t[0-9]+ ]]; then
        # Extract the gene name (e.g., g25938.t1)
        gene_name=$(echo $item | grep -o 'g[0-9]\+\.t[0-9]\+')

        # Check if the gene name ends with '1' or '2'
        if [[ $gene_name =~ ^g.*[12]$ ]]; then
          # Write the matching gene name to the output file
          echo $gene_name >> $output_file
        fi
      fi
    done
  done < $input_file

  # Print a message indicating the process is complete for the current file
  echo "Filtered gene names have been written to $output_file"
done

# Print a final message indicating all files have been processed
echo "All files have been processed."
