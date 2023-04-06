import Foundation
import SwiftUI

struct AsyncImageHelperView: View
{
    private let phase: AsyncImagePhase
    
    init(_ phase: AsyncImagePhase)
    {
        self.phase = phase
    }
    
    var body: some View
    {
        if let image = phase.image
        {
            image.resizable()
        }
        else if phase.error != nil
        {
            Text(phase.error!.localizedDescription)
        }
        else
        {
            ProgressView()
			.tint(.black)
        }
    }
}
