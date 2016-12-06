//
//  ItemRSS.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 1..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation

class ItemRSS {
    var temp : Double   // 기온
    var sky : Int       // 날씨코드
    var pty : Int       // 강우코드
    var wfKor : String  // 날씨
    var ws : Double     // 풍속
    var wdKor : String  // 풍향
    var pop : Int       // 강수확률
    var reh : Int       // 습도
    var seq : Int       // 데이터 순서
    
    init() {
        self.temp = 0
        self.sky = 0
        self.pty = 0
        self.wfKor = ""
        self.ws = 0
        self.wdKor = ""
        self.pop = 0
        self.reh = 0
        self.seq = 0
    }
    
    init(temp : Double,
         sky : Int,
         pty : Int,
         wfKor : String,
         ws : Double,
         wdKor : String,
         pop : Int,
         reh : Int,
         seq : Int) {
        
        self.temp = temp
        self.sky = sky
        self.pty = pty
        self.wfKor = wfKor
        self.ws = ws
        self.wdKor = wdKor
        self.pop = pop
        self.reh = reh
        self.seq = seq
    }
}
