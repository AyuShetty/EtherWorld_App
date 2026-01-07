import SwiftUI

struct SavedArticlesView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Saved Articles")
                    .font(.title)
                    .bold()
                    .padding()
                
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Saved Articles")
                        .font(.headline)
                    
                    Text("Save articles to read them offline")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationTitle("Saved")
        }
    }
}

#Preview {
    SavedArticlesView()
}
