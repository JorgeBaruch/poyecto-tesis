$testString = "[[p=1]]`nSome content on page 1.`f[[p=2]]`nSome content on page 2."

$pages = $testString -split "`f" | Where-Object { $_ -ne "" }

foreach ($pageContent in $pages) {
    $pageNumber = 0
    $tempPage = $pageContent

    if ($tempPage -match "^\[\[p=(\d+)\]\]") {
        $pageNumber = $matches[1]
        $tempPage = $tempPage -replace "^\[\[p=\d+\]\][`r`n]+", ""
    }
    $page = $tempPage.Trim()

    Write-Host "Page Number: $pageNumber"
    Write-Host "Page Content: $page"
    Write-Host "---"
}