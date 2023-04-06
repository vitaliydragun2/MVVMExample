import XCTest
@testable import MVVMExample
import Combine

class MyStreamViewModelTests: XCTestCase
{
    var expectedPhotoDatas: [PhotoData]!
    var dataSource: DataSourceMockup!
    var viewModel: MyStreamViewModel!
    
    override func setUpWithError() throws
    {
		let expectedPhotoData1 = PhotoData(name: "Photo1",
										   path: "http:\\myphoto1.jpg",
										   photoID: "123456789")
		let expectedPhotoData2 = PhotoData(name: "Photo2",
										   path: "http:\\myphoto2.jpg",
										   photoID: "1234567890")
        expectedPhotoDatas = [expectedPhotoData1, expectedPhotoData2]
        dataSource = DataSourceMockup()
        viewModel = MyStreamViewModel(dataSource: dataSource)
    }

    func testReloadPhotosSuccessFully()
    {
        dataSource.photoDatas = expectedPhotoDatas
        dataSource.isSuccessFul = true
        
        viewModel.loadPhotos()
        
        XCTAssert(viewModel.photoDatas == expectedPhotoDatas &&
                  viewModel.status == .success)
    }
    
    func testReloadPhotosWithFailure()
    {
        dataSource.isSuccessFul = false
        
        viewModel.loadPhotos()
        
        XCTAssert(viewModel.status == .failure &&
                  viewModel.isShowAlert == true)
    }
    
    func testLoadMorePhotosSuccessfully()
    {
        dataSource.photoDatas = expectedPhotoDatas
        
        let morePhotoData = PhotoData(name: "Photo3",
                                      path: "http:\\myphoto3.jpg",
                                      photoID: "12345678900")
        
        dataSource.photoDatas.append(morePhotoData)
        expectedPhotoDatas.append(morePhotoData)
        
        viewModel.loadMorePhotos()
        
        XCTAssert(viewModel.photoDatas == expectedPhotoDatas &&
                  viewModel.status == .success)
    }
    
    class DataSourceMockup: PhotosDataSource
    {
        var photoDatas: [PhotoData]!
        var isSuccessFul: Bool!
        
        func loadPhotos() -> AnyPublisher<[PhotoData], Error>
        {
            if isSuccessFul
            {
                return Just(photoDatas)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            else
            {
                return Fail(error: "Loading has failed")
                    .eraseToAnyPublisher()
            }
        }
        
        func loadMorePhotos() -> AnyPublisher<[PhotoData], Error>
        {
            return Just(photoDatas)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
