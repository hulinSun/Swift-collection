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
* NSBundle.mainBundle() 改为 Bundle.main()
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



##### Swift 3 新的访问控制
新添加了两种访问控制权限 fileprivate和 open。

**fileprivate
在原有的swift中的 private其实并不是真正的私有，如果一个变量定义为private，在同一个文件中的其他类依然是可以访问到的。这个场景在使用extension的时候很明显。当我们标记为private时，意为真的私有还是文件内可共享呢？
当我们如果意图为真正的私有时，必须保证这个类或者结构体在一个单独的文件里。否则可能同文件里其他的代码访问到。
由此，在swift 3中，新增加了一个 fileprivate来显式的表明，这个元素的访问权限为文件内私有。过去的private对应现在的fileprivate。现在的private则是真正的私有，离开了这个类或者结构体的作用域外面就无法访问。**

**open
open则是弥补public语义上的不足。
现在的pubic有两层含义：
这个元素可以在其他作用域被访问
这个元素可以在其他作用域被继承或者override
继承是一件危险的事情。尤其对于一个framework或者module的设计者而言。在自身的module内，类或者属性对于作者而言是清晰的，能否被继承或者override都是可控的。但是对于使用它的人，作者有时会希望传达出这个类或者属性不应该被继承或者修改。这个对应的就是 final。
 final的问题在于在标记之后，在任何地方都不能override。而对于lib的设计者而言，希望得到的是在module内可以被override，在被import到其他地方后其他用户使用的时候不能被override。
这就是 open产生的初衷。通过open和public标记区别一个元素在其他module中是只能被访问还是可以被override。**

现在的访问权限则依次为：open，public，internal，fileprivate，private。


#### 截屏代码(view.drawHierarchy)

```

extension UIImage {
    class func snapshot(from view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
//        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot!
    }
}
```


#### 通知

```
NotificationCenter.default.addObserver(tableView, selector: #selector(UITableView.reloadData), name: NSNotification.Name.UIApplicationDidBecomeActive, object:nil)
        
NotificationCenter.default.post(name: NSNotification.Name(rawValue: "someNotification"), object: nil)
```

```
   ninja.center = {
            let x = (frame.minX + ninja.frame.width / 2)
            let y = (frame.maxY - ninja.frame.height / 2)
            return CGPoint(x: x, y: y)
        }()
```

#### 异常机制 抛出的错误类型探讨？

把错误类型的作用域限制在每个抽象层次。

#### 控制器常量的统一管理

```
    struct Constants {
        struct ColorPalette {
            static let green = UIColor(red:0.00, green:0.87, blue:0.71, alpha:1.0)
        }
    }
```

#### loadNib

**dynamicType is deprecated. Use 'type(of …)' instead**

```
    func loadNib() -> UIView {
        let bundel = Bundle(for: type(of: self))
        let nibName =  type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundel)
        let v  = nib.instantiate(withOwner: self, options: nil).last as! UIView
        return v
    }
    
    
public protocol UIViewLoading {}
extension UIView : UIViewLoading {}
public extension UIViewLoading where Self : UIView {
    static func loadFromNib() -> Self {
        let nibName = "\(self)".characters.split{$0 == "."}.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).last as! Self
    }
}

```


#### 关于添加类似于GPUImage Cordov 的静态库问题
**一定是要在工程中addfile才可以，直接拖是不行的,经典报错image not found**

#### 类名创建对象
```
guard let className = NSClassFromString("classString") else {return}
guard let model = className as? NSObject.Type else {return}
let m = model.init()
```

