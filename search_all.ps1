$startingDirectory = "\\PALMDC\shrData\Projects"
$pattern = Read-Host -Prompt 'Enter search pattern'
$maxDepth = 5
$maxResults = 15

# Initialize an empty array in the global scope
$options = @()

function Show-Menu {
    param (
        [string[]]$Options
    )

    Write-Host "Select an option (use arrow keys to navigate):"

    $selectedIndex = 0
    $totalOptions = $Options.Count

    while ($true) {
        for ($i = 0; $i -lt $totalOptions; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "> $($Options[$i])" -ForegroundColor Cyan
            } else {
                Write-Host "  $($Options[$i])"
            }
        }

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

        switch ($key) {
            38 {  # Up arrow key
                $selectedIndex = ($selectedIndex - 1) % $totalOptions
                if ($selectedIndex -lt 0) {
                    $selectedIndex += $totalOptions
                }
            }
            40 {  # Down arrow key
                $selectedIndex = ($selectedIndex + 1) % $totalOptions
            }
            13 {  # Enter key
                Invoke-Item -Path $Options[$selectedIndex]
                return $Options[$selectedIndex]
            }
        }

        # Clear the console before redrawing the menu
        [System.Console]::Clear()
    }
}

function Get-MatchedDirectories {

    param (
        [string]$searchPattern
    )

    $regexPattern = [regex]::new($searchPattern.Replace(" ", ".*"))
    $queue = [System.Collections.Generic.Queue[PSObject]]::new()
    $queue.Enqueue([PSCustomObject]@{Path = $startingDirectory; Depth = 0})
    $matchedDirectories = [System.Collections.Generic.List[string]]::new()

    while ($queue.Count -gt 0 -and $matchedDirectories.Count -lt $maxResults) {
        $current = $queue.Dequeue()
        if ($current.Depth -gt $maxDepth) { continue }

        try {
            $subDirs = [System.IO.Directory]::EnumerateDirectories($current.Path)
            foreach ($subDir in $subDirs) {
                if ($matchedDirectories.Count -ge $maxResults) { break }

                if ($regexPattern.IsMatch($subDir)) {
                    $matchedDirectories.Add($subDir)
                    $script:options += $subDir
                }

                if ($current.Depth + 1 -le $maxDepth) {
                    $queue.Enqueue([PSCustomObject]@{Path = $subDir; Depth = $current.Depth + 1})
                }
            }
        } catch {
            Write-Warning "Unable to access directory: $current.Path"
        }
    }

    return $matchedDirectories
}

while ($true) {
    $results = Get-MatchedDirectories -searchPattern $pattern
    if ($results.Count -eq 0) {
        Write-Host "No directories found matching the pattern."
    } else {
    	Show-Menu -Options $options
    }
    $script:options = @()
    $pattern = Read-Host -Prompt 'Enter search pattern (or type "exit" to close)'
    if ($pattern -eq "exit") {
        break
    }
}