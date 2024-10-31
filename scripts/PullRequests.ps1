$year = Get-Date -Format "yyyy"
$week = Get-Date -UFormat "%V"
Write-Debug "Year: $year, Week: $week"
$inputFilePath = "./$year/$week/data.json"
$outputFilePath = "./$year/$week/formatted_prs.json"

$inputData = Get-Content -Path $inputFilePath -Raw | ConvertFrom-Json
$formattedPRs = @()
foreach ($url in $inputData.pull_requests) {
    if ($url -match "https://github.com/([^/]+)/([^/]+)/pull/(\d+)") {
        $pr = Get-GitHubPullRequest -OwnerName $matches[1] -RepositoryName $matches[2] -PullRequest $matches[3]
        Write-Debug "Processing PR: " 
        Write-Debug $pr
        $formattedPRs += ([PSCustomObject]@{
            'URL' = $url
            'Number' = $pr.number
            'Organization' = $organization
            'Repository' = $repository
            'State' = $pr.state
            'Title' = $pr.title
            'Body' = $pr.body
            'Created' = $pr.created_at
            'Merged' = $pr.merged_at
            'Labels' = $pr.labels.name -join ', '
            'Draft' = $pr.draft
            'Head' = $pr.head.label
            'Base' = $pr.base.label
            'IsMerged' = $pr.merged
            'UserName' = $pr.user.login
            'UserURL' = $pr.user.html_url
            'UserAvatar' = $pr.user.avatar_url
        })
    } else {
        Write-Warning "Invalid URL: $url"
    }
}

$jsonOutput = $formattedPRs | ConvertTo-Json
Set-Content -Path $outputFilePath -Value $jsonOutput
Write-Debug "Successfully formatted PRs to $outputFilePath"