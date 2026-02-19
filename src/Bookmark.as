class Bookmark: IFolderItem {
    private string m_bookmarkName;
    int ClubId;
    int RoomId;
    
    string get_Name() override {
        return m_bookmarkName; 
    }
    
    void set_Name(const string &in val) override {
        m_bookmarkName = val; 
    }
    
    Json::Value@ ToJson() override {
        auto json = Json::Object();
        json["type"] = "bookmark";
        json["name"] = Name;  
        json["clubId"] = ClubId;
        json["roomId"] = RoomId;
        return json;
    }
}