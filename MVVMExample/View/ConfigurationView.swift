import SwiftUI

struct ConfigurationView: View
{
    @ObservedObject var configuration = Configuration()
    
    init()
    {
        UISegmentedControl.appearance().selectedSegmentTintColor = .red
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
    }
    
	var body: some View
	{
		NavigationView
		{
			VStack
			{
				Spacer()
					.frame(height: 10)
				Text("To proove that view and model are comletely independent from each other I have added the ability to switch them on the go.")
					.font(.system(size: 22).italic())
					.padding(.all, 12.0)
					.foregroundColor(.white)
					.background(.blue)
					.border(.red, width: 4)
					.cornerRadius(5)
				Spacer()
					.frame(height: 35)
				Divider()
					.frame(height: 1)
					.overlay(.blue)
				Text("Select Model")
					.foregroundColor(.blue)
				Picker("Select Model", selection: $configuration.selectedDataSourceType)
				{
					Text("Flickr").tag(Configuration.DataSourceType.Flickr)
						.foregroundColor(.white)
					Text("Unsplash").tag(Configuration.DataSourceType.Unsplash)
						.foregroundColor(.white)
				}
				.pickerStyle(.segmented)
				.accessibilityIdentifier("Select Model Picker")
				Text("Select View")
					.foregroundColor(.blue)
				Picker("Select View", selection: $configuration.selectedView)
				{
					Text("Grid")
					.tag(Configuration.SelectedView.Grid)
					Text("LazyVStack")
					.tag(Configuration.SelectedView.LazyVStack)
					Text("UICollectionView")
					.tag(Configuration.SelectedView.UICollectionView)
				}
				.pickerStyle(.segmented)
				.accessibilityIdentifier("Select View Picker")
				Spacer()
				NavigationLink
				{
					LazyView(ViewSelector(configuration))
				}
				label:
				{
					Text("Launch")
						.font(.system(size: 18))
						.padding()
						.foregroundColor(.white)
						.background(.red)
						.clipShape(Capsule())
				}
			}
			.padding()
			.navigationTitle("Configuration")
			.navigationBarTitleDisplayMode(.large)
			.navigationBarColor(.systemBlue)
			.environmentObject(configuration)
			.background(.white)
		}
		.navigationBarTitleDisplayMode(.large)
		.navigationViewStyle(.stack)
		.preferredColorScheme(.dark)
	}
}

struct Preferences_Previews: PreviewProvider
{
    static var previews: some View
    {
        ConfigurationView()
    }
}
