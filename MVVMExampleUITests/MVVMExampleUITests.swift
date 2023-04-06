import XCTest

final class MVVMExampleUITests: XCTestCase
{
	let app = XCUIApplication()
	
	override func setUpWithError() throws
	{
		continueAfterFailure = false
	
		app.launch()
	}
	
	//Switch off internet to produce an error and then after alert appears switch internet back on
	func testLoadingFailureAndThenSuccess()
	{
		app.buttons["Launch"].tap()
		while app.activityIndicators["ProgressView"].exists
		{
			sleep(1)
		}
		if app.alerts.element.waitForExistence(timeout: 1)
		{
			sleep(10)
			app.alerts.element.buttons["OK"].tap()
			app.buttons["Reload"].tap()
		}
		XCTAssertTrue(app.otherElements["LazyVStack"].waitForExistence(timeout: 3))
	}
	
	func testModelViewSwitch() throws
	{
		app.buttons["Launch"].tap()
		XCTAssertTrue(app.otherElements["LazyVStack"].firstMatch.waitForExistence(timeout: 5))
		app.buttons["Configuration"].tap()
	
		app.segmentedControls["Select View Picker"].buttons["Grid"].tap()
		app.buttons["Launch"].tap()
		XCTAssertTrue(app.otherElements["Grid"].waitForExistence(timeout: 5))
		app.buttons["Configuration"].tap()
	
		app.segmentedControls["Select View Picker"].buttons["UICollectionView"].tap()
		app.buttons["Launch"].tap()
		XCTAssertTrue(app.collectionViews["UICollectionView"].waitForExistence(timeout: 5))
		app.buttons["Configuration"].tap()
	
		app.segmentedControls["Select Model Picker"].buttons["Unsplash"].tap()
		app.segmentedControls["Select View Picker"].buttons["LazyVStack"].tap()
		app.buttons["Launch"].tap()
		XCTAssertTrue(app.otherElements["LazyVStack"].waitForExistence(timeout: 5))
	}
}
