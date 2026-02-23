namespace MainWindow {
    IFolderItem@ EditCommandTarget;
    IFolderItem@ DeleteCommandTarget;

    void Render() {
        if (UI::Begin("Room Bookmarks", g_showMainMenu)) {
            UI::PushStyleColor(UI::Col::Border, UI::GetStyleColor(UI::Col::FrameBgHovered));
            if (UI::BeginChild("##TreeChild", vec2(), UI::ChildFlags::Borders)) {
                RenderFolderTree(BookmarksManager::Root, true);
            }
            UI::EndChild();
            UI::PopStyleColor();
        }
        UI::End();
    }
    
    void OnEditConfirmed(bool isEdit, Folder@ &in baseFolder) {
        if (isEdit) {
            BookmarksManager::MoveItem(EditCommandTarget, baseFolder);
        } else {
            BookmarksManager::AddItem(EditCommandTarget);
        }
    }
    
    void OnConfirmDelete() {
        BookmarksManager::DeleteItem(DeleteCommandTarget);
    }

    void RenderFolderTree(Folder@ &in folder, bool isRoot = false) {
        UI::PushID(folder);
        auto extraFlags = isRoot ? UI::TreeNodeFlags::DefaultOpen : 0;
        auto isTreeOpen = UI::TreeNode(folder.Name + "##FolderName", UI::TreeNodeFlags::Framed | UI::TreeNodeFlags::AllowOverlap | UI::TreeNodeFlags::OpenOnDoubleClick | UI::TreeNodeFlags::OpenOnArrow | extraFlags);
        
        if (!isRoot) {
            auto spacing = UI::GetContentRegionMax().x - UI::MeasureButton(Icons::Circle).x * 3;
            UI::SameLine(spacing);

            if (UI::Button(Icons::Trash + "##DeleteFolderButton")) {            
                @DeleteCommandTarget = folder;
                auto modal = DeletePromptModal(OnConfirmDelete, "Delete folder", "Delete the folder \"\\$<" + folder.Name + "\\$>\" and all its contents?");
                Renderables::Add(modal);
            }
            
            UI::SameLine(0, 0);

            if (UI::Button(Icons::Pencil + "##EditFolderButton")) {
                @EditCommandTarget = folder;
                auto modal = EditItemModal(OnEditConfirmed, folder, null, true);
                Renderables::Add(modal);
            }

            UI::SameLine(0, 0);
        } else {
            auto spacing = UI::GetContentRegionMax().x - UI::MeasureButton(Icons::Circle).x * 1;
            UI::SameLine(spacing);
        }

        if (UI::Button(Icons::Plus + "##AddFolderButton")) {
            auto newFolder = Folder();
            @EditCommandTarget = newFolder;
            auto modal = EditItemModal(OnEditConfirmed, newFolder, folder);
            Renderables::Add(modal);
        }

        if (isTreeOpen) {
            for (uint j = 0; j < folder.Contents.Length; j++) {
                auto item = folder.Contents[j]; 
                auto itemBookmark = cast<Bookmark>(item);
                auto itemFolder = cast<Folder>(item);
                if (itemBookmark !is null) {
                    RenderBookmarkTree(itemBookmark);
                } else if (itemFolder !is null) {
                    RenderFolderTree(itemFolder);
                }
            }
            
            UI::TreePop();
        }
        
        UI::PopID();
    }
    
    void RenderBookmarkTree(Bookmark@ &in bookmark) {
        UI::PushID(bookmark);
        UI::Text(bookmark.Name);

        auto spacing = UI::GetContentRegionMax().x - UI::MeasureButton(Icons::Circle).x * 3;
        
        UI::SameLine(spacing, 0);
        if (UI::Button(Icons::Trash + "##DeleteBookmark")) {
            @DeleteCommandTarget = bookmark;
            auto modal = DeletePromptModal(OnConfirmDelete, "Delete bookmark", "Delete bookmark \\$<\"" + bookmark.Name + "\\$>\"?");
            Renderables::Add(modal);
        }

        UI::SameLine(0, 0);
        if (UI::Button(Icons::Pencil + "##EditBookmark")) {
            @EditCommandTarget = bookmark;
            auto modal = EditItemModal(OnEditConfirmed, bookmark, null, true);
            Renderables::Add(modal);
        }
        UI::SetItemTooltip("Edit this bookmark");
        
        UI::SameLine(0, 0);
        if (UI::GreenButton(Icons::Play + "##JoinServer")) {
            @Game::JoinTarget = bookmark;
            startnew(Game::TryJoinServer);
        }
        UI::SetItemTooltip("Join server");
        
        UI::PopID();
    }
}