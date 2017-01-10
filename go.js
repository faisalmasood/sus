/*
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
*/

// parse URL parameter
function gup( name, url ) {
    if (!url) url = location.href;
    name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    var regexS = "[\\?&]"+name+"=([^&#]*)";
    var regex = new RegExp( regexS );
    var results = regex.exec( url );
    return results == null ? null : results[1];
}

// HTTP call to REST api
function httpGet(theUrl)
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "GET", theUrl, false ); // false for synchronous request
    xmlHttp.setRequestHeader("accept", "application/json; odata=verbose");
    xmlHttp.send( null );
    return xmlHttp.responseText;
}

// parameters
var id = gup('id');
var q = gup('q');
console.log(id);
console.log(q);

// query SP list
if (id) {
	var url = "/_api/web/lists/getByTitle('go')/items?$filter=ID eq '" + id +"'";
} else {
	var url = "/_api/web/lists/getByTitle('go')/items?$filter=Title eq '" + q +"'";
}
var response = httpGet(url);
var j = JSON.parse(response);
var url = j.d.results[0].URL;
console.log(url);

// redirect
document.location.href = url;