interface IFolderItem {
    string get_Name();
    void set_Name(const string &in val);
    
    Json::Value@ ToJson();
}