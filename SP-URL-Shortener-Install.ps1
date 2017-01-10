<#
.SYNOPSIS
	SharePoint URL Shortener - Redirect ID# and Vanity short URL to any destination.
	
.DESCRIPTION
	Creates the supporting "/go/" folder with "default.aspx" and "go.js" front end.
	Creates the backing list "go" with columns URL, Title, and ID.
	
	NOTE - must run local to a SharePoint server under account with farm admin rights.

	Comments and suggestions always welcome!  spjeff@spjeff.com or @spjeff
	
.NOTES
	File Namespace	: SP-URL-Shortener-Install.ps1
	Author			: Jeff Jones - @spjeff
	Version			: 0.10
	Last Modified	: 01-10-2017
	
.LINK
	Source Code
	http://www.github.com/spjeff/sus
	
#>
param (
    $webAppUrl = "http://portal"
)

# Plugin
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue | Out-Null
$web = Get-SPWeb $webAppUrl

# Create SP list
$listName = "go"
$list = $web.Lists[$listName]
if (!$list) {
    $web.Lists.Add($listName, "", 100)
    $list = $web.Lists[$listName]
}
$url = $list.Fields["URL"]
if (!$url) {
    $type = [Microsoft.SharePoint.SPFieldType]::Text
    $list.Fields.Add("URL", $type, $true)
}

# Configure Title
$title = $list.Fields["Title"]
if ($title.Required) {
    $title.Required = $false
    $title.Indexed = $true
    $title.Update()
    $title.EnforceUniqueValues = $true
    $title.Update()
}

# Default view - add ID, URL
$dv = $list.DefaultView
$dv.ViewFields.Add("ID")
$dv.ViewFields.Add("URL")
$dv.Update()

# Create Folder /go/
$f = $web.RootFolder
$g = $f.SubFolders.Add("go")

# Upload files "go.js" and "default.aspx"
$js = Get-ChildItem "go.js"
$g.Files.Add("/go/go.js", $js.OpenRead(), $false)
$d = Get-ChildItem "default.aspx"
$g.Files.Add("/go/default.aspx", $d.OpenRead(), $false)

# Add test items for ?id=1 and ?q=sd
$item = $list.Items.Add()
$item["URL"] = "http://google.com"
$item.Update()

$item = $list.Items.Add()
$item["sd"]
$item["URL"]= "http://slashdot.org"
$item.Update()