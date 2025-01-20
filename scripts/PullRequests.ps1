$year = Get-Date -Format "yyyy"
$week = Get-Date -UFormat "%V"
Write-Output "Year: $year, Week: $week"

$inputFilePath = "./$year/$week/data.json"
$outputFilePath = "./formatted_prs.json"

$bearerToken = $env:BEARER_TOKEN
$headers = @{
    "Accept" = "application/vnd.github+json"
    "Authorization" = "Bearer $bearerToken"
}

$inputData = Get-Content -Path $inputFilePath -Raw | ConvertFrom-Json
$formattedPRs = @()
foreach ($url in $inputData.pull_requests) {
    if ($url -match "https://github.com/([^/]+)/([^/]+)/pull/(\d+)") {
        $owner = $matches[1]
        $repository = $matches[2]
        $pullNumber = $matches[3]

        $pullRequestUrl = "https://api.github.com/repos/$owner/$repository/pulls/$pullNumber"
        $pullRequestResponse = Invoke-RestMethod -Uri $pullRequestUrl -Method Get -Headers $headers
        $pullRequest = $pullRequestResponse | Select-Object -Property html_url, number, title, state, created_at, updated_at, body, user, merged, draft, head, base
        $user = @{
            login = $pullRequest.user.login
            avatar_url = $pullRequest.user.avatar_url
            html_url = $pullRequest.user.html_url
        }
        $pullRequest.user = $user
        $formattedPRs += $pullRequest
    } else {
        Write-Warning "Invalid URL: $url"
    }
}

$jsonOutput = $formattedPRs | ConvertTo-Json
Set-Content -Path $outputFilePath -Value $jsonOutput
Write-Debug "Successfully formatted PRs to $outputFilePath"