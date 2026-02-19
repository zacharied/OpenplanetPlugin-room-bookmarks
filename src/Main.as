bool g_showMainMenu;

void Main() {
    Save::LoadSaveFile();
    BookmarksManager::SortTree();
    
    startnew(WatchServer::Main);
}

void OnDisabled() { 
    Save::UpdateSaveFile();
}

void OnDestroyed() { 
    Save::UpdateSaveFile();
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

        if (UI::MenuItem(Icons::Plus + " Bookmark this room", "", false, WatchServer::ClubId >= 0)) { 
            if (WatchServer::ClubId >= 0) {
                auto bookmark = Bookmark();
                bookmark.Name = Text::OpenplanetFormatCodes(WatchServer::ServerName);
                bookmark.ClubId = WatchServer::ClubId;
                bookmark.RoomId = WatchServer::RoomId;
                BookmarksManager::AddItem(bookmark);
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
        @Game::JoinTarget = bookmark;
        startnew(Game::TryJoinServer);
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