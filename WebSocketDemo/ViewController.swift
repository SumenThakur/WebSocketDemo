//
//  ViewController.swift
//  WebSocketDemo
//
//  Created by Sumendra on 21/05/22.
//

import UIKit

class ViewController: UIViewController{
    @IBOutlet weak var lblSentMsg:UILabel!
    @IBOutlet weak var lblReceivedMsg:UILabel!
    
    private var webSocket : URLSessionWebSocketTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Initial setup for connecting web socket
        setUpForConnectingSocket()
    }
    
    func setUpForConnectingSocket(){
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let url = URL(string: urlString)
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
    }
    
    func ping(){
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                 print("Ping error: \(error)")
            }
        })
    }
    func close(){
        webSocket?.cancel(with: .goingAway, reason: "Going away".data(using: .utf8))
    }
    
    func send(){
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {[weak self] in
            let newMessage = "Sent new message with number \(Int.random(in: 0...1000))"
            self?.webSocket?.send(.string(newMessage), completionHandler: { error in
                if error == nil{
                    DispatchQueue.main.async {
                        self?.lblSentMsg.text = newMessage
                    }
                    self?.send()
                    debugPrint(newMessage)

                }else{
                    debugPrint("There is an error in sending message")
                }
            })
        }
        
        
    }
    func receive(){
        webSocket?.receive(completionHandler: {[weak self] result in
            switch result{
            case .success(let message):
                switch message{
                case .data(let data):
                   debugPrint("Received data is :\(data)")
                case .string(let msg):
                    DispatchQueue.main.async {
                    self?.lblReceivedMsg?.text = "Received:\(msg)"
                    }
                    debugPrint("Received:\(msg)")
                @unknown default:
                    break
                }
            case .failure(let error):
                debugPrint("Error in receiving data:\(error)")
            }
            self?.receive()
        })
    }
    

}

extension ViewController: URLSessionWebSocketDelegate{
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        debugPrint("WebSocket is connected")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        debugPrint("WebSocket is closed")

    }
}

