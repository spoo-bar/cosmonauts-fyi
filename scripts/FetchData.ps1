$year = Get-Date -Format "yyyy"
$week = Get-Date -UFormat "%V"
Write-Debug "Year: $year, Week: $week"

$inputFilePath = "./watched_repos.json"
$inputData = Get-Content -Path $inputFilePath -Raw | ConvertFrom-Json
$outputFilePath = "./$year/$week/data.json"


$currentDate = Get-Date
$sevenDaysAgo = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ")

$allPullrequests = @()
$allIssues = @()
$allReleases = @()
$bearerToken = $env:BEARER_TOKEN

foreach ($org in $inputData) {
    $organizationName = $org.Organisation
    Write-Output "Organization: $organizationName"
    
    foreach ($repo in $org.Repositories) {
        $repositoryName = $repo.Name
        Write-Output "  Repository: $repositoryName"
        $headers = @{
            "Accept" = "application/vnd.github.text+json"
            "Authorization" = "Bearer $bearerToken"
        }
        
        # Fetch issues created in the last 7 days
        $issuesUrl = "https://api.github.com/repos/$organizationName/$repositoryName/issues?state=all&since=$sevenDaysAgo&sort=updated&direction=desc&per_page=100"
        $issuesResponse = Invoke-RestMethod -Uri $issuesUrl -Method Get -Headers $headers
        foreach ($issue in $issuesResponse) {
            if ($issue.pull_request) {
                if ($issue.user.login -ne "dependabot[bot]" -and $issue.user.login -ne "mergify[bot]") {
                    $allPullrequests += $issue.html_url
                }
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

        Write-Output "    Pull Requests: $($allPullrequests.Count)"
        Write-Output "    Issues: $($allIssues.Count)"
        Write-Output "    Releases: $($allReleases.Count)"
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
Write-Output "Successfully fetched data to $outputFilePath"

