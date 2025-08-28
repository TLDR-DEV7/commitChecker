# === Configuration ===
$GitHubPath = "C:\Users\liamramsden\Documents\GitHub"
$OutputFile = "commit_log.csv"

function Get-Repositories {
    Get-ChildItem -Path $GitHubPath -Directory | Select-Object -ExpandProperty Name
}

function Select-Repository {
    $repos = Get-Repositories
    if ($repos.Count -eq 0) {
        Write-Host "❌ No repositories found in $GitHubPath."
        exit
    }

    Write-Host "`n📂 Available Repositories:"
    for ($i = 0; $i -lt $repos.Count; $i++) {
        Write-Host "$($i + 1). $($repos[$i])"
    }

    do {
        $choice = Read-Host "🔧 Enter the number of the repository to export commits from"
    } while (-not ($choice -match '^\d+$') -or $choice -lt 1 -or $choice -gt $repos.Count)

    return Join-Path $GitHubPath $repos[$choice - 1]
}

function Select-Branch($repoPath) {
    Set-Location $repoPath
    Write-Host "`n📦 Available branches:"
    git branch --list

    $branch = Read-Host "`n🔧 Enter the branch name to export commits from"
    git checkout $branch | Out-Null
    return $branch
}

function Build-GitLogCommand($author, $fromDate, $toDate) {
    $cmd = "git log --pretty=format:`"%H|%an|%ad|%s`" --date=iso"
    if ($author) { $cmd += " --author=`"$author`"" }
    if ($fromDate) { $cmd += " --since=`"$fromDate`"" }
    if ($toDate) { $cmd += " --until=`"$toDate`"" }
    return $cmd
}

function Export-Commits($cmd, $outputFile) {
    Write-Host "`n📤 Exporting commit log to '$outputFile'..."
    Invoke-Expression $cmd | ForEach-Object {
        $parts = $_ -split '\|'
        $dateTime = $parts[2].Trim()
        $date = ($dateTime -split ' ')[0]
        $time = ($dateTime -split ' ')[1]
        $formattedDate = ($date -split '-')[2] + "-" + ($date -split '-')[1] + "-" + ($date -split '-')[0]
        '"{0}","{1}","{2}","{3}","{4}"' -f $parts[0], $parts[1], $formattedDate, $time, $parts[3]
    } | Set-Content $outputFile

    Write-Host "📂 Opening file..."
    Start-Process $outputFile
}

# === Main Loop ===
do {
    $repoPath = Select-Repository
    $branch = Select-Branch $repoPath

    $author = Read-Host "👤 Enter author name to filter by (leave blank for all)"
    $fromDate = Read-Host "📅 From date (YYYY-MM-DD, leave blank for earliest)"
    $toDate = Read-Host "📅 To date (YYYY-MM-DD, leave blank for latest)"

    $gitCmd = Build-GitLogCommand $author $fromDate $toDate
    Export-Commits $gitCmd $OutputFile

    $repeat = Read-Host "`n🔁 Would you like to export another branch or repo? (y/n)"
} while ($repeat.ToLower() -eq 'y')

Write-Host "`n👋 Exiting. Goodbye!"

