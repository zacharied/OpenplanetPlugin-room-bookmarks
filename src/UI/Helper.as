namespace UI {
    void InputTextFormatCodesCallback(UI::InputTextCallbackData@ data) {
        if (data.EventChar == 0x5c) {
            data.EventChar = 0;
        }
    }

    void InputNumberCharFilterCallback(UI::InputTextCallbackData@ data) {
        if (data.EventChar < 0x30 || data.EventChar > 0x39) {
            data.EventChar = 0;
        }
    }

    vec2 MeasureButton(const string &in label) {
        vec2 text = UI::MeasureString(label);
        vec2 padding = UI::GetStyleVarVec2(UI::StyleVar::FramePadding);

        return text + padding * 2;
    }

    bool RedButton(const string &in text) { return ButtonColored(text, 0.0f); }
    bool GreenButton(const string &in text) { return ButtonColored(text, 0.33f); }
    bool OrangeButton(const string &in text) { return ButtonColored(text, 0.1f); }
    bool CyanButton(const string &in text) { return ButtonColored(text, 0.5f); }
    bool PurpleButton(const string &in text) { return ButtonColored(text, 0.8f); }
    bool RoseButton(const string &in text) { return ButtonColored(text, 0.9f); }
    bool YellowButton(const string &in text) { return ButtonColored(text, 0.2f); }
    bool GoldButton(const string &in text) { return ButtonColored(text, 0.12f, 1.f, 0.7f); }
    bool GreyButton(const string &in text) { return ButtonColored(text, 0.0f, 0.0f, 0.4f); }
}