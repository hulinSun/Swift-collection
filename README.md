# Swift-collection
swift 一些知识点收集

**1.Swift 懒加载**

```swift
// MARK: 懒加载
private lazy var icon: UIImageView = { // 如果是私有的那么就private
let i = UIImageView()
return i
}() // 懒加载完毕之后，一定要加上(),表示调用

// 声明数组时，要注意数组里面存的是什么类型，显示的声明出来
lazy var pictureImages = [UIImage]()
```

**2.swift self**

```
1. 不要再控制器中过多的用self 调用，swift 会通过上下文的环境隐式的明确self
2. 如果是在闭包内部，那么必须显示的写self。防止闭包带来的循环引用的问题
view.addSubview(collcetionView)
```
**3. 访问控制**

```
Public：可以访问自己模块或应用中源文件里的任何实体，别人也可以访问引入该模块中源文件里的所有实体。通常情况下，某个接口或Framework是可以被任何人使用时，你可以将其设置为public级别。
Internal：可以访问自己模块或应用中源文件里的任何实体，但是别人不能访问该模块中源文件里的实体。通常情况下，某个接口或Framework作为内部结构使用时，你可以将其设置为internal级别。
Private：只能在当前源文件中使用的实体，称为私有实体。使用private级别，可以用作隐藏某些功能的实现细节。

如果是私有的方法，内部的不想给别人知道，那么加private关键字
private func setupUI(){}
```
**4. 闭包移除所有子控件，不使用遍历数组那方法**

```
//移除一个view 的所有子控件
view.subviews.forEach {$0.removeFromSuperview}
```

**5. 关于闭包**

```
1.在 Swift 中 函数只是闭包的一种特殊形式。
* 全局函数是一个有名字但不会捕获任何值的闭包
* 内嵌函数是一个有名字可以捕获到所在的函数域内值的闭包
* 闭包表达式是一个没有名字的可以捕获上下文中的变量或者常量的闭包

2. 格式
{ (parameters) -> return type in // 参数 -> 返回值 in
    statements
}

3. 数组闭包map 格式
let names = ["zhao","wang","Li"] 
names.map({ (name:String) -> String in  // 正规写法
    "\(name) has been map !"
})

names.map({ name in  // 修改参数名,并且不需要显示的写参数类型。闭包会根据上下文环境来推断
    "\(name) has been map !"
}) 

names.map({"\($0) has been map !"}) // 单行闭包
 
names.map{"\($0) has been map !"} // 尾闭包写法:若闭包是函数的最后一个参数，那么可以省略()

4. 闭包注意点

* 推断类型
compare()函数的第三个参数是闭包表达式,它的类型为(num:Int,value:Int)->Bool,由于 Swift 可以推 断其参数和返回值的类型,所以->和围绕在参数周围的括号可以省略,如以下的代码:
var v1=copare(array,value:500,cb:{(num, value) in return num>value
})

* 省略 return
单行表达式闭包可以通过隐藏 return 关键字来隐式返回单行表达式的结果,可以将上面的例子进行 修改:
var v1=copare(array,value:500,cb:{(num,value) in num>value
})
* 简写参数名
Swift 为内联函数提供了参数名缩写功能,开发者可以通过$0、$1、$2 来顺序的调用闭包的参数。

* 写在一行 当闭包的函数体部分很短时可以将其写在一行上面,如以下代码:
var v1=copare(array,value: 500,cb: {$0 > $1})

* 运算符函数
在 Swift 中 String 类型定义了关于大于号(>)的字符串实现,其作为一个函数接受两个 String 类型 的参数并返回 Bool 类型的值。而这正好与以上代码 sort 函数的第二个参数需要的函数类型相符合。 因 此,可以简单地传递一个大于号,Swift 可以自动推断出您想使用大于号的字符串函数实现:
var v1=copare(array,value:500,cb:>)
在 Swift 1.2 中使用闭包表达式需要注意以下三点:
> 有单返回语句的闭包,现在类型检查时以单表达式闭包处理。
> 匿名的且含有非空返回类型的单表达式,现在可以用在 void 上下文中。  多表达式的闭包类型的情况,可能无法被类型推断出来。

5. 尾闭包注意点
* 如果没有参数, 没有返回值, in和in之前的东西可以省略
* 如果闭包是函数的最后一个参数, 可以写在()后面  -- 尾随闭包
* 如果函数只接受一个参数, 并且这个参数是闭包, 那么()可以省略
* 闭包的简写: 如果闭包没有返回这，没有参数，那么 ()->() in 可以省略不写

6. 闭包 + 数组
* map和flatMap：如何变换元素
* filter：一个元素是否应该被包括进来
* reduce：把数组元素组合起来，得到一个聚合值
* sort和lexicographicalCompare[2]：数组中元素以什么样的顺序排列
* indexOf和contains：某个元素是否匹配
* minElement和maxElement：两个元素中哪个是最大值，哪个是最小值
* elementsEqual和startsWith：两个元素是否相等
* split：某个元素是否是分隔符。
* contains方法它可以在找到第一个目标后及早返回。只要在你真的需要所有结果的时候才使用filter方法

loadData2 ({ print("执行回调") })

loadData3(){
    print("执行回调")
}

loadData4{
    print("执行回调")
}

loadData5("shl") { () -> () in
    print("执行回调")
}


7. 循环引用的问题 weak unowned

* 闭包的循环引用解决方案：weak strong dance (还有一种方法是withExtendlifeTime)方法，延长生命周期
lazy var printName: ()->() = { [weak self] in
    if let strongSelf = self {
        println("The name is \(strongSelf.name)")
    }
}

weak var weakSelf = self
loadData { () -> () in
    // 以后看到self基本上都和闭包有关系
    weakSelf!.view.backgroundColor = UIColor.redColor()
}

弱引用必须被声明为变量，表明其值能在运行时被修改。因为弱引用可以没有值，必须将每一个弱引用声明为可选类型

*  如果我们可以确定在整个过程中 self 不会被释放的话，我们可以将上面的 weak 改为 unowned，这样就不再需要 strongSelf 的判断。但是如果在过程中 self 被释放了而 printName 这个闭包没有被释放的话 (比如 生成 Person 后，某个外部变量持有了 printName，随后这个 Person 对象被释放了，但是 printName 已然存在并可能被调用)，使用 unowned 将造成崩溃。在这里我们需要根据实际的需求来决定是使用 weak 还是 unowned

* 无主引用: 就是在闭包参数前,加上[unowned self]
{ [unowned self] (number: Int) -> Bool in
    return true
}

// 捕获列表： 每一项都由一对元素组成，一个元素是 weak 或 unowned 关键字，另一个元素是类实例的引用(如 self) 或初始化过的变量。如果闭包又参数列表和返回类型，把捕获列表放在它们前面

lazy var someClosure: (Int, String) -> String = {
    [unowned self, weak delegate = self.delegate!]
    (index: Int, stringToProcess: String) -> String in
        // closure body
}

无主引用是永远有值的，所以一定要被定义成非可选类型。用关键字 unowned。无主引用总是可以被直接访问的。

8. 闭包回调： 和block 类似用法  搭配typealias
// 定义闭包类型，类型别名－> 首字母一定要大写
typealias Completion = (result: AnyObject?, error: NSError?) -> ()

```

**6.协议**

```swift
// 代理.注意需要加上 @objc 关键字,因为 有optional 关键字就必须要写上
@objc protocol CustomDelegate : NSObjectProtocol {
    optional func photoDidAddSelector(cell: PhotoSelectorCell)
}

// 写上代理属性
class CustomView {
    weak var CustomDelegate: PhotoSelectorCellDelegate?
}

// 通知代理
func addBtnClick(){
    // self 是代理传出的值
    PhotoCellDelegate?.photoDidAddSelector!(self)
    // 通知代理
    delegate?.textViewDidChange!(self)
}
```

**7.collcetionViewLayout**

```swift
class PhotoSelectorViewLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        // 在 将要布局的时候，设置布局属性
        super.prepareLayout()
        itemSize = CGSize(width: 80, height: 80)
        minimumInteritemSpacing  = 10
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
```

**8. 可选链 **

```
// 如果确定这个某个可选类型的值一定是有值的，那么为了方便起见，就可以使用强制解析。没有必要用可选链走下去
request.URL?.query?.hasPrefix("s") // 但是这个可选链返回的是可选值，所以
request.URL!.query!.hasPrefix("s") // 这个获得的是确定的值

```

**9. 属性拦截,计算属性**

```swift
// didset 拦截
var expires_in: NSNumber?{
didSet{
        // 根据过期的秒数, 生成真正地过期时间
        expires_Date = NSDate(timeIntervalSinceNow: expires_in!.doubleValue)
        print(expires_Date)
    }
}

/// 保存用户过期时间
var expires_Date: NSDate?

//在定义一个计算属性时,必须且只能使用 var 关键字,

class PersonName{
        var name:String="" //1.在只读计算属性中,可以将 get 关键字和花括号去掉
        var returnName :String{
            if (name.isEmpty) {
            return "NULL"
        }else{
            return name
        }
    }
}

* let 关键字不能声明类型属性

* 属性监听 willset传过来的时 newValue， didset 里 money 是赋值之后的值。是新的值，oldValue 是旧值

* 延迟属性不能使用属性监视器

* 在一个类型方法中不可以使用存储属性
* 重写属性： 通过set get didSet willSet 方法重写属性,子类重写必须加入voerride 关键字，并且子类重写可以权限变大，不能权限变小(子类不能将父类的读写属性，重写成只读属性)
```

**10. KVC **

```swift
// 如果kvc 赋值出错的话，那么就会在这个方法里面处理，在这个方法里面打印key 方便调试,并且重写了这个方法，还不会crash 掉
override func setValue(value: AnyObject?, forUndefinedKey key: String) { print(key) }
```

**11. 数组便利方法 **

```
在一个序列中,往往需要获取元素的最大值或者最小值。此时可以使用 maxElement()和 minElement()函数
let sequence1=[9,8,2,3]
let maxValue1=sequence1.maxElement()! // 主要返回的是可选的，所以强制解析一下
```

```
contains()函数可以判断一个序列中是否包含指定的元素。其语法形式如下:序列.contains(元素)
var languages = ["Swift", "Objective-C","C"] //判断在 languages 数组中是否包含"Swift"字符串
if languages.contains("Swift") == true {
        print("languages 序列中包含元素“Swift”")
    }else{
        print("languages 序列中不包含元素“Swift”")
}
```

```
经常需要对序列中元素的进行排序。此时可以使用 Swift 中的 sortInPlace()函数来实现。 其语法形式如下: 序列.sortInPlace()
var languages1 = ["Swift", "Objective-C","C"]
languages1.sortInPlace() // 默认顺序排列
print("排序后:languages=\(languages1)")  // 排序后:languages=[C, Objective-C, Swift]

reverse()函数可以将序列中元素的倒序排列。其语法形式如下: 序列.reverse()
```

**12. 异常机制 **

```
当一个函数遇到错误条件,它能报错。调用函数的地方能抛出错误消息并合理处理。
func canThrowAnErrow() throws {
    // 这个函数有可能抛出错误
}

一个函数可以通过在声明中添加 throws 关键词来抛出错误消息。当你的函数能抛出错误消息时, 你应该在表达式 中前置 try 关键词。
do {
    try canThrowAnErrow() // 没有错误消息抛出
} catch {
    // 有一个错误消息抛出
}
```
** 13. 断言**
```
断言，断言一个语句是否为真，如果表达式为真，那么直接就过掉，什么也不发生，如果为假，那么会触发断言，程序直接崩溃。所以发开阶段可以用，但是发布阶段不能有断言
let age = -3
assert(age >= 0, "A person's age cannot be less than zero") // 因为 age < 0,所以断言会触发
```

** 14.区间运算符**
```
for index in 1...5 {  // 1..<5 ==(1,2,3,4)
    print("\(index) * 5 = \(index * 5)")
}
```
** 15.空和运算符((Nil Coalescing Operator) ?? **

```
空合运算符( a ?? b )将对可选类型 a 进行空判断,如果 a 包含一个值就进行解封,否则就返回一个默认值 b .这 个运算符有两个条件:
* 表达式 a 必须是Optional类型
* 默认值 b 的类型必须要和 a 存储值的类型保持一致
空合并运算符是对以下代码的简短表达方法 a != nil ? a! : b // a 是可选类型 */

```

** 15.字符串 **
```swift
var emptyString = "" // 空字符串字面量
var anotherEmptyString = String() // 初始化方法
emptyString.isEmpty // 判断是否为空
emptyString += "JN" // 也能这么玩
emptyString.append("!")  // 方法将一个字符附加到一个字符串变量的尾部,注意，添加的只能是一个字符
for c in emptyString.characters{ // 输出每一个字符  J N
    print(c)
}

```

```
* 每一个 String 值都有一个关联的索引(index)类型, String.Index ,它对应着字符串中的每一个 Character 的位 置。

* 通过调用 String.Index 的 predecessor() 方法,可以立即得到前面一个索引,调用 successor() 方法可以立即 得到后面一个索引。任何一个 String 的索引都可以通过锁链作用的这些方法来获取另一个索引,也可以调用 advancedBy(_:) 方法来获取。但如果尝试获取出界的字符串索引,就会抛出一个运行时错误

* 可以使用加法操作符( + )来组合两种已存在的相同类型数组 ,和字符串类似
```

** 16.构造过程 **
```
类初始化的时候，所有的存储属性必须要有初始值: 1.默认副初值 2.在构造函数中副初始值(针对指定构造函数)
```

```swift
class Person {
var name: String
var age: Int
var score: Double

    // 构造函数中，所有的参数都是局部参数，并且也是外部参数
    init(name: String ,age: Int , score: Double){
        self.name = name
        self.age = age
        self.score = score
    }

    convenience init(name: String,age: Int){
        self.init(name: name ,age:age,score:99.9)
    }

    convenience init(score: Double){
        self.init(name:"" ,age: 22,score:score)
    }
}

```

```
注意点：只要有了指定构造函数，那么系统默认给的init() 构造函数就不会生成,但是你可以自己手动添加
* 构造函数的类型： 指定构造函数， 便利构造函数(利用当前类中的其他构造函数，还遍历构造)
* 只能在指定构造函数中调用父类的指定构造函数，并且一定要调用，为了保证父类初始化完成，因为父类初始化完成才有子类的初始化
* 便利构造方法中，只能调用本类的其他构造函数，不能调用父类的构造函数，并且便利构造方法必须要以指定构造方法结尾
* 在子类的指定构造函数中，必须调用父类的指定的构造函数，如果父类的init 构造函数是无参的，那么系统会默认在子类的构造方法中，帮你调用。不需要你手动的调用

指定构造器必须调用它直接父类的指定构造器方法.
便利构造器必须调用同一个类中定义的其它初始化方法.
便利构造器在最后必须调用一个指定构造器.

在指定构造器中
1 先给自己未初始化的类型赋值
2 调用super.init(必须是指定构造器)
3 可以修改继承自父类的构造器

便利构造器  
1.调用自己的指定构造器 初始化

如果子类重写了 某个required构造器 
那么调用次required构造器的  遍历构造器  也可以被父类使用了

4 required构造器都是指定构造器
```

** 17.xib 加载**

```swift
class func headerView() -> SearchHeaderView {
    return NSBundle.mainBundle().loadNibNamed("SearchHeaderView", owner: nil, options: nil).first as! SearchHeaderView
}
```

** 18.类型 **
```
只能判断是否是自己类的实例
if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer.self){}

可以判断自己的类型，包括子类的类型
if gestureRecognizer is UIPanGestureRecognizer{}

if object === tableViewpPanGesture 是否是同一个对象

类型检查 is
类型转换 as
向下转型，从父类转换到子类 as? 或 as!
```

** 19.@IBDesignable **
```
@IBDesignable:当应用到 UIView子类中的时候，@ IBDesignable 让 Interface Builder 知道它应该在画布上直接渲染视图。你会看到你的自定义视图在每次更改后不必编译并运行你的应用程序就会显示。
```
** 20.GCD其他知识 **
```
* dispatch_barrier_async会把并行队列的运行周期分为这三个过程：

* 首先等目前追加到并行队列中所有任务都执行完成
开始执行dispatch_barrier_async中的任务，这时候即使向并行队列提交任务，也不会执行
* dispatch_barrier_async中的任务执行完成后，并行队列恢复正常。
总的来说，dispatch_barrier_async起到了“承上启下”的作用。它保证此前的任务都先于自己执行，此后的任务也迟于自己执行。正如barrier的含义一样，它起到了一个栅栏、或是分水岭的作用。
```

** 21. swift 单例**

```swift
class singletonClass {
    static let sharedInstance = singletonClass()
    private init() {} // 这就阻止其他对象使用这个类的默认的'()'初始化方法
}
```
** 22.OC + Swift 混编 **

```
Swift代码引用OC，需依靠 Objective-C bridging header 将相关文件暴露给Swift。
创建 Objective-C bridging header 有两种方法：
1、当你在Swift项目中尝试创建OC文件时，系统会自动帮你创建 Objective-C bridging header .
2. 自己创建 Objective-C bridging header
File > New > File > (iOS or OS X) > Source > Header File
切记，名字 一定要 是 项目工程名-Bridging-Header.
```

```
在oc项目中 引用swift 文件 系统会自动创建ProjectName-Swift.h 文件，但是你看不到这个文件在finder 的位置，只能点开头文件,
*  1.在工程的 Build Settings 中把 defines module 设为 YES.
*  2.把 product module name 设置为项目工程的名字。
*  3.在你的OC文件中导入 ProjectName-Swift.h.
```
** 23.RunLoop 事件处理流程 **
```
1.通知观察者即将进入runloop处理
2.如果存在即将发生的定时器事件,通知所有的观察者。
3.如果存在即将发生的非port的source事件,在事件发生前,通知所有的观察者。
4.如果存在即将发生的非port的source事件,在事件发生后,通知所有的观察者。
5.如果存在基于port的事件等待处理,立即处理转9
6.通知观察者,线程即将休眠
7.线程休眠一直等到下面任意事件之一发生:
1)基于port的事件发生
2)定时器超时
3)runloop设置的超时时间到期
4)显式的唤醒runloop
8.通知观察者,线程即将被唤醒
9.处理等待的事件
1)如果是定时器事件,执行定时器处理函数重新start runloop, 转2
2)如果是用户定义的source 执行对应的事件处理方法
3)如果runloop被显式的唤醒并且没有超时,重新start runloop, 转2

使用RunLoop监控主线程阻塞 ：利用Observer对RunLoop的状态监控,如果长时间处于工作态kCFRunLoopBeforeSources或kCFRunLoopAfterWaiting,就认为主线程被阻塞,这对于UI界面卡顿不流畅提供了一种实现思路。

```

** 24.Extension 扩展别名**
```
 为扩展写个牛逼的容易debug 的名字 private typealias TableViewDataSource = ViewController
```

** 25.tabBar tintColor **

```
这个属性能控制tabbitem 图片和文字的颜色
tabBar.tintColor = UIColor.orangeColor()

在viewWillAppear 方法里面做调整tabbar 的事情
composeButton.frame.offsetInPlace(dx: CGFloat(2) * width , dy: 0)

```

** 26.frame.offsetInPlace **
```
titleLabel?.frame.offsetInPlace(dx: -imageView!.bounds.width * CGFloat(0.5), dy: 0)
imageView?.frame.offsetInPlace(dx: titleLabel!.bounds.width * CGFloat(0.5), dy: 0)
```

** 27.swift 不允许在类方法中添加用static 修饰的变量，应该提取在外面写**
** 28.当一个控件的transform 改变的时候，那么他的frame 会改变，但是他的bounds 不会改变(scrollView做缩放的那个代理方法) **

** 29. 按钮的监听方法不能用private ，要么把private 去掉，要么加上 @objc 告诉系统，动态检测方法并且调用 **





