$year = Get-Date -Format "yyyy"
$week = Get-Date -UFormat "%V"
Write-Debug "Year: $year, Week: $week"
$inputFilePath = "./$year/$week/data.json"
$outputFilePath = "./$year/$week/formatted_issues.json"

$inputData = Get-Content -Path $inputFilePath -Raw | ConvertFrom-Json
$formattedIssues = @()
foreach ($url in $inputData.issues) {
    if ($url -match "https://github.com/([^/]+)/([^/]+)/issues/(\d+)") {
        $issue = Get-GitHubIssue -OwnerName $matches[1] -RepositoryName $matches[2] -Issue $matches[3]
        Write-Debug "Processing Issues: " 
        Write-Debug $issue
        $formattedIssues += ([PSCustomObject]@{
            'URL' = $issue.html_url
            'Organization' = $matches[1]
            'Repository' = $matches[2]
            'Number' = $issue.number
            'Title' = $issue.title
            'State' = $issue.state
            'Locked' = $issue.locked
            'CreatedAt' = $issue.created_at
            'ClosedAt' = $issue.closed_at
            'Body' = $issue.Body
            'User' = $issue.user.UserName
            'UserAvatar' = $issue.user.avatar_url
            'UserType' = $issue.user.type
            'Labels' = $issue.labels.LabelName -join ', '
        })
    } else {
        Write-Warning "Invalid URL: $url"
    }
}

$jsonOutput = $formattedIssues | ConvertTo-Json
Set-Content -Path $outputFilePath -Value $jsonOutput
Write-Debug "Successfully formatted issues to $outputFilePath"