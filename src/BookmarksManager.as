namespace BookmarksManager {
    Folder Root;
    
    void AddItem(IFolderItem@ item, Folder@ baseFolder = null) {
        if (GetContainingFolder(item) !is null) {
            warn("Attempted to add an item already in the tree");
            return;
        }

        if (baseFolder is null) {
            @baseFolder = Root;
        }

        baseFolder.Contents.InsertLast(item);
        
        SortTree();

        Save::UpdateSaveFile();
    }

    void MoveItem(IFolderItem@ &in item, Folder@ dest) {
        if (GetContainingFolder(item) is null) {
            warn("Attempted to move an item not in the tree");
            return;
        }
        
        bool moveIsValid = true;
        auto itemFolder = cast<Folder@>(item);
        if (itemFolder !is null) {
            if (itemFolder is dest) {
                moveIsValid = false;
            }

            auto children = GetAllFolders(itemFolder);
            foreach (auto folder : children) {
                if (folder.Contents.FindByRef(@dest) >= 0) {
                    moveIsValid = false; 
                }
            }
        }
        
        if (!moveIsValid) {
            return;
        }

        auto currentFolder = GetContainingFolder(item);
        currentFolder.Contents.RemoveAt(currentFolder.Contents.FindByRef(@item));
        dest.Contents.InsertLast(item);

        SortTree();

        Save::UpdateSaveFile();
    }
    
    void DeleteItem(IFolderItem@ &in item) {
        if (item is Root) { 
            warn("Attempted to remove tree root");
            return;
        }

        auto containingFolder = GetContainingFolder(item);
        if (containingFolder is null) {
            warn("Attempted to remove an item not in the tree");
            return;
        }

        containingFolder.Contents.RemoveAt(containingFolder.Contents.FindByRef(@item));
        
        Save::UpdateSaveFile();
    }

    Bookmark@[] GetAllBookmarks(Folder@ folder = null, Bookmark@[]@ buffer = null) {
        if (folder is null) {
            @folder = Root;
        }
        if (buffer is null) {
            @buffer = array<Bookmark@>();
        }

        foreach (auto item : folder.Contents) {
            auto itemBookmark = cast<Bookmark@>(item);
            auto itemFolder = cast<Folder@>(item);
            if (itemBookmark !is null) {
                buffer.InsertLast(itemBookmark);
            }
            else if (itemFolder !is null) {
                auto res = GetAllBookmarks(itemFolder);
                for (uint i = 0; i < res.Length; i++) {
                    buffer.InsertLast(res[i]);
                }
            }
        }
        
        return buffer;
    }
    
    void SortTree() {
        auto folders = GetAllFolders(Root);
        for (uint i = 0; i < folders.Length; i++) {
            Util::FolderQuickSort(folders[i].Contents, true);
        }
    }

    Folder@[] GetAllFolders(Folder@ folder = null, Folder@[]@ buffer = null) {
        if (folder is null) {
            @folder = Root;
        }
        if (buffer is null) {
            @buffer = array<Folder@>();
        }

        buffer.InsertLast(folder);
        foreach (auto item : folder.Contents) {
            auto itemFolder = cast<Folder@>(item);
            if (itemFolder !is null) {
                GetAllFolders(itemFolder, buffer);
            }
        }
        
        return buffer;
    }

    Folder@ GetContainingFolder(const IFolderItem@ bookmark) {
        foreach (auto folder : GetAllFolders()) {
            if (folder.Contents.FindByRef(@bookmark) >= 0) {
                return folder;
            }
        }
        
        return null;
    }
    
}