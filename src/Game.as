namespace Game {
    bool CancelJoinRoom = false;

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

        auto modal = JoinServerModal(bookmark, function() { Game::CancelJoinRoom = true; });
        Renderables::Add(modal);

        while (true) {
            if (modal.ShouldDisappear())
                break;
            
            modal.JoinFailed = false;

            try {
                JoinServer(bookmark.ClubId, bookmark.RoomId);
                modal.JoinCompleted = true;
            } catch {
                modal.JoinFailed = true;
            }
            
            while (!modal.RetryRequested && !modal.ShouldDisappear())
                yield();
        }
    }

    // Join a server by getting the joinlink for a given club and room
    void JoinServer(uint clubId, uint roomId) {
        if (clubId < 0 || roomId < 0) {
            return; 
        }
        
        CancelJoinRoom = false;

        string pw;
        //if (password.Length > 0) {
        //    pw = ":" + password;
        //}

        Json::Value@ joinLink = API::GetJoinLink(clubId, roomId);
        if (CancelJoinRoom) {
            trace("Room join request canceled by user");
            return;
        }

        uint count = 0;
        while (!JoinLinkReady(joinLink) && count < 10) {
            count++;
            sleep(2000);
            @joinLink = API::GetJoinLink(clubId, roomId);

            if (CancelJoinRoom) {
                trace("Room join request canceled by user");
                return;
            }
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
    
    class JoinServerData {
        int ClubId = -1;
        int RoomId = -1; 
    }
}