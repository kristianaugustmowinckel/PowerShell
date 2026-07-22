function Invoke-MakeStatFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$OutDir = "\\hvl.no\tilsett\Data\IT\IT-Users\kam"
    )

    begin {

        $pname = Split-Path $Path -Leaf

        $outfileCsv = Join-Path $OutDir "$pname.csv"
        $outfileXlsx = Join-Path $OutDir "$pname.xlsx"

        function Get-FolderStat {
            param([string]$Folder)

            if (Test-Path $Folder) {
                [PSCustomObject]@{
                    Size  = Measure-dirsize -Path $Folder
                    Count = (Get-ChildItem -Path $Folder -File -Recurse -ErrorAction SilentlyContinue).Count
                }
            }
            else {
                [PSCustomObject]@{
                    Size  = 0
                    Count = 0
                }
            }
        }
    }

    process {

        $result = foreach ($dir in Get-ChildItem -Path $Path -Directory) {

            Write-Verbose "Processing $($dir.Name)"

            $adUser = Get-ADUser -Identity $dir.Name `
                                 -Properties DisplayName, Enabled `
                                 -ErrorAction SilentlyContinue

            $documents = Get-FolderStat (Join-Path $dir.FullName "Documents")
            $desktop   = Get-FolderStat (Join-Path $dir.FullName "Desktop")
            $pictures  = Get-FolderStat (Join-Path $dir.FullName "Pictures")
            $videos    = Get-FolderStat (Join-Path $dir.FullName "Videos")
            $music     = Get-FolderStat (Join-Path $dir.FullName "Music")
            $favorites = Get-FolderStat (Join-Path $dir.FullName "Favorites")

            [PSCustomObject]@{

                SamAccountName = $dir.Name

                DisplayName = $adUser.DisplayName

                Status = if ($null -eq $adUser) {
                    "NotExists"
                }
                elseif ($adUser.Enabled) {
                    "Enabled"
                }
                else {
                    "Disabled"
                }

                FullName = $dir.FullName

                Size  = Measure-dirsize $dir.FullName
                Count = (Get-ChildItem $dir.FullName -File -Recurse -ErrorAction SilentlyContinue).Count

                SizeDocuments  = $documents.Size
                CountDocuments = $documents.Count

                SizeDesktop  = $desktop.Size
                CountDesktop = $desktop.Count

                SizePictures  = $pictures.Size
                CountPictures = $pictures.Count

                SizeVideos  = $videos.Size
                CountVideos = $videos.Count

                SizeMusic  = $music.Size
                CountMusic = $music.Count

                SizeFavorites  = $favorites.Size
                CountFavorites = $favorites.Count
            }
        }

        $result | Export-Csv -Path $outfileCsv -NoTypeInformation -Encoding UTF8

        $result | Export-Excel `
            -Path $outfileXlsx `
            -WorksheetName $pname `
            -AutoSize `
            -FreezeTopRow `
            -FreezeFirstColumn `
            -BoldTopRow
    }
}