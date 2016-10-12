## 一些变化

#### ++ --改变

取消了i++这样的写法。取而代之的用 i+=1; ==> i = i + 1

#### for 循环 

```
// Swift 不在允许这样写了
for (i = 1; i <= 10; i++) {
  print(i)
}

取而代之的用以下方法
for i in 1...10 {
  print(i)
}

(1...10).forEach { // 闭包写法
  print($0)
}

```

####移除函数参数的 var 标记

* 如果不需要在函数内部对参数进行修改的话，函数参数通常都定义为常量。然而，在某些情况下，定义成变量会更加合适。在 Swift 2 中，你可以用 var 关键字来将函数参数标记为变量。一旦参数用 var 来标记，就会生成一份变量的拷贝，如此便能在方法内部对变量进行修改了
* Swift 3 不在允许开发者这样来将参数标记为变量了，因为开发者可能会在 var 和 inout 纠结不已。所以最新的 Swift 版本中，就干脆移除了函数参数标记 var 的特性

```
// Swift 2
func gcd(var a: Int, var b: Int) -> Int {
 
  if (a == b) {
    return a
  }
 
  repeat {
    if (a > b) {
      a = a - b
    } else {
      b = b - a
    }
  } while (a != b)
 
  return a
}

// Swift 3
func gcd(a: Int, b: Int) -> Int{
 
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

```

#### 不再用string 的 selector
Swift 3 将字符串 selector 的写法改为了 #selecor()。这将允许编译器提前检查方法名的拼写问题，而不用等到运行时。
button.addTarget(responder, action: #selector(Responder.tap), for: .touchUpInside)

#### 不再是 String 的 key-path 写法

```
class Person: NSObject {
  var name: String = ""
 
  init(name: String) {
    self.name = name
  }
}
let me = Person(name: "Cosmin")
me.value(forKeyPath: #keyPath(Person.name))
```

#### Foundation 去掉 NS 前缀

```
let file = Bundle.main().pathForResource("tutorials", ofType: "json")
let url = URL(fileURLWithPath: file!)
let data = try! Data(contentsOf: url)
let json = try! JSONSerialization.jsonObject(with: data)
print(json)
```

#### 函数参数标签的一致性
在 Swift 3 中，函数的调用要像下面这样：gcd(a: 8, b: 12)
即使是第一个参数，也必须带上标签。如果不带，Xcode 8 会直接报错。

```
苹果又给出了一种不用给第一个参数带标签的解决方案。在第一个参数前面加上一个下划线：
func gcd(_ a: Int, b: Int) -> Int { ... }

```

####M_PI 还是 .pi

* 在旧版本的 Swift 中，我们使用 M_PI 常量来表示 π。而在 Swift 3 中，π 整合为了 Float，Double 与 CGFloat 三种形式：Float.pi ,Double.pi ,CGFloat.pi

```
let r = 3.0
let circumference = 2 * Double.pi * r
let area = Double.pi * r * r
let area = .pi * r * r // 更精简的写法
```

#### GCD 

```
let queue = DispatchQueue(label: "Swift 3")
queue.async {
  print("Swift 3 queue")
}
```

#### 更 Swift 范的 Core Graphics

```
let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
 
class View: UIView {
 
  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    
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
```

#### 动词与名词的命名约定


####更 Swift 范的 API
Swift 3 采用了更具有哲理性 API 设计方式——移除不必要的单词。所以，如果某些词是多余的，或者是能根据上下文推断出来的，那就直接移除

* XCPlaygroundPage.currentPage 改为 PlaygroundPage.current
* button.setTitle(forState) 改为 button.setTitle(for)
* button.addTarget(action, forControlEvents) 改为 button.addTarget(action, for)
*NSBundle.mainBundle() 改为 Bundle.main()
* NSData(contentsOfURL) 改为 URL(contentsOf)
* NSJSONSerialization.JSONObjectWithData() 改为 JSONSerialization.jsonObject(with)
* UIColor.blueColor() 改为 UIColor.blue()
* UIColor.redColor() 改为 UIColor.red()

####枚举成员
Swift 3 将枚举成员当做属性来看，所以使用小写字母开头而不是以前的大写字母：

* .System 改为 .system
* .TouchUpInside 改为 .touchUpInside
* .FillStroke 改为 .fillStroke
* .CGColor 改为 .cgColor

####@discardableResult
在 Swift 3 中，如果没有接收某方法的返回值，Xcode 会报出警告

```
@discardableResult // 消除警告
func printMessage(message: String) -> String {
    let outputMessage = "Output : \(message)"
    print(outputMessage)
    
    return outputMessage
}
```
