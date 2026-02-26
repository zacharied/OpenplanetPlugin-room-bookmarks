class RouterPushHook : MLHook::HookMLEventsByType {
    RouterPushHook() {
        super("Router_Push");
    }
    
    void OnEvent(MLHook::PendingEvent@ event) override {
        if (event.data.Length < 2) {
            return;
        }

        if (event.data[0] != "/live/arcade/roommaplistdisplay") {
            return;
        }
        
        try {
            auto args = Json::Parse(event.data[1]);
            auto room = Json::Parse(args["Room"]);
            RouterWatch::ClubId = int(room["ClubId"]);
            RouterWatch::RoomId = int(room["Id"]);
            RouterWatch::RoomName = string(room["Name"]);
            trace("[RoomBookmarks RouterPushHook] RouterWatch IDs updated for room \"" + Text::StripFormatCodes(RouterWatch::RoomName) + "\"");
        } catch {
            warn("[RoomBookmarks RouterPushHook] Failed to parse roommaplistdisplay data");
        }
    }
}

class RouterPushParentHook : MLHook::HookMLEventsByType {
    RouterPushParentHook() {
        super("Router_PushParent");
    }
    
    void OnEvent(MLHook::PendingEvent@ event) override {
        if (event.data.Length != 1 || event.data[0] != "/live/arcade/roommaplistdisplay") {
            return;
        }

        RouterWatch::ClubId = -1;
        RouterWatch::RoomId = -1;
        RouterWatch::RoomName = "";
        
        trace("[RoomBookmarks RouterPushParentHook] RouterWatch IDs reset");
    }
}

namespace RouterWatch {
    int ClubId = -1;
    int RoomId = -1;
    string RoomName = "";
}