$year = Get-Date -Format "yyyy"
$week = Get-Date -UFormat "%V"
Write-Output "Year: $year, Week: $week"

$inputFilePath = "./$year/$week/data.json"
$outputFilePath = "./formatted_releases.json"

$bearerToken = $env:BEARER_TOKEN
$headers = @{
    "Accept" = "application/vnd.github+json"
    "Authorization" = "Bearer $bearerToken"
}

$inputData = Get-Content -Path $inputFilePath -Raw | ConvertFrom-Json
$formattedReleases = @()
foreach ($url in $inputData.releases) {
    if ($url -match "https://github.com/([^/]+)/([^/]+)/releases/tag/([^/]+)") {
        $ownerName = $matches[1]
        $repositoryName = $matches[2]
        $tagName = $matches[3]

        $releasesUrl = "https://api.github.com/repos/$ownerName/$repositoryName/releases/tags/$tagName"
        $releaseResponse = Invoke-RestMethod -Uri $releasesUrl -Method Get -Headers $headers
        $release = $releaseResponse | Select-Object -Property html_url, tag_name, name, draft, prerelease, created_at, published_at, body, author
        $author = @{
            login = $release.author.login
            avatar_url = $release.author.avatar_url
            html_url = $release.author.html_url
        }
        $release.author = $author
        $formattedReleases += $release

    } else {
        Write-Warning "Invalid URL: $url"
    }
}

$jsonOutput = $formattedReleases | ConvertTo-Json
Set-Content -Path $outputFilePath -Value $jsonOutput
Write-Debug "Successfully formatted releases to $outputFilePath"