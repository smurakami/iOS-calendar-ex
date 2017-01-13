//
//  ViewController.swift
//  CalendarEx
//
//  Created by 村上晋太郎 on 2017/01/13.
//  Copyright © 2017年 村上晋太郎. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    let eventStore = EKEventStore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allowAuthorization()
        listEvents(calendar: getExchangeCalendar())
        
        
        // イベントを作成してエクスチェンジに送信
//        let startDate = Date()
//        let cal = Calendar(identifier: .gregorian)
//        let endDate = cal.date(byAdding: .hour, value: 2, to: startDate, wrappingComponents: true)!
//        let title = "カレンダーテストイベント"
//        // イベントを作成して情報をセット
//        let event = EKEvent(eventStore: eventStore)
//        event.title = title
//        event.startDate = startDate
//        event.endDate = endDate
//
//        addEvent(event, to: getExchangeCalendar())
    }
    
    func addEvent(_ event: EKEvent, to calendar: EKCalendar) {
        // イベントの情報を準備
        event.calendar = calendar
        // イベントの登録
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch let error {
            print(error)
        }
    }
    
    func getExchangeCalendar() -> EKCalendar {
        let calendars = eventStore.calendars(for: .event)
        let calendar = calendars.first(where: {$0.type == .exchange && $0.title == "予定表"})!
        return calendar
    }
    
    // 許可状況を確認して、許可されていなかったら許可を得る
    func allowAuthorization() {
        if getAuthorization_status() {
            // 許可されている
            return
        } else {
            // 許可されていない
            eventStore.requestAccess(to: .event, completion: {
                (granted, error) in
                if granted {
                    return
                }
                else {
                    print("Not allowed")
                }
            })
            
        }
    }
    
    // 認証ステータスを確認する
    func getAuthorization_status() -> Bool {
        // 認証ステータスを取得
        let status = EKEventStore.authorizationStatus(for: .event)
        
        // ステータスを表示 許可されている場合のみtrueを返す
        switch status {
        case .notDetermined:
            print("NotDetermined")
            return false
            
        case .denied:
            print("Denied")
            return false
            
        case .authorized:
            print("Authorized")
            return true
            
        case .restricted:
            print("Restricted")
            return false
        }
    }
    
    func listEvents(calendar: EKCalendar) {
        // 検索条件を準備
        let cal = Calendar(identifier: .gregorian)
        let startDate = cal.date(byAdding: .year, value: -1, to: Date(), wrappingComponents: true)!
        let endDate = cal.date(byAdding: .year, value: 11, to: Date(), wrappingComponents: true)!
        // 検索するためのクエリー的なものを用意
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        // イベントを検索
        let events = eventStore.events(matching: predicate)
        print(events)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

