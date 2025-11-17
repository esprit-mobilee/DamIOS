import SwiftUI
import PhotosUI

struct PhotosPickerButton: View {
    @Binding var image: UIImage?
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker("Choisir un logo", selection: $pickerItem, matching: .images)
            .onChange(of: pickerItem) { _, newValue in
                guard let newValue else { return }
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self),
                       let ui = UIImage(data: data) {
                        await MainActor.run { image = ui }
                    }
                }
            }
    }
}
