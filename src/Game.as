namespace Game {
    int get_ClubId() { 
        return RouterWatch::ClubId < 0 ? WatchServer::ClubId : RouterWatch::ClubId;
    }
    
    int get_RoomId() {
        return RouterWatch::RoomId < 0 ? WatchServer::RoomId : RouterWatch::RoomId;
    }
    
    string get_RoomName() {
        return RouterWatch::RoomName.Length == 0 ? WatchServer::ServerName : RouterWatch::RoomName;
    }

    void TryJoinServer(ref@ bookmarkRef) {
        auto bookmark = cast<Bookmark@>(bookmarkRef);
        if (bookmark is null) {
            warn("Invalid object handle for TryJoinServer");
            return;
        }

        if (!Permissions::PlayPublicClubRoom()) {
            UI::ShowNotification("Cannot join", "Your account does not have permission to join club rooms!");
            return;
        }

        try {
            UI::ShowNotification("Joining room", "Joining bookmarked room \"\\$<" + bookmark.Name + "\\$>\". This may take a while if the server needs to start up."); 
            JoinServer(bookmark.ClubId, bookmark.RoomId);
        } catch {
            UI::ShowNotification("Failed to join", "Unable to join bookmarked room \"\\$<" + bookmark.Name + "\\$>\".", vec4(.9, .3, .1, .3));
        }
    }

    // Join a server by getting the joinlink for a given club and room
    void JoinServer(uint clubId, uint roomId) {
        if (clubId < 0 || roomId < 0) {
            return; 
        }

        string pw;
        //if (password.Length > 0) {
        //    pw = ":" + password;
        //}
        Json::Value@ joinLink = API::GetJoinLink(clubId, roomId);
        uint count = 0;
        while (!JoinLinkReady(joinLink) && count < 10) {
            count++;
            sleep(2000);
            @joinLink = API::GetJoinLink(clubId, roomId);
        }
        if (count >= 10) {
            throw("No server was available after 10 retries (20+ seconds)");
        }
        string jl = joinLink.Get('joinLink', '');
        auto link = jl.Replace("#join", "#qjoin") + pw;
        ReturnToMenu();
        trace("Joining: " + link);
        cast<CGameManiaPlanet>(GetApp()).ManiaPlanetScriptAPI.OpenLink(link, CGameManiaPlanetScriptAPI::ELinkType::ManialinkBrowser);
    }

    bool JoinLinkReady(Json::Value@ pl) {
        if (pl is null || pl.GetType() != Json::Type::Object) return false;
        if (!pl.HasKey("joinLink") || !pl.HasKey("starting")) return false;
        if (bool(pl.Get("starting", true))) return false;
        return true;
    }

    void ReturnToMenu(bool yieldTillReady = false) {
        auto app = cast<CGameManiaPlanet>(GetApp());
        if (app.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed) {
            app.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);
        }
        app.BackToMainMenu();
        while (yieldTillReady && !app.ManiaTitleControlScriptAPI.IsReady) yield();
    }
}