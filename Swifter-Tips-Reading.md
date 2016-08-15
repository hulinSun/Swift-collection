##读猫神Swifter 笔记

#####实例方法的动态调用

不直接使用实例来调用对象方法： 通过类型获取这个类的实例方法签名，在通过传递实例拿到实际需要调用的方法

```
class MyClass {
    func method(number: Int) -> Int {
        return number + 1
    }
}

let f = MyClass.method
let object = MyClass()
let result = f(object)(1)

```

######Swift单例的集中写法

```
class MyManager {
    class var sharedManager : MyManager {
    // Swift 1.2之前的写法，因为1.2不支持存储属性的类属性。所以用一个Struct来存储类型变量
        struct Static {
            static let sharedInstance : MyManager = MyManager()
        }

        return Static.sharedInstance
    }
}


// 想用一个只存在一份的属性，将其定义为全局的scope + Swift 权限关键字private 。只能自己当前文件访问
private let sharedInstance = MyManager()
class MyManager  {
    class var sharedManager : MyManager {
        return sharedInstance
    }
}


// 2.0之后写法
class MyManager  {
    private static let sharedInstance = MyManager()
    class var sharedManager : MyManager {
        return sharedInstance
    }
} 

```

#####UIApplicationMain 方法
这个方法将根据第三个参数初始化一个 UIApplication 或其子类的对象并开始接收事件 (在这个例子中传入 nil，意味使用默认的 UIApplication)。最后一个参数指定了 AppDelegate 类作为应用的委托，它被用来接收类似 didFinishLaunching 或者 didEnterBackground 这样的与应用生命周期相关的委托方法。另外，虽然这个方法标明为返回一个 int，但是其实它并不会真正返回。它会一直存在于内存中，直到用户或者系统将其强制终止。

```
int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil,
                   NSStringFromClass([AppDelegate class]));
    }
}
```
**引出的问题：如果监听每次发送事件**

```
class MyApplication: UIApplication {
    override func sendEvent(event: UIEvent!) {
        super.sendEvent(event)
        // 在程序启动的时候用自己自定义的UIApplication子类，这样就能抓到这个时机做事情
        println("Event sent: \(event)");
    }
}
```


##### @objc 和 dynamic
**@objc作用**
oc与Swift 混编时。要使用oc代码或特殊调用纯Swift 时候，会找不到方法(这些运行时的信息)而崩溃，解决方法： 在Swift 文件中将需要暴露给oc 使用的任何地方(类，方法，属性)加上@objc修饰符 (运行时能找到)

#####可选接口和接口扩展
原生的 Swift protocol 里没有可选项，所有定义的方法都是必须实现的。如果想要像oc那样，在协议前加上 @objc

```
@objc protocol OptionalProtocol {
    optional func optionalMethod()  // 可选
    func necessaryMethod()          // 必须”
}
```
但是此时，@objc修饰的protocol 只能被class 实现，不能被struct enum 实现

在 Swift 2.0 中，我们有了另一种选择，那就是使用 protocol extension。我们可以在声明一个 protocol 之后再用 extension 的方式给出部分方法默认的实现。这样这些方法在实际的类中就是可选实现的了

```
protocol OptionalProtocol {
    func optionalMethod()        // 可选
    func necessaryMethod()       // 必须
    func anotherOptionalMethod() // 可选
}

extension OptionalProtocol {
// 不实现会有默认的实现。
func optionalMethod() {
        print("Implemented in extension")
    }
    func anotherOptionalMethod() {
        print("Implemented in extension")
    }
}
```

#####内存管理，weak unowned
Swift对象的释放原则也是遵循了自动引用计数(ARC)

unowned 类似于 oc 的 unsafe_unretained，而 weak 就是以前的 weak。unowned 设置以后即使它原来引用的内容已经被释放了，它仍然会保持对被已经释放了的对象的一个 "无效的" 引用，它不能是 Optional 值，也不会被指向 nil。如果你尝试调用这个引用的方法或者访问成员属性的话，程序就会崩溃。而 weak 则友好一些，在引用的内容被释放后，标记为 weak 的成员将会自动地变成 nil (因此被标记为 @weak 的变量一定需要是 Optional 值)。关于两者使用的选择，Apple 给我们的建议是如果能够确定在访问时不会已被释放的话，尽量使用 unowned，如果存在被释放的可能，那就选择用 weak。

**循环引用解决**

```
lazy var printName: ()->() = {
    [weak self] in
    if let strongSelf = self {
        print("The name is \(strongSelf.name)")
    }
}

// 捕获列表
{ [unowned self, weak someObject] (number: Int) -> Bool in
    //...
    return true
}
```

#####@autoreleasepool
在 app 中，整个主线程其实是跑在一个自动释放池里的，并且在每个主 Runloop 结束时进行 drain 操作。为了解决例如for循环里没有机会释放的对象，数量太大，很容易造成内存不足而crash

swfit中，autoreleasepool变成了一个接受闭包的方法

```
// 尾闭包
func loadBigData() {
if let path = NSBundle.mainBundle()
        .pathForResource("big", ofType: "jpg") {
        for i in 1...10000 {
            autoreleasepool {
                let data = NSData.dataWithContentsOfFile(
                    path, options: nil, error: nil)
                    NSThread.sleepForTimeInterval(0.5)
            }
        }
    }
}
```

#####获取对象类型
1.如果是NSObject的子类，可以通过运行时

```
let date = NSDate()
let name: AnyClass! = object_getClass(date)
println(name) // __NSDate”
let name = date.dynamicType // 专业写法
```

#####自省
```
obj1.isKindOfClass(ClassA.self)    
obj2.isMemberOfClass(ClassA.self)  
if p is Person{}
```
对于一个不确定的类型，我们现在可以使用 is 来进行判断。is 在功能上相当于原来的 isKindOfClass，可以检查一个对象是否属于某类型或其子类型 同事也可以用enum 和struct

#####KVO
KVO 的目的并不是为当前类的属性提供一个钩子方法，而是为了其他不同实例对当前的某个属性 (严格来说是 keypath) 进行监听时使用的。其他实例可以充当一个订阅者的角色，当被监听的属性发生变化时，订阅者将得到通知,在Swift中也可以使用kvo,但仅限于NSObject子类中.swift为了效率，默认禁用了动态派发,将对象标记为dynamic 触发动态派发

// Swift kvo 的局限性是属性需要用dynamic修饰
```
class MyClass: NSObject {
    dynamic var date = NSDate()
}
private var myContext = 0
class Class: NSObject {
    var myObject: MyClass!
    override init() {
        super.init()
        myObject = MyClass()
        print("初始化 MyClass，当前日期: \(myObject.date)")
        myObject.addObserver(self,
            forKeyPath: "date",
            options: .New,
            context: &myContext)

        delay(3) {
            self.myObject.date = NSDate()
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?,
            ofObject object: AnyObject?,
            change: [String : AnyObject]?,
            context: UnsafeMutablePointer<Void>)
    {
        if let change = change where context == &myContext {
            let a = change[NSKeyValueChangeNewKey]
            print("日期发生变化 \(a)")
        }
    }
}

#####局部scope
```
func local(closure: ()->()) {
    closure()
}
override func loadView() {
    let view = UIView(frame: CGRectMake(0, 0, 320, 480))

	// 可以替代懒加载的高逼格写法,配合尾闭包写法
    local {
        let titleLabel = UILabel(frame: CGRectMake(150, 30, 20, 40))
        titleLabel.textColor = UIColor.redColor()
        titleLabel.text = "Title"
        view.addSubview(titleLabel)
    }
    self.view = view
}

```
在Swift中有do关键字来作为捕获异常的作用于,恰好用来当做局部作用于.可以写成如下

```
do {
    let textLabel = UILabel(frame: CGRectMake(150, 80, 20, 40))
    //...
}

```

######Swizzle

```
extension UIButton {
    class func xxx_swizzleSendAction() {
        struct xxx_swizzleToken {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&xxx_swizzleToken.onceToken) {
            let cls: AnyClass! = UIButton.self

            let originalSelector = Selector("sendAction:to:forEvent:")
            let swizzledSelector = Selector("xxx_sendAction:to:forEvent:")

            let originalMethod =
                        class_getInstanceMethod(cls, originalSelector)
            let swizzledMethod =
                        class_getInstanceMethod(cls, swizzledSelector)

            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
```

#####遍历

```
var result = 0
for (idx, num) in [1,2,3,4,5].enumerate() {
    result += num
    if idx == 2 {
        break
    }
}
print(result)
```


#####类型编码
1.oc关键字 @encode：通过类型获取对应编码

```
char *typeChar1 = @encode(int32_t);
char *typeChar2 = @encode(NSArray);
// typeChar1 = "i", typeChar2 = "{NSArray=#}
```

```
let p = NSValue(CGPoint: CGPointMake(3, 3))
String.fromCString(p.objCType)
// {Some "{CGPoint=dd}"}
Swift 中的处理方法 NSValue.objCType
```
