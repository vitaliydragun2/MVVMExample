import Foundation

class Configuration: ObservableObject
{
    @Published var selectedDataSourceType: DataSourceType = .Flickr
    @Published var selectedView: SelectedView = .LazyVStack
    
    enum DataSourceType: String
    {
    	case Flickr = "Flickr"
        case Unsplash = "Unsplash"
    }
    
    enum SelectedView: String
    {
    	case Grid = "Grid"
        case LazyVStack = "LazyVStack"
        case UICollectionView = "UICollectionView"
    }
}
