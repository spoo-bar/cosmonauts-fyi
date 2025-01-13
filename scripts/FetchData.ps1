$year = Get-Date -Format "yyyy"
$week = Get-Date -UFormat "%V"
Write-Debug "Year: $year, Week: $week"

$inputFilePath = "./watched_repos_test.json"
$inputData = Get-Content -Path $inputFilePath -Raw | ConvertFrom-Json
$outputFilePath = "./$year/$week/data.json"


$currentDate = Get-Date
$sevenDaysAgo = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ")

$allPullrequests = @()
$allIssues = @()
$allReleases = @()

foreach ($org in $inputData) {
    $organizationName = $org.Organisation
    Write-Output "Organization: $organizationName"
    
    foreach ($repo in $org.Repositories) {
        $repositoryName = $repo.Name
        Write-Output "  Repository: $repositoryName"
        $headers = @{
            "Accept" = "application/vnd.github.text+json"
        }

        # # Fetch pull requests created in the last 7 days
        # $url = "https://api.github.com/repos/$organizationName/$repositoryName/pulls?state=open&base=main"
        # $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers        
        # $recentPullRequests = $response | Where-Object {
        #     $createdAt = [DateTime]::Parse($_.created_at)
        #     ($currentDate - $createdAt).Days -le 7
        # }
        # $pullRequestUrls = $recentPullRequests | ForEach-Object { $_.html_url }
        # $allPullrequests += $pullRequestUrls
        
        # Fetch issues created in the last 7 days
        $issuesUrl = "https://api.github.com/repos/$organizationName/$repositoryName/issues?state=all&since=$sevenDaysAgo&sort=updated&direction=desc&per_page=100"
        $issuesResponse = Invoke-RestMethod -Uri $issuesUrl -Method Get -Headers $headers
        $recentIssues = $issuesResponse | Where-Object {
            $createdAt = [DateTime]::Parse($_.created_at)
            ($currentDate - $createdAt).Days -le 7
        }
        foreach ($issue in $recentIssues) {
            if ($issue.pull_request) {
                $allPullrequests += $issue.html_url
            } else {
                $allIssues += $issue.html_url
            }
        }
    
        # Fetch releases created in the last 7 days
        $releasesUrl = "https://api.github.com/repos/$organizationName/$repositoryName/releases"
        $releasesResponse = Invoke-RestMethod -Uri $releasesUrl -Method Get -Headers $headers
        $recentReleases = $releasesResponse | Where-Object {
            $createdAt = [DateTime]::Parse($_.created_at)
            ($currentDate - $createdAt).Days -le 7
        }
        $releaseUrls = $recentReleases | ForEach-Object { $_.html_url }
        $allReleases += $releaseUrls
    }
}

$outputData = @{
    PullRequests = $allPullrequests
    Issues = $allIssues
    Releases = $allReleases
}
$outputJson = $outputData | ConvertTo-Json

# Ensure the output directory exists
$outputDirectory = Split-Path -Path $outputFilePath -Parent
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -Path $outputDirectory -ItemType Directory | Out-Null
}

Set-Content -Path $outputFilePath -Value $outputJson
Write-Debug "Successfully fetched data to $outputFilePath"