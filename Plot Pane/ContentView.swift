import SwiftUI

struct ContentView: View {
    
    @Binding var data: [String]
    @Binding var active: Int
    
    var currentData: String? {
        return data.count != 0 ? data[active] : nil
    }
    
    var body: some View {
        Base64View(data: currentData)
    }
}
