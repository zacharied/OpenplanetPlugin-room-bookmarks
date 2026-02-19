namespace Util {
    // Original code from Better TOTD by Xertrov
    void FolderQuickSort(IFolderItem@[]@ folder, bool descending, int left = 0, int right = -1) {
        if (right < 0) right = folder.Length - 1;
        if (folder.Length == 0) return;

        int i = left;
        int j = right;
        IFolderItem@ pivot = folder[(left + right) / 2];

        while (i <= j) {
            if (descending) {
                while (CompareFolderItems(folder[i], pivot) > 0) i++;
                while (CompareFolderItems(folder[j], pivot) < 0) j--;
            } else {
                while (CompareFolderItems(folder[j], pivot) > 0) j--;
                while (CompareFolderItems(folder[i], pivot) < 0) i++;
            }

            if (i <= j) {
                IFolderItem@ temp = folder[i];
                @folder[i] = folder[j];
                @folder[j] = temp;
                i++;
                j--;
            }
        }

        if (left < j) FolderQuickSort(folder, descending, left, j);
        if (i < right) FolderQuickSort(folder, descending, i, right);
    }

    int CompareFolderItems(IFolderItem@ a, IFolderItem@ b) {
        auto itemBookmarkA = cast<Bookmark@>(a);
        auto itemFolderA = cast<Folder@>(a);
        auto itemBookmarkB = cast<Bookmark@>(b);
        auto itemFolderB = cast<Folder@>(b);
        if (itemBookmarkA !is null) {
            if (itemBookmarkB !is null) {
                if (itemBookmarkA.Name.ToLower() < itemBookmarkB.Name.ToLower()) return 1;
                if (itemBookmarkA.Name.ToLower() > itemBookmarkB.Name.ToLower()) return -1;
            } else {
                return -1;                
            }
        } else if (itemFolderA !is null) {
            if (itemFolderB !is null) {
                if (itemFolderA.Name.ToLower() < itemFolderB.Name.ToLower()) return 1;
                if (itemFolderA.Name.ToLower() > itemFolderB.Name.ToLower()) return -1;
            } else {
                return 1;                
            }
        }
        return 0;
    }
}