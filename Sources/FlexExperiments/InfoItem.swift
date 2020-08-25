import Foundation
import Path

public struct InfoItem {
    public var title: String
    public var description: String
    public var images: [Image]

    public init(from directory: Path) {
        let jsonInfo = try! String(contentsOf: Path(directory)/"data.json")
        
        let info = try! JSONSerialization.jsonObject(with: jsonInfo.data(using: .utf8)!) as! [String: Any]
        
        self.title = info["title"] as! String
        
        self.description = info["description"] as! String

        let imageNames = info["images"] as! [String]

        self.images = imageNames.map {
            try! Image(contentsOf: URL(string: (Path(directory)/$0).string)!)
        }
    }
}