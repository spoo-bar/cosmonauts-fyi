$year = Get-Date -Format "yyyy"
$week = Get-Date -UFormat "%V"
Write-Output "Year: $year, Week: $week"

$inputFilePath = "./$year/$week/data.json"
$outputFilePath = "./formatted_issues.json"

$bearerToken = $env:BEARER_TOKEN
$headers = @{
    "Accept" = "application/vnd.github+json"
    "Authorization" = "Bearer $bearerToken"
}

$inputData = Get-Content -Path $inputFilePath -Raw | ConvertFrom-Json
$formattedIssues = @()
foreach ($url in $inputData.issues) {
    if ($url -match "https://github.com/([^/]+)/([^/]+)/issues/(\d+)") {
        $ownerName = $matches[1]
        $repositoryName = $matches[2]
        $issueNumber = $matches[3]

        $issuesUrl = "https://api.github.com/repos/$ownerName/$repositoryName/issues/$issueNumber"
        $issueResponse = Invoke-RestMethod -Uri $issuesUrl -Method Get -Headers $headers
        $issue = $issueResponse | Select-Object -Property html_url, number, title, state, locked, created_at, closed_at, body, user, labels
        $user = @{
            login = $issue.user.login
            avatar_url = $issue.user.avatar_url
            html_url = $issue.user.type
        }
        $issue.user = $user
        $formattedIssues += $issue
    } else {
        Write-Warning "Invalid URL: $url"
    }
}

$jsonOutput = $formattedIssues | ConvertTo-Json
Set-Content -Path $outputFilePath -Value $jsonOutput
Write-Debug "Successfully formatted issues to $outputFilePath"