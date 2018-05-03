/*
 
 Sorting Algorithm that sorts an input array of integers digit by digit.
 
 */

// NOTE: This implementation does not handle negative numbers

extension Array where Element:BinaryInteger {
    public mutating func radixSort() {
        let radix = 10  //Here we define our radix to be 10
        var done = false
        var index: Index
        var digit = 1  //Which digit are we on?
        while !done {  //While our  sorting is not completed
            done = true  //Assume it is done for now
            var buckets: [[Element]] = []  //Our sorting subroutine is bucket sort, so let us predefine our
            for bucketNum in 0..<radix {
                buckets.append([])
                buckets[bucketNum].reserveCapacity(self.count / radix)
            }
            
            for number in self {
                index = Index(Int(number) / digit)  //Which bucket will we access?
                buckets[index % radix].append(number)
                if done && index > 0 {  //If we arent done, continue to finish, otherwise we are done
                    done = false
                }
            }
            
            var i = 0
            for j in 0..<radix {
                let bucket = buckets[j]
                for number in bucket {
                    self[i] = number
                    i += 1
                }
            }
            
            digit *= radix  //Move to the next digit
        }
    }
}
func radixSort<T:BinaryInteger>(_ array: inout [T] ) {
    let radix = 10  //Here we define our radix to be 10
    var done = false
    var index: Array<T>.Index
    var digit = 1  //Which digit are we on?
    
    while !done {  //While our  sorting is not completed
        done = true  //Assume it is done for now
        
        var buckets: [[T]] = []  //Our sorting subroutine is bucket sort, so let us predefine our buckets
        
        for bucketNum in 0..<radix {
            buckets.append([])
            buckets[bucketNum].reserveCapacity(array.count / radix)
        }
        
        for number in array {
            index = Array<T>.Index(Int(number) / digit)  //Which bucket will we access?
            buckets[index % radix].append(number)
            if done && index > 0 {  //If we arent done, continue to finish, otherwise we are done
                done = false
            }
        }
        
        var i = 0
        
        for j in 0..<radix {
            let bucket = buckets[j]
            for number in bucket {
                array[i] = number
                i += 1
            }
        }
        
        digit *= radix  //Move to the next digit
    }
}
