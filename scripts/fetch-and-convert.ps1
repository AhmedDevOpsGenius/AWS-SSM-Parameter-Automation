function Fetch-Parameters {
    param (
        [string]$ParameterPath
    )
    # Fetch parameters and return as JSON
    $parameters = aws ssm get-parameters-by-path `
        --path $ParameterPath `
        --recursive `
        --with-decryption `
        --query 'Parameters[*].{Name:Name,Value:Value}' `
        --output json

    return $parameters | ConvertFrom-Json
}

function Detect-Type {
    param (
        [string]$Value
    )

    # Check if it's an integer or a float
    if ($Value -match '^\d+$') {
        return "Integer"
    }
    elseif ($Value -match '^\d+\.\d+$') {
        return "Float"
    }
    else {
        return "String"
    }
}

function Format-Parameters {
    param (
        [array]$Parameters
    )

    # Initialize empty hash table for JSON structure
    $formattedOutput = @{}

    # Loop through each parameter
    foreach ($row in $Parameters) {
        # Extract the Name and Value from each row
        $fullName = $row.Name
        $value = $row.Value

        # Detect the data type of the value
        $dataType = Detect-Type -Value $value

        # Split the full name by its path components
        $parts = $fullName -split '/'

        # Extract parent, repo, and param_name
        $parent = $parts[1]
        $repo = $parts[2]

        # Check if the parent exists in the formatted output
        if (-not $formattedOutput.ContainsKey($parent)) {
            $formattedOutput[$parent] = @{}
        }

        # Check if repo exists in the parent
        if (-not $formattedOutput[$parent].ContainsKey($repo)) {
            $formattedOutput[$parent][$repo] = @()
        }

        # Add the parameter information (Name, Value, Type) to the repo
        $formattedOutput[$parent][$repo] += @{
            Name  = $parts[-1]  # The last part of the name is the parameter name
            Value = $value
            Type  = $dataType
        }
    }

    return $formattedOutput
}

# Path to the parameters in the parameter store 
$ParameterPath = "/"

# Fetch parameters
$parametersJson = Fetch-Parameters -ParameterPath $ParameterPath

# Format parameters to the desired structure
$formattedParameters = Format-Parameters -Parameters $parametersJson

# Save to a file (optional)
$formattedParameters | ConvertTo-Json -Depth 100 | Out-File -FilePath "parameters.json"

# Output the formatted parameters
Write-Output "Formatted Parameters in JSON format:"
$formattedParameters | ConvertTo-Json -Depth 100 | Write-Output
