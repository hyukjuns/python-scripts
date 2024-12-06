param(
    $eventGridEvent, 
    $TriggerMetadata
)

# Print whole message
$eventGridEvent | convertto-json | Write-Host

# Get Resource Id
$resourceId=$eventGridEvent.data.resourceUri

# Get caller
$createBy=$eventGridEvent.data.claims.name
if ( $createBy -eq $null ) {
    $createBy=$eventGridEvent.data.claims.idtyp+" ("+$eventGridEvent.data.claims.appid+") "
}

# Check if tag exist
$resourceTags=Get-AzTag -ResourceId $resourceId
$isTagExist=$resourceTags.Properties.TagsProperty.ContainsKey('CreatedBy')

if ( $isTagExist -eq $false ) {
    $tags = @{"CreatedBy"="$createBy";}

    try {
        Update-AzTag -ResourceId $resourceId -Tag $tags -operation Merge -ErrorAction Stop
    }
    catch {
        $err = $_.Exception.message
        Write-Host "Error Occured : $err"
        exit
    }
    Write-Host "Added 'CreatedBy' tag with user: $createBy"
}
else {
    Write-Host $resourceId
    Write-Host "Tag 'CreatedBy' already exists"
}