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


```


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

#####delegate
一个类遵守某个协议 写weak var delegte: MyClassDelegate? 的话。会发生一下错误

**weak var delegate: MyClassDelegate? 编译错误**

**'weak' cannot be applied to non-class type 'MyClassDelegate**
因为swift 中的protocol除了适用于类。还适用于enmu struct,他们本身就不通过引用计数来管理内存，所以也不可能用 weak 这样的 ARC 的概念来进行修饰

想要在 Swift 中使用 weak delegate，我们就需要将 protocol 限制在 class 内。一种做法是将 protocol 声明为 Objective-C 的，这可以通过在 protocol 前面加上 @objc 关键字来达到，Objective-C 的 protocol 都只有类能实现，因此使用 weak 来修饰就合理了

另一种可能更好的办法是在 protocol 声明的名字后面加上 class，这可以为编译器显式地指明这个 protocol 只能由 class 来实现。

```
@objc protocol MyClassDelegate {
    func method()
}

protocol MyClassDelegate: class {
    func method()
}
```

#####关联 Associated Object
Swift 关联写法有所改变
**key 的类型在这里声明为了 Void?，并且通过 & 操作符取地址并作为 UnsafePointer<Void> 类型被传入。这在 Swift 与 C 协作和指针操作时是一种很常见的用法** 

```
// MyClassExtension.swift
private var key: Void?

extension MyClass {
    var title: String? {
        get {
            return objc_getAssociatedObject(self, &key) as? String
        }
		set {
            objc_setAssociatedObject(self,
                &key, newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}



```

#####@synchronized 在swift 中不存在。被其本质的原理写法替代
**@synchronized 在幕后做的事情是调用了 objc_sync 中的 objc_sync_enter 和 objc_sync_exit 方法**

```
func myMethod(anObj: AnyObject!) {
    objc_sync_enter(anObj)
    // 在 enter 和 exit 之间 anObj 不会被其他线程改变
    objc_sync_exit(anObj)
}

// 尾闭包封装
func synchronized(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

func myMethodLocked(anObj: AnyObject!) {
    synchronized(anObj) {
        // 在括号内 anObj 不会被其他线程改变
    }
}
```

#####桥接转换CF 
** OC: 对于 CF 系的 API，如果 API 的名字中含有 Create，Copy 或者 Retain 的话，在使用完成后，我们需要调用 CFRelease 来进行释放**

**Swift 中我们不再需要显式地去释放带有这些关键字的内容了 (事实上，含有 CFRelease 的代码甚至无法通过编译) CF 也在arc 的管辖范围内**

#####print
使用 CustomStringConvertible 接口，这个接口定义了将该类型实例输出时所用的字符串。相对于直接在原来的类型定义中进行更改，我们更应该倾向于使用一个 extension，这样不会使原来的核心部分的代码变乱变脏

```
extension Meeting: CustomStringConvertible {
    var description: String {
        return "于 \(self.date) 在 \(self.place) 与 \(self.attendeeName) 进行会议"
    }
}

print(meeting)
// 于 2015-08-10 03:33:34 +0000 在 会议室B1 与 小明 进行会议”
```

#####异常处理机制
NSError 的使用方式其实变相在鼓励开发者忽略错误

```
do {
    try d.writeToFile("Hello", options: [])
} catch let error as NSError {
    print ("Error: \(error.domain)")
}
```

```
enum LoginError: ErrorType {
    case UserNotFound, UserPasswordNotMatch
}

func login(user: String, password: String) throws {
    //users 是 [String: String]，存储[用户名:密码]
    if !users.keys.contains(user) {
        throw LoginError.UserNotFound
    }
    if users[user] != password {
        throw LoginError.UserPasswordNotMatch
    }
    print("Login successfully.")
}

// 调用
do {
    try login("onevcat", password: "123")
} catch LoginError.UserNotFound {
    print("UserNotFound")
} catch LoginError.UserPasswordNotMatch {
    print("UserPasswordNotMatch")
}
```
**局限性:对于异步api，抛出异常的机制是不可用的**
但是一般对于异步的API，耗时出错的可能性更大。一般用enmu 来封装一下。枚举 (enum) 类型现在是可以与其他的实例进行绑定的，我们还可以让方法返回枚举类型，然后在枚举中定义成功和错误的状态，并分别将合适的对象与枚举值进行关联

```
enum Result {
    case Success(String)
    case Error(NSError)
}

func doSomethingParam(param:AnyObject) -> Result {
    //...做某些操作，成功结果放在 success 中
    if success {
        return Result.Success("成功完成")
    } else {
        let error = NSError(domain: "errorDomain", code: 1, userInfo: nil)
        return Result.Error(error)
    }
}

// 利用 switch 中的 let 来从枚举值中将结果取出
let result = doSomethingParam(path)
switch result {
    case let .Success(ok):
    let serverResponse = ok
case let .Error(error):
    let serverResponse = error.description
}
```

**在 Swift 2 时代中的错误处理，现在一般的最佳实践是对于同步 API 使用异常机制，对于异步 API 使用泛型枚举(上面的例子是Stirng)**

#####断言
assert(-100>0, "达不到绝对零度哦")
**断言只在debug状态有效,不在release状态起作用 。 如果release状态下，让程序终止,那么使用fatalError**

##### NSNull
NSNull 出场最多的时候就是在 JSON 解析了,如果json中某个值为控制，那么系统会默认用NSNull对象来表示，因为只能存对象

#####宏定义 define
**swift中没有宏定义**

#####柯里化(Curring)
就是把接受多个参数的方法变换成接受第一个参数的方法，并且返回接受余下的参数并且返回结果的新方法

```
func addTwoNumbers(a: Int)(num: Int) -> Int {
    return a + num
}

let addToFour = addTwoNumbers(4)    // addToFour 是一个 Int -> Int
let result = addToFour(num: 6)      // result = 10”


// let result = addTwoNumbers(4)(6)
```

#####Struct mutable方法
Struct 出来的变量是 Immutable 的，想要用一个方法去改变变量里面的值的时候必须要加上一个关键词 mutating,类的话就不需要加上mutating

```
struct User {
    var age : Int
    var weight : Int
    var height : Int

    mutating func gainWeight(newWeight: Int) {
        weight += newWeight
    }
}
```

#####将 protocol 的方法声明为 mutating
**swift中的协议可以被类。结构体，枚举遵守，要考虑到除了类的情况。mutating 关键字修饰方法是为了能在该方法中修改 struct 或是 enum 的变量**

#####@autocolsure 自动闭包
**@autoclosure 做的事情就是把一句表达式自动地封装成一个闭包 (closure)**

```
func logIfTrue(@autoclosure predicate: () -> Bool) {
 // 参数名前面加上 @autoclosure 关键字
    if predicate() {
        println("True")
        }
    }
    
logIfTrue(2 > 1)
```


#####操作符

**如果我们要新加操作符的话，需要先对其进行声明，告诉编译器这个符号其实是一个操作符。**

```
infix operator +* {
    associativity none // 结合律
    precedence 160 // 优先级 乘除150 加减140
}

func +* (left: Vector2D, right: Vector2D) -> Double {
    return left.x * right.x + left.y * right.y
}
```

#####func 的参数修饰

```
// 方法的参数上也是如此，我们不写修饰符的话，默认情况下所有参数都是 let 的
func incrementor(var variable: Int) -> Int {
    return ++variable
}

将参数写作 var 后，通过调用返回的值是正确的，而 luckyNumber 还是保持了原来的值。这说明 var 只是在方法内部作用，而不直接影响输入的值。有些时候我们会希望在方法内部直接修改输入的值，这时候我们可以使用 inout 来对参数进行修饰
```

#####Any 和AnyObject
**AnyObject 可以代表任何 class 类型的实例  id == AnyObject?**

**Any 可以表示任意类型，甚至包括方法 (func) 类型**

#####可变参数
**可变参数只能作为方法中的最后一个参数来使用,当做数组来用，但是用之前先判空，判断数组是否有值**

######初始化方法顺序
**某个类的子类中，初始化方法里语句的顺序并不是随意的，我们需要保证在当前子类实例的成员初始化完成后才能调用父类的初始化方法**

```
class Tiger: Cat {
    let power: Int
    override init() {
        power = 10 // 自己的属性
        super.init()
        name = "tiger" // 父类的属性
    }
}
```
* 设置子类自己需要初始化的参数，power = 10
* 调用父类的相应的初始化方法，super.init()
* 对父类中的需要改变的成员进行设定，name = "tiger

**规则**

* 初始化路径必须保证对象完全初始化，这可以通过调用本类型的 designated 初始化方法来得到保证

* 子类的 designated 初始化方法必须调用父类的 designated 方法，以保证父类也完成初始化。

######protocol 组合
protocol<ProtocolA, ProtocolB, ProtocolC> == protocol ProtocolD: ProtocolA, ProtocolB, ProtocolC {}


#####static 和 class
**swfit中“类型范围作用域” 有两个，它们分别是 static 和 class**

*在非 class 的类型上下文中，我们统一使用 static 来描述类型作用域*

##### ...  "a"..."z"

#####AnyClass 元类型 .self
**typealias AnyClass = AnyObject.Type**

* 通过 AnyObject.Type 这种方式所得到是一个元类型 (Meta) ,比如 A.Type 代表的是 A 这个类型的类型
* .self 可以用在类型后面取得类型本身，也可以用在某个实例后面取得这个实例本身

#####接口和类方法中的self

```
protocol Copyable {
    func copy() -> Self
}

class MyClass: Copyable {
    var num = 1

    func copy() -> Self {
        let result = self.dynamicType.init()
        result.num = num
        return result
    }

    required init() {

    }
}
```

* 在这里需要的是通过一个和当前上下文 (也就是和 MyClass) 无关的，又能够指代当前类型的方式进行初始化。希望你还能记得我们在对象类型中所提到的 dynamicType，这里我们就可以使用它来做初始化，以保证方法与当前类型上下文无关，这样不论是 MyClass 还是它的子类，都可以正确地返回合适的类型满足 Self 的要求”

* 编译器提示我们如果想要构建一个 Self 类型的对象的话，需要有 required 关键字修饰的初始化方法，这是因为 Swift 必须保证当前类和其子类都能响应这个 init 方法

##### Optional Map
**方法能对数组中的所有元素应用某个规则，然后返回一个新的数组**

```
let arr = [1,2,3]
let doubled = arr.map{
    $0 * 2
}
print(doubled)

// 并非只能用于数组，也能用于可选类型
let num: Int? = 3
let result = num.map {
    $0 * 2
}
```
