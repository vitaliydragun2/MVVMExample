import XCTest
@testable import MVVMExample
import Combine

class UnsplasPhotoInfoLoaderTest: NetworkTestCase
{
    var subscription: AnyCancellable!
    
    override func setUpWithError() throws
    {
        try super.setUpWithError()
        
        createMockResponseWithJsonFile("UnsplashPhotoInfoResponse")
    }

    func testJsonParsing() throws
    {
        let expectation = XCTestExpectation(description: "Response")
        let expectedPhotoData = PhotoData(dataSourceType: .Unsplash,
                                          photoID: "Dwu85P9SOIk",
                                          numberOfViews: "100")
        
        let photoInfoLoader = UnsplashAPI.PhotoInfoLoader(urlSession: urlSession)
        subscription = photoInfoLoader.fillInPhotoData(PhotoData(dataSourceType: .Unsplash, photoID:"Dwu85P9SOIk"))
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
