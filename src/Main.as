bool g_showMainMenu;

void Main() {
    Save::LoadSaveFile();
    BookmarksManager::SortTree();
    
    MLHook::RegisterMLHook(RouterPushHook(), "", true);
    MLHook::RegisterMLHook(RouterPushParentHook(), "", true);
    
    startnew(WatchServer::Main);
}

void OnDisabled() { 
    Save::UpdateSaveFile();
    MLHook::UnregisterMLHooksAndRemoveInjectedML();
}

void OnDestroyed() { 
    Save::UpdateSaveFile();
    MLHook::UnregisterMLHooksAndRemoveInjectedML();
}

void Render() {
    if (g_showMainMenu) {
        MainWindow::Render();
    }
    
    Renderables::Render();
}

void RenderMenu() {
    if (UI::BeginMenu(Icons::Bookmark + " Room Bookmarks")) {
        if (UI::MenuItem(Icons::WindowMaximize + " Bookmarks menu")) {
            g_showMainMenu = true;
        }

        if (UI::MenuItem(Icons::Plus + " Bookmark this room", "", false, Game::RoomId >= 0)) { 
            if (Game::ClubId >= 0 && Game::RoomId >= 0) {
                auto bookmark = Bookmark();
                bookmark.Name = Game::RoomName.Length > 0 ? Text::OpenplanetFormatCodes(Game::RoomName) : "Untitled bookmark";
                bookmark.ClubId = Game::ClubId;
                bookmark.RoomId = Game::RoomId;
                BookmarksManager::AddItem(bookmark);
                UI::ShowNotification("Bookmark added", "\"\\$<" + bookmark.Name + "\\$>\" has been added as a bookmark.");
            } else {
                UI::ShowNotification("Unable to bookmark", "Failed to find the room associated with the current server.", vec4(.9, .3, .1, .3));
            }
        }
        
        if (BookmarksManager::Root.Contents.Length >= 0) {
            UI::Separator();
        }
        
        for (uint i = 0; i < BookmarksManager::Root.Contents.Length; i++) {
            RenderMenuItem(BookmarksManager::Root.Contents[i]); 
        }
        
        UI::EndMenu();
    }
}

void RenderMenuItem(IFolderItem@ item) {
    auto itemBookmark = cast<Bookmark@>(item);
    auto itemFolder = cast<Folder@>(item);
    if (itemBookmark !is null) {
        RenderMenuBookmark(itemBookmark);
    } else if (itemFolder !is null) {
        RenderMenuFolder(itemFolder);                
    }
}

void RenderMenuBookmark(Bookmark@ &in bookmark) {
    UI::PushID(bookmark);
    if (UI::MenuItem(bookmark.Name)) {
        startnew(Game::TryJoinServer, bookmark);
    }
    UI::PopID();
}

void RenderMenuFolder(Folder@ &in folder) {
    UI::PushID(folder);
    if (UI::BeginMenu(folder.Name)) {
        foreach (auto item : folder.Contents) {
            RenderMenuItem(item);
        }
        UI::EndMenu();
    }
    UI::PopID();
}