import XCTest
@testable import MVVMExample
import Combine

class PhotoInfoViewModelTests: XCTestCase
{
    var dataSource: DataSourceMockup!
    var viewModel: PhotoInfoViewModel!
    
    let expectedPhotoData = PhotoData(dataSourceType: .Flickr,
                                      name: "My Photo",
                                      path: "http:\\myphoto.jpg",
                                      photoID: "123456789",
                                      author: "Me",
                                      description: "Some landscape",
                                      date: "12.08.22",
                                      numberOfViews: "100",
                                      numberOfComments: "3")
    
    override func setUpWithError() throws
    {
        dataSource = DataSourceMockup()
        viewModel = PhotoInfoViewModel(photoData: PhotoData(),
                                       dataSource: dataSource)
    }

    func testPhotoDataLoadSuccessfully() throws
    {
        dataSource.expectedPhotoData = expectedPhotoData
        viewModel.loadPhotoData()
        XCTAssert(viewModel.photoData == expectedPhotoData &&
                  viewModel.isShowAlert == false)
    }
    
    func testPhotoDataLoadFailure() throws
    {
        dataSource.isSuccess = false
        viewModel.loadPhotoData()
        XCTAssert(viewModel.isShowAlert == true)
    }
    
    class DataSourceMockup: PhotoInfoDataSource
    {
        var expectedPhotoData: PhotoData!
        
        var isSuccess: Bool = true
        
        func fillInPhotoData(_ photoData: PhotoData) -> AnyPublisher<PhotoData, Error>
        {
            if isSuccess
            {
                return Just(expectedPhotoData)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
			else
            {
                return Fail(error: "Something wrong just happened")
                    .eraseToAnyPublisher()
            }
        }
    }
}
