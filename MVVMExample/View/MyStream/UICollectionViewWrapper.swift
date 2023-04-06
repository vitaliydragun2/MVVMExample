import SwiftUI

struct UICollectionViewWrapper <Cell: View>: UIViewRepresentable
{
    @EnvironmentObject var preferences: Configuration
    @EnvironmentObject var myStreamViewModel: MyStreamViewModel
    
    var cell: (PhotoData) -> Cell
    
    init(@ViewBuilder cell: @escaping (PhotoData) -> Cell)
    {
        self.cell = cell
    }

    func makeCoordinator() -> Coordinator
    {
        let coordinator = Coordinator(cell: cell)
		coordinator.viewModel = myStreamViewModel
		return coordinator
    }
    
    func makeUIView(context: Context) -> some UIView
    {
        let screenSize: CGRect! = UIScreen.main.bounds
        let screenWidth: CGFloat! = screenSize.width
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/4)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        
       	let collectionView = UICollectionView(frame: .null, collectionViewLayout: layout)
        collectionView.register(HostCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = context.coordinator
        collectionView.accessibilityIdentifier = "UICollectionView"
		collectionView.backgroundColor = .clear
        return collectionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context)
    {
		guard let collectionView = uiView as? UICollectionView else { return }
		
		let viewModel: MyStreamViewModel = context.coordinator.viewModel
		let allItems = viewModel.photoDatas
		
		//Workaround of the bug described here
		//https://stackoverflow.com/questions/19199985/invalid-update-invalid-number-of-items-on-uicollectionview
		if allItems.count == viewModel.numberOfNewlyLoadedPhotos
		{
			collectionView.reloadData()
		}
		else
		{
			var indexPathsToInsert = [IndexPath]()
			let itemsToInsert = allItems.suffix(viewModel.numberOfNewlyLoadedPhotos)
			for element in itemsToInsert
			{
				if let index = allItems.firstIndex(of: element)
				{
					let indexPath = IndexPath(item: index, section: 0)
					indexPathsToInsert.append(indexPath)
				}
			}
			collectionView.insertItems(at: indexPathsToInsert)
			
			//Get rid of activity indicator
			var indexOfItemWithActivityIndicator: Int
			if let firstInsertedItem = itemsToInsert.first
			{
				indexOfItemWithActivityIndicator = allItems.firstIndex(of: firstInsertedItem)! - 1
			}
			else
			{
				indexOfItemWithActivityIndicator = allItems.count - 1
			}
			if indexOfItemWithActivityIndicator >= 0
			{
				let indexPathToUpdate = IndexPath(item: indexOfItemWithActivityIndicator, section: 0)
				collectionView.reloadItems(at: [indexPathToUpdate])
			}
		}
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource
    {
        init(@ViewBuilder cell: @escaping (PhotoData) -> Cell)
        {
            self.cell = cell
        }
        
        weak var viewModel: MyStreamViewModel!
        
        var cell: (PhotoData) -> Cell
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        {
            return viewModel.photoDatas.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HostCell
            cell.hostedCell = self.cell(viewModel.photoDatas[indexPath.row])
			cell.backgroundColor = .clear

            return cell
        }
    }
    
    private class HostCell: UICollectionViewCell
    {
        private var hostingController: UIHostingController<Cell>?
        
        override func prepareForReuse()
        {
            if let hostView = hostingController?.view
            {
                hostView.removeFromSuperview()
            }
            hostingController = nil
        }
        
        var hostedCell: Cell?
        {
            willSet
            {
                guard let view = newValue else {return}
                hostingController = UIHostingController(rootView: view)
                if let hostView = hostingController?.view
                {
                    hostView.frame = contentView.bounds
					hostView.backgroundColor = .clear
                    hostView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    contentView.addSubview(hostView)
                }
            }
        }
    }
}

struct CollectionView_Previews: PreviewProvider
{
    static var previews: some View
    {
        let configuraion = Configuration()
        UICollectionViewWrapper
        { photoData in
            NavigationLink(destination: LazyView(PhotoDetailsView(photoData: photoData)))
            {
                AsyncImage(url: URL(string: photoData.path),
                           scale: 1.0,
                           transaction: Transaction(),
                           content:
                { phase in
                    AsyncImageHelperView(phase)
                })
                .scaledToFit()
            }
        }
        .environmentObject(MyStreamViewModel(configuration: configuraion))
        .environmentObject(configuraion)
    }
}
