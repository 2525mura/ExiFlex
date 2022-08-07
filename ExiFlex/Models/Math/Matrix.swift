//
//  Matrix.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/07.
//

import Foundation
import UIKit

//行列クラス
public class Matrix {
    var data: [[Double]] = []
    
    public init(data:[[Double]]) {
        self.data = data
    }
    
    //各行の要素の数が一致するかを確認する
    private func assertElementCount(data: [[Double]]){
        for i in 0 ..< data.count {
            
            if i==0 {
                continue
            }
            assert(data[i].count == data[i-1].count, "各行に含まれる要素の数が一致していません。")
        }
    }
}

//行列同士の積の定義
func *(left: Matrix, right: Matrix) -> Matrix {
    assert(left.data[0].count==right.data.count, "左の列数と右の行数が一致しません。")

    var result: [[Double]] = []

    for i in 0 ..< left.data.count {
        
        var row = [Double]()
        for j in 0 ..< right.data[i].count{
            
            var c = 0.0
            for k in 0 ..< right.data.count{
                let a = left.data[i][k]
                let b = right.data[k][j]
                c = c + (a*b)
            }
            row.append(c)
        }
        result.append(row)
    }
    return Matrix(data: result)
}
