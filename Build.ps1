Remove-Item "RoomBookmarks*.zip"

$PluginVersion = ((Get-Content info.toml | Select-String -Pattern "=" | ConvertFrom-StringData).version -split "`"")[1]
7z a "RoomBookmarks-v$PluginVersion.zip" info.toml src