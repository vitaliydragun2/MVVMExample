import Foundation

struct PhotoData: Equatable
{
    static func == (lhs: PhotoData, rhs: PhotoData) -> Bool
    {
        guard lhs.dataSourceType == rhs.dataSourceType,
              lhs.name == rhs.name,
              lhs.path == rhs.path,
              lhs.photoID == rhs.photoID,
              lhs.description == rhs.description,
              lhs.date == rhs.date,
              lhs.numberOfViews == rhs.numberOfViews,
              lhs.numberOfComments == rhs.numberOfComments
        else
        {
            return false
        }
        return true
    }
    
    var dataSourceType: Configuration.DataSourceType = .Flickr
    var name: String = ""
    var path: String = ""
    var photoID: String = ""
    var author: String = ""
    var description: String = ""
    var date: String = ""
    var numberOfViews: String = ""
    var numberOfComments: String = ""
}
