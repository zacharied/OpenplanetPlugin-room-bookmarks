funcdef void DeletePromptModalCallback();

class DeletePromptModal : ModalDialog {
    DeletePromptModalCallback@ m_callback;
    
    string m_prompt;
    
    DeletePromptModal(DeletePromptModalCallback@ callback, const string &in title, const string &in prompt) {
        super(title);

        @m_callback = callback;
        m_prompt = prompt;
    }

    void RenderDialog() override {
        UI::AlignTextToFramePadding();
        UI::Text(m_prompt);

        auto confirmText = "Delete";
        auto cancelText = "Cancel";
        auto spacing = UI::GetContentRegionAvail().x - UI::MeasureButton(confirmText).x - UI::MeasureButton(cancelText).x - UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x * 1;
        UI::SetCursorPosX(spacing);
        
        if (UI::Button(cancelText + "##CancelButton")) {
            Close();
        }

        UI::SameLine();

        if (UI::RedButton(confirmText + "##ConfirmButton")) {
            m_callback();
            Close();
        };
    }
}