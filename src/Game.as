namespace Game {
    Bookmark@ JoinTarget;
    
    void TryJoinServer() {
        try {
            UI::ShowNotification("Joining room", "Joining bookmarked room \"" + JoinTarget.Name + "\". This may take a while if the server needs to start up."); 
            JoinServer();
        } catch {
            UI::ShowNotification("Failed to join", "Unable to join bookmarked room \"" + JoinTarget.Name + "\".", vec4(.9, .3, .1, .3));
        }
    }

    // Join a server by getting the joinlink for a given club and room
    void JoinServer() {
        if (JoinTarget is null) {
            return; 
        }

        string pw;
        //if (password.Length > 0) {
        //    pw = ":" + password;
        //}
        Json::Value@ joinLink = API::GetJoinLink(JoinTarget.ClubId, JoinTarget.RoomId);
        uint count = 0;
        while (!JoinLinkReady(joinLink) && count < 10) {
            count++;
            sleep(2000);
            @joinLink = API::GetJoinLink(JoinTarget.ClubId, JoinTarget.RoomId);
        }
        if (count >= 10) {
            throw("No server was available after 10 retries (20+ seconds)");
        }
        string jl = joinLink.Get('joinLink', '');
        auto link = jl.Replace("#join", "#qjoin") + pw;
        ReturnToMenu();
        trace("Joining: " + link);
        cast<CGameManiaPlanet>(GetApp()).ManiaPlanetScriptAPI.OpenLink(link, CGameManiaPlanetScriptAPI::ELinkType::ManialinkBrowser);
        
        @JoinTarget = null;
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