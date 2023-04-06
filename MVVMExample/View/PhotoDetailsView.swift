import SwiftUI

struct PhotoDetailsView: View
{
    @ObservedObject var photoInfoViewModel: PhotoInfoViewModel
    
    init(photoData: PhotoData)
    {
        photoInfoViewModel = PhotoInfoViewModel(photoData: photoData)
    }
    
    var body: some View
    {
        ScrollView
        {
            VStack
            {
                Text(photoInfoViewModel.photoData.name)
                    .font(.largeTitle)
                    .padding(.top)
                HStack
                {
					AsyncImageWithCache(url: URL(string: photoInfoViewModel.photoData.path)!)
						.scaledToFit()
						.padding(20)
						.border(.white, width: 20.0)
                }
                .padding()
                HStack
                {
                    Image("eye")
                        .resizable()
                        .frame(width: 20.0, height: 20.0, alignment: .center)
                        .scaledToFit()
                    Text(photoInfoViewModel.photoData.numberOfViews)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .accessibilityIdentifier(/*@START_MENU_TOKEN@*/"Identifier"/*@END_MENU_TOKEN@*/)
                Text("Comments: \(photoInfoViewModel.photoData.numberOfComments)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .bottom])
                HStack(spacing: 10)
                {
                    Text("Author:")
                        .underline()
                    Text(photoInfoViewModel.photoData.author)
                    Spacer()
                }
                .padding(.leading)
                Text("Description:")
                    .underline()
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth:.infinity, alignment: .leading)
                    .padding(.leading)
                Text(photoInfoViewModel.photoData.description)
                    .padding([.leading, .trailing])
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack
                {
                    Text("Date Taken:")
                        .underline()
                        .padding(.leading)
                    Text(photoInfoViewModel.photoData.date)
                    Spacer()
                }
            }
        }
        .navigationTitle("Photo Info")
        .alert(photoInfoViewModel.alertMessage, isPresented: $photoInfoViewModel.isShowAlert)
        {
            Button("OK", role: .cancel) { }
        }
        .navigationBarColor(.systemBlue)
        .background(RadialGradient(colors: [.blue, .white],
								   center: .bottom,
								   startRadius: 0,
								   endRadius: 800))
		.foregroundColor(.black)
    }
}

struct PhotoInfoView_Previews: PreviewProvider
{
    static var previews: some View
    {
        let photoData = PhotoData(dataSourceType: .Flickr,
                                  name: "DSC09894",
                                  path: "https://live.staticflickr.com/65535/52259153955_5dc763a0ac.jpg",
                                  photoID: "52259153955",
                                  author: "Vitaliy Dragun",
                                  description: "Somewhere in the Carpathian mountains",
                                  date: "2022.03.07",
                                  numberOfViews: "100",
                                  numberOfComments: "2")
        PhotoDetailsView(photoData: photoData)
    }
}
