import Foundation

enum FileBrowser {
    static func contents(of directory: URL, includingHiddenFiles: Bool) throws -> [FileItem] {
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
        let options: FileManager.DirectoryEnumerationOptions = includingHiddenFiles ? [] : [.skipsHiddenFiles]
        return try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: options
        ).map { url in
            let values = try? url.resourceValues(forKeys: keys)
            return FileItem(
                url: url,
                name: url.lastPathComponent,
                isDirectory: values?.isDirectory ?? false,
                size: values?.fileSize.map(Int64.init),
                modificationDate: values?.contentModificationDate
            )
        }
    }
}
