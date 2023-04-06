import XCTest
@testable import MVVMExample
import Combine

class FlickrUserPhotosLoaderTests: NetworkTestCase
{
    var subscription: AnyCancellable!
    
    override func setUpWithError() throws
    {
    	try super.setUpWithError()
        
        createMockResponseWithJsonFile("FlickrUserPhotosResponse")
    }

    func testJsonParsing() throws
    {
        let expectation = XCTestExpectation(description: "Response")
        let expectedPhotoData = PhotoData(dataSourceType: .Flickr,
                                          name: "DSC08178",
                                          path: "https://live.staticflickr.com/65535/52290008911_cbf929ddd4.jpg",
                                          photoID: "52290008911")
        
        let userPhotoLoader = FlickrAPI.UserPhotosLoader(urlSession: urlSession)
        subscription = userPhotoLoader.loadPhotos()
            .sink ( receiveCompletion:
            {completion in
                if case .failure(let error) = completion
                {
                    XCTFail(error.localizedDescription)
                }
            },
            receiveValue:
            { photoDatas in
                guard photoDatas.first == expectedPhotoData
                else
                {
                    XCTFail("JSON parsing problem")
                    return
                }
                expectation.fulfill()
            })
        wait(for: [expectation], timeout: 1)
    }
}
