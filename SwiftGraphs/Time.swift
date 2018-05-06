//
//  Time.swift
//  SwiftGraphs
//
//  Created by Bromberger, Seth on 02-May-18.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

import Dispatch
import Foundation

func timeIt(_ f: () -> Void) -> UInt64 {
    let start = DispatchTime.now()
    f()
    let end = DispatchTime.now()
    let elapsedNS = end.uptimeNanoseconds - start.uptimeNanoseconds
    return (elapsedNS)
}
