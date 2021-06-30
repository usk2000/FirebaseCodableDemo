//
//  SampleModel.swift
//  FirebaseCodableDemo
//
//  Created by Yusuke Hasegawa on 2021/06/30.
//

import Foundation
import FirebaseCodable

struct SampleModel: FirestoreCodable, Equatable {
    var id: String
    let title: String
    let date: Date
}
