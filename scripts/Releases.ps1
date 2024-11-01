$year = Get-Date -Format "yyyy"
$week = Get-Date -UFormat "%V"
Write-Debug "Year: $year, Week: $week"
$inputFilePath = "./$year/$week/data.json"
$outputFilePath = "./$year/$week/formatted_releases.json"

$inputData = Get-Content -Path $inputFilePath -Raw | ConvertFrom-Json
$formattedReleases = @()
foreach ($url in $inputData.releases) {
    if ($url -match "https://github.com/([^/]+)/([^/]+)/releases/tag/([^/]+)") {
       $release = Get-GitHubRelease -OwnerName $matches[1] -RepositoryName $matches[2] -Tag $matches[3]
        Write-Debug "Processing Release: " 
        Write-Debug $release
        $formattedReleases += ([PSCustomObject]@{
            'URL' = $release.html_url
            'Organization' = $matches[1]
            'Repository' = $matches[2]
            'TagName' = $release.tag_name
            'Name' = $release.name
            'Draft' = $release.draft
            'Prerelease' = $release.prerelease
            'CreatedAt' = $release.created_at
            'PublishedAt' = $release.published_at
            'Assets' = $release.assets.browser_download_url -Join ', '
            'Body' = $release.body
            'AuthorName' = $release.author.UserName
            'AuthorAvatar' = $release.author.avatar_url
            'AuthorType' = $release.author.type
        })
    } else {
        Write-Warning "Invalid URL: $url"
    }
}

$jsonOutput = $formattedReleases | ConvertTo-Json
Set-Content -Path $outputFilePath -Value $jsonOutput
Write-Debug "Successfully formatted releases to $outputFilePath"