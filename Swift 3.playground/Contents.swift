import UIKit
import PlaygroundSupport

var i = 0
i += 1
i -= 1

for i in 1...10 {
  print(i)
}
(1...10).forEach {
  print($0)
}

func gcd(a: Int, b: Int) -> Int {
  
  if (a == b) {
    return a
  }
  
  var c = a
  var d = b
  
  repeat {
    if (c > d) {
      c = c - d
    } else {
      d = d - c
    }
  } while (c != d)
  
  return c
}
gcd(a: 8, b: 12)

class Responder: NSObject {
  
  func tap() {
    print("Button pressed")
  }
}
let responder = Responder()

let button = UIButton(type: .system)
button.setTitle("Button", for: [])
button.addTarget(responder, action: #selector(Responder.tap), for: .touchUpInside)
button.sizeToFit()
button.center = CGPoint(x: 50, y: 25)

let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
let view = UIView(frame: frame)
view.addSubview(button)
PlaygroundPage.current.liveView = view

class Person: NSObject {
  var name: String = ""
  
  init(name: String) {
    self.name = name
  }
}
let me = Person(name: "Cosmin")
me.value(forKeyPath: #keyPath(Person.name))

let file = Bundle.main().pathForResource("tutorials", ofType: "json")
let url = URL(fileURLWithPath: file!)
let data = try! Data(contentsOf: url)
let json = try! JSONSerialization.jsonObject(with: data)
print(json)

let r = 3.0
let circumference = 2 * .pi * r
let area = .pi * r * r

let queue = DispatchQueue(label: "Swift 3")
queue.async {
  print("Swift 3 queue")
}

class View: UIView {
  
  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    
    let blue = UIColor.blue().cgColor
    context.setFillColor(blue)
    let red = UIColor.red().cgColor
    context.setStrokeColor(red)
    context.setLineWidth(10)
    context.addRect(frame)
    context.drawPath(using: .fillStroke)
  }
}
let aView = View(frame: frame)

for i in (1...10).reversed() {
  print(i)
}
var array = [1, 5, 3, 2, 4]
for (index, value) in array.enumerated() {
  print("\(index + 1) \(value)")
}
let sortedArray = array.sorted()
print(sortedArray)
array.sort()
print(array)



















