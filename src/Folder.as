class Folder: IFolderItem {
    array<IFolderItem@> Contents;
    
    private string m_name;
    
    string get_Name() override {
        return m_name;
    }
    
    void set_Name(const string &in val) override {
        m_name = val;
    }
    
    Json::Value@ ToJson() override {
        auto json = Json::Object();
        json["type"] = "folder";

        json["name"] = Name;  
        
        auto contents = Json::Array();
        foreach (auto item : Contents) {
            contents.Add(item.ToJson());
        }
        
        json["contents"] = contents;
        
        return json;
    }
}