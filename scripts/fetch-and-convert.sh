#!/bin/bash

# Function to fetch parameters from AWS Parameter Store
fetch_parameters() {
    PARAMETER_PATH="$1"
    # Fetch parameters and return as JSON
    aws ssm get-parameters-by-path \
        --path "$PARAMETER_PATH" \
        --recursive \
        --with-decryption \
        --query 'Parameters[*].{Name:Name,Value:Value}' \
        --output json
}

# Function to detect the data type of the value
detect_type() {
    local value="$1"
    # Check if it's an integer or a float
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "Integer"
    elif [[ "$value" =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo "Float"
    else
        echo "String"
    fi
}

# Function to reformat parameters into nested structure
format_parameters() {
    local parameters="$1"
    local formatted_output

    # Initialize empty associative array for JSON structure
    formatted_output="{}"

    # Loop through each parameter
    for row in $(echo "${parameters}" | jq -c '.[]'); do
        # Extract the Name and Value from each row
        full_name=$(echo "${row}" | jq -r '.Name')
        value=$(echo "${row}" | jq -r '.Value')

        # Detect the data type of the value
        data_type=$(detect_type "$value")

        # Break down the name by its path components
        IFS='/' read -ra PARTS <<< "$full_name"

        # Extract parent, repo, and param_name
        parent="${PARTS[1]}"
        repo="${PARTS[2]}"
        param_name="${PARTS[3]}"

        # Structure based on the hierarchy
        if [ -z "$repo" ]; then
            # If there's no repo, just add it under the parent
            formatted_output=$(echo "$formatted_output" | jq --arg parent "$parent" --arg name "$param_name" --arg value "$value" --arg type "$data_type" \
                '. + {($parent): (if .[$parent] then .[$parent] + [{"Name": $name, "Value": $value, "Type": $type}] else [{"Name": $name, "Value": $value, "Type": $type}] end)}')
        else
            # Otherwise, group by both parent and repo
            formatted_output=$(echo "$formatted_output" | jq --arg parent "$parent" --arg repo "$repo" --arg name "$param_name" --arg value "$value" --arg type "$data_type" \
                '. + {($parent): (if .[$parent] then .[$parent] + {($repo): (if .[$parent][$repo] then .[$parent][$repo] + [{"Name": $name, "Value": $value, "Type": $type}] else [{"Name": $name, "Value": $value, "Type": $type}] end)} else {($repo): [{"Name": $name, "Value": $value, "Type": $type}]} end)}')
        fi
    done

    # Print the final output
    echo "$formatted_output" | jq .
}

# Path to the parameters in the parameter store (e.g., /)
PARAMETER_PATH="/"

# Fetch parameters
PARAMETERS_JSON=$(fetch_parameters "$PARAMETER_PATH")

# Format parameters to the desired structure
FORMATTED_PARAMETERS=$(format_parameters "$PARAMETERS_JSON")

# Save to a file (optional)
echo "$FORMATTED_PARAMETERS" > parameters.json

# Output the formatted parameters
echo "Formatted Parameters in JSON format:"
echo "$FORMATTED_PARAMETERS"
