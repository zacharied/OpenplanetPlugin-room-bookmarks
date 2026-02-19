funcdef void EditItemModalCallback(bool isEdit, Folder@ &in destinationFolder);

class EditItemModal : ModalDialog {
    EditItemModalCallback@ m_callback;
    
    bool m_isEdit;
    IFolderItem@ m_item;
    bool m_isBookmark;
    
    string m_textEntry;
    string m_roomClubIdEntry;
    string m_roomRoomIdEntry;
    Folder@ m_baseFolder = BookmarksManager::Root;

    EditItemModal(EditItemModalCallback@ callback, IFolderItem@ item, Folder@ containingFolder = null, bool isEdit = false)  {
        m_isEdit = isEdit;
        string title = isEdit ? "Edit" : "Create";
        if (cast<Bookmark@>(item) !is null)  {
            title += " bookmark";
            m_isBookmark = true;
        } else {
            title += " folder";
        }

        super(title);

        @m_callback = callback;
        @m_item = item;
        
        m_textEntry = item.Name;

        if (containingFolder is null) {
            @containingFolder = BookmarksManager::GetContainingFolder(item);
        }
        @m_baseFolder = containingFolder is null ? BookmarksManager::Root : containingFolder;

        if (m_isBookmark) {
            m_roomClubIdEntry = tostring(cast<Bookmark@>(item).ClubId);
            m_roomRoomIdEntry = tostring(cast<Bookmark@>(item).RoomId);
        }
    }
    
    void RenderDialog() override {
        m_textEntry = UI::InputText("Name##NameInput", m_textEntry);
        
        if (m_isBookmark) {
            UI::PushItemWidth(70);
            m_roomClubIdEntry = UI::InputText("Club ID##ClubIdEntry", m_roomClubIdEntry, UI::InputTextFlags::CharsDecimal);    
            UI::SameLine();
            m_roomRoomIdEntry = UI::InputText("Room ID##RoomIdEntry", m_roomRoomIdEntry, UI::InputTextFlags::CharsDecimal);
            UI::PopItemWidth();
        }
        
        if (UI::BeginCombo("Folder##BaseFolderCombo", m_baseFolder.Name)) {
            RenderFolderComboBox();     
            UI::EndCombo();
        }
        
        string confirmText = Icons::Check + " Confirm";
        string cancelText = Icons::Times + " Cancel";
        
        auto nextX = UI::GetContentRegionAvail().x - UI::MeasureButton(confirmText).x - UI::MeasureButton(cancelText).x - UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x * 1;

        UI::SetCursorPosX(nextX);

        UI::BeginDisabled(m_textEntry.Trim().Length == 0);
        if (UI::Button(cancelText)) {
            Close();
        }

        UI::SameLine();
        if (UI::GreenButton(confirmText)) {
            m_item.Name = m_textEntry;
            if (m_isBookmark) {
                cast<Bookmark@>(m_item).ClubId = Text::ParseInt(m_roomClubIdEntry);
                cast<Bookmark@>(m_item).RoomId = Text::ParseInt(m_roomRoomIdEntry);
            }
            if (m_callback !is null) {
                m_callback(m_isEdit, m_baseFolder);
            }
            Close();
        }
        UI::EndDisabled();
    }

    private void RenderFolderComboBox(Folder@ &in folder = null, uint indent = 0) {
        if (folder is null) {
            @folder = BookmarksManager::Root;
        }

        UI::PushID(folder);
        auto indentString = string::Repeat(" ", indent);
        if (UI::Selectable(indentString + folder.Name + "##SelectFolder", @m_baseFolder == @folder))  {
            @m_baseFolder = folder; 
        }

        foreach (auto item : folder.Contents) {
            auto itemFolder = cast<Folder@>(item);
            if (itemFolder is null) {
                continue;
            }

            RenderFolderComboBox(itemFolder, indent + 1);
        }
        UI::PopID();
    }
}