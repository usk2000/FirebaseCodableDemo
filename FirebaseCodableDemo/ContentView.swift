//
//  ContentView.swift
//  FirebaseCodableDemo
//
//  Created by Yusuke Hasegawa on 2021/06/24.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        
        NavigationView {
            
            List {
                ForEach.init(self.viewModel.samples, id: \.id) { sample in
                    VStack(alignment: .leading) {
                        Text(sample.title)
                            .font(.body)
                        Text(sample.date.description)
                            .font(.caption)
                    }
                }
                
            }.onAppear {
                
                viewModel.fetchSingleDocument()
                viewModel.fetchSamples()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.viewModel.observeDocuments()
                }
                
            }
            .navigationBarTitle("Sample Documents")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button.init(action: { self.viewModel.addDocument() }, label: {
                Image(systemName: "plus")
            }))
            
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
