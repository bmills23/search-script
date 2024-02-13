# Prompt the user for a directory name and project folder
$directoryName = Read-Host -Prompt 'Enter directory name'
$projectName = Read-Host -Prompt 'Enter project folder'
Write-Host "You entered: $directoryName and $projectName"

# Define the base path combined with the directory name provided by the user
$path = "\\\$directoryName" 
Write-Host "Searching for project in $path..."

# Use Get-ChildItem to search for the project folder within the specified path
try {
    $matchingDirectories = Get-ChildItem -Path $path -Directory -Recurse -Filter "*$projectName*" -Depth 1

    if ($matchingDirectories.Count -gt 0) {
        # If there are multiple matches, this selects the first one. Adjust as necessary.
        $bestMatch = $matchingDirectories | Select-Object -First 1
        $bestMatchPath = $bestMatch.FullName
        Invoke-Item $bestMatchPath
    }
    else {
        # Optionally, open the base directory if no specific project folder is found
        Invoke-Item $path
    }
}
catch {
    Write-Host "An error occurred: $_"
} 