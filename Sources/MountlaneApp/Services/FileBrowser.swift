import Foundation

enum FileBrowser {
    static func contents(of directory: URL) throws -> [FileItem] {
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
        return try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        ).map { url in
            let values = try? url.resourceValues(forKeys: keys)
            return FileItem(
                url: url,
                name: url.lastPathComponent,
                isDirectory: values?.isDirectory ?? false,
                size: values?.fileSize.map(Int64.init),
                modificationDate: values?.contentModificationDate
            )
        }.sorted {
            if $0.isDirectory != $1.isDirectory { return $0.isDirectory }
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
}
