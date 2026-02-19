namespace Save {
    const string SAVE_LOCATION = IO::FromStorageFolder("favorite_rooms.json");
    
    void UpdateSaveFile() {
        auto json = BookmarksManager::Root.ToJson();
        Json::ToFile(SAVE_LOCATION, json);
    }
    
    void LoadSaveFile() {
        if (!IO::FileExists(SAVE_LOCATION)) {
            return;
        }

        auto json = Json::FromFile(SAVE_LOCATION);
        BookmarksManager::Root = LoadFolder(json);
        BookmarksManager::Root.Name = "Bookmarks";
    }
    
    Folder@ LoadFolder(const Json::Value@ &in jsonFolder) {
        IFolderItem@[] contents;
        auto contentsJson = jsonFolder["contents"];
        for (uint i = 0; i < contentsJson.Length; i++) {
            if (contentsJson[i]["type"] == "bookmark") {
                auto bookmark = Bookmark();
                bookmark.Name = contentsJson[i]["name"];
                bookmark.ClubId = contentsJson[i]["clubId"];
                bookmark.RoomId = contentsJson[i]["roomId"];
                contents.InsertAt(contents.Length, bookmark);
            } else if (contentsJson[i]["type"] == "folder") {
                auto folder = LoadFolder(contentsJson[i]);
                contents.InsertAt(contents.Length, folder);
            }
        }

        auto folder = Folder();
        folder.Name = jsonFolder["name"];
        folder.Contents = contents;

        return folder;
    }
}