import XCTest
@testable import MVVMExample
import Combine

class FlickrPhotoInfoLoaderTests: NetworkTestCase
{
    var subscription: AnyCancellable!
    
    override func setUpWithError() throws
    {
        try super.setUpWithError()
        
        createMockResponseWithJsonFile("FlickrPhotoInfoResponse")
    }
    
    func testJsonParsing() throws
    {
        let expectation = XCTestExpectation(description: "Response")
        let expectedPhotoData = PhotoData(dataSourceType: .Flickr,
                                          name: "DSC08178",
                                          path: "https://live.staticflickr.com/65535/52290008911_cbf929ddd4.jpg",
                                          photoID: "52290008911",
                                          author: "Vitaliy Dragun",
                                          date: "2022-07-16 18:59:01",
                                          numberOfViews: "403",
                                          numberOfComments: "2")
        
        let photoInfoLoader = FlickrAPI.PhotoInfoLoader(urlSession: urlSession)
        subscription = photoInfoLoader.fillInPhotoData(expectedPhotoData)
            .sink ( receiveCompletion:
            {completion in
                if case .failure(let error) = completion
                {
                    XCTFail(error.localizedDescription)
                }
            },
            receiveValue:
            { photoData in
                guard photoData == expectedPhotoData
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
