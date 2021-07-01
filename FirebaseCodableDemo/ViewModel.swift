//
//  ViewModel.swift
//  FirebaseCodableDemo
//
//  Created by Yusuke Hasegawa on 2021/06/24.
//

import Foundation
import FirebaseFirestore
import FirebaseCodable

class ViewModel: ObservableObject {    
    
    @Published var samples: [SampleModel] = []
    
    private var firestore: Firestore = .firestore()
    
    private var decoder: FCDefaultDecoder = {
        let jsonDecoder = FCDefaultDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        return jsonDecoder
    }()
    private var encoder: FCDefaultEncoder = {
        let jsonEncoder = FCDefaultEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        return jsonEncoder
    }()
    
    private var lastSnapshot: DocumentSnapshot?
    private var listener: ListenerRegistration?
    
}

extension ViewModel {
    
    func fetchSamples() {
        
        let query = firestore.collection("samples")
            .order(by: "date", descending: true)
            .limit(to: 10)
        
        query.getDocumentResponseAs(SampleModel.self, source: .default, decoder: decoder) { [weak self] result in
            switch result {
            case .success(let response):
                
                guard let self = self else { return }
                
                self.lastSnapshot = response.items.count != 10 ? response.lastSnapshot : nil
                self.samples = response.items
                
                debugPrint("count : \(self.samples.count)")
                debugPrint("can load more : \(self.canLoadMore())")
                
            case .failure(let error):
                debugPrint(error)
            }
        }
        
    }
    
    func canLoadMore() -> Bool {
        return lastSnapshot != nil
    }
    
    func loadMore() {
                
        guard let last = lastSnapshot else { return }
        
        debugPrint("loadMore")
        
        let query = firestore.collection("samples")
            .order(by: "date", descending: true)
            .start(afterDocument: last)
            .limit(to: 10)
        
        query.getDocumentResponseAs(SampleModel.self, source: .default, decoder: decoder) { [weak self] result in
            switch result {
            case .success(let response):
                guard let self = self else { return }
                self.lastSnapshot = response.items.count != 10 ? response.lastSnapshot : nil
                self.samples += response.items
                
            case .failure(let error):
                debugPrint(error)
            }
        }
        
    }
    
    func fetchSingleDocument() {
        let ref = firestore.collection("samples").document("single_document")
        
        ref.getDocumentAs(SampleModel.self, decoder: decoder) { result in
            switch result {
            case .success(let response):
                debugPrint("sample document")
                debugPrint(response ?? "null")
            case .failure(let error):
                debugPrint(error)
            }
        }
        
    }
    
    func addDocument() {
        
        let ref = firestore.collection("samples").document()
        
        let model = SampleModel.init(id: "tmp", title: "sample text", date: Date())
        
        ref.setDataAs(model, encoder: encoder) { result in
            switch result {
            case .success:
                debugPrint("success to save")
                
            case .failure(let error):
                debugPrint(error)
            }
        }
        
    }
    
    func observeDocuments() {
        
        //get first document
        let query = firestore.collection("samples")
            .order(by: "date", descending: true)
            .limit(to: 1)
        
        
        listener = query.addSnapshotListenerAs(SampleModel.self, decoder: decoder) { [weak self] result in
            switch result {
            case .success(let snapshotDiff):
                
                debugPrint("added    : \(snapshotDiff.added.count)")
                debugPrint("modified : \(snapshotDiff.modified.count)")
                debugPrint("removed  : \(snapshotDiff.removed.count)")
                
                guard let self = self else { return }
                
                var samples = self.samples
                FCSnapshotDiff.apply(diffs: snapshotDiff, value: &samples)
                self.samples = samples
                
            case .failure(let error):
                debugPrint(error)
            }
        }
        
    }
    
}
