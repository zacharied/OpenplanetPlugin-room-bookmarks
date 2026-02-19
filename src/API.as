namespace API {
    Json::Value@ GetJoinLink(uint clubId, uint roomId) {
        auto resp = APIHelpers::PostLiveApiPath("/api/token/club/" + clubId + "/room/" + roomId + "/join", Json::Object());
        if (resp !is null && resp.GetType() == Json::Type::Array) {
            if (resp.Length > 0 && string(resp[0]) == "roomServer:error-NoServerAvailable") {
                throw("Getting join link: roomServer:error-NoServerAvailable -- The room is probably deactivated");
            }
        }
        return resp;
    }
    
    Json::Value@ GetClubActivities(uint clubId, bool active, uint length = 100, uint offset = 0) {
        return APIHelpers::CallLiveApiPath("/api/token/club/" + clubId + "/activity?active=" + tostring(active) + "&" + APIHelpers::LengthAndOffset(length, offset));
    }
}

namespace APIHelpers {
    Json::Value@ CallLiveApiPath(const string &in path) {
        return FetchLiveEndpoint(NadeoServices::BaseURLLive() + path);
    }

    Json::Value@ PostLiveApiPath(const string &in path, Json::Value@ data) {
        return PostLiveEndpoint(NadeoServices::BaseURLLive() + path, data);
    }

    Json::Value@ FetchLiveEndpoint(const string &in route) {
        trace("[FetchLiveEndpoint] Requesting: " + route);
        auto req = NadeoServices::Get("NadeoLiveServices", route);
        req.Start();
        while(!req.Finished()) { yield(); }
        return req.Json();
    }

    Json::Value@ PostLiveEndpoint(const string &in route, Json::Value@ data) {
        trace("[FetchLiveEndpoint] Requesting: " + route);
        auto req = NadeoServices::Post("NadeoLiveServices", route, Json::Write(data));
        req.Start();
        while(!req.Finished()) { yield(); }
        return req.Json();
    }

    // Length and offset get params helper
    const string LengthAndOffset(uint length, uint offset) {
        return "length=" + length + "&offset=" + offset;
    }
}