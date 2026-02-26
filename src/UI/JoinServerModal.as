funcdef void OnCloseCallback();

class JoinServerModal : ModalDialog {
    Bookmark@ JoinTarget;
    OnCloseCallback@ CloseCallback;

    bool JoinCompleted = false;
    bool JoinFailed = false;

    bool RetryRequested = false;

    JoinServerModal(Bookmark@ bookmark, OnCloseCallback@ closeCallback) {
        super("Joining server");
        
        @JoinTarget = bookmark;
        @CloseCallback = closeCallback;
        
        this.m_flags = this.m_flags | UI::WindowFlags::NoTitleBar;
    }
    
    void RenderDialog() override {
        if (JoinCompleted) {
            Close();
            return;
        }

        UI::Text("Joining bookmark \"\\$<" + JoinTarget.Name + "\\$>\".\nThis may take a while if the server needs to start up.");
        
        if (JoinFailed) {
            UI::PushStyleColor(UI::Col::Text, vec4(1, .2f, .2f, 1));
            UI::Text("Failed to join.");
            UI::PopStyleColor();
        } else {
            UI::Text("");
        }
        
        UI::BeginDisabled(!JoinFailed);
        if (UI::Button(Icons::Refresh + " Retry")) {
            RetryRequested = true;            
        }
        UI::EndDisabled();

        UI::SameLine();

        if (UI::RedButton(Icons::Times + " Cancel")) {
            Close();
        }
    }
    
    void Close() override {
        ModalDialog::Close();
        CloseCallback(); 
    }
}