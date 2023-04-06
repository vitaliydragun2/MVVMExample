import SwiftUI

struct ViewSelector: View
{
    let configuration: Configuration
    
    init(_ configuration: Configuration)
    {
        self.configuration = configuration
    }
	
    var body: some View
    {
        switch configuration.selectedView
        {
        	case .LazyVStack:
            	MyStreamLazyVStack(configuration: configuration)
        	case .Grid:
            	MyStreamGrid(configuration: configuration)
        	case .UICollectionView:
            	MyStreamUICollectionView(configuration: configuration)
        }
    }
}

struct ViewSelector_Previews: PreviewProvider
{
    static var previews: some View
    {
        let configuration = Configuration()
        ViewSelector(configuration)
    }
}
