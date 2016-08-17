### SwiftGG - 入门

##### 理解flatmap

```
let nestedArray = [[1,2,3], [4,5,6]]
// 写法1 
let multipliedFlattenedArray = nestedArray.flatMap { $0.map { $0 * 2 } }
// 写法2 ：这种更容易理解$0 代表的不是一个东西
let multipliedFlattenedArray = nestedArray.flatMap { array in
    array.map { element in
        element * 2 }
}
multipliedFlattenedArray // [2, 4, 6, 8, 10, 12]
```

**flatmap + 可选类型 **

```
let optionalInts: [Int?] = [1, 2, nil, 4, nil, 5]

let ints = optionalInts.flatMap { $0 }
ints // [1, 2, 4, 5] - this is an [Int]
```

* flatMap基本就是一个map，但是删除了nil值。换句话说，它会返回 [T]，而不是 [T?]。

#####为什么guard 比 if 好 ?

**使用 guard 会强迫你编写 happy-path，如果出错会提前退出，从而必须处理可能发生的错误**

鞭尸金字塔问题。有错误那么提前退出，越往后面越是完备的。

```
func createPerson() throws -> Person {
    guard let age = age, let name = name
        where name.characters.count > 0 && age.characters.count > 0
        else {
            throw InputError.InputMissing
    }

    guard let ageFormatted = Int(age) else {
        throw InputError.AgeIncorrect
    }

    return Person(name: name, age: ageFormatted)
}
```

##### Swift 中的结构体与 NSCoding

**Swift 中的结构体不遵守 NSCoding 协议。NSCoding 只适用于继承自 NSObject 的类。 可是结构体在 Swift 中的地位与使用频率都非常高，因此，我们需要一个能将结构体的实例归档和解档的方法**

```
struct Person {
  let firstName: String
  let lastName: String
  // 类型方法。存档
  static func encode(person: Person) {
    let personClassObject = HelperClass(person: person)
    
        NSKeyedArchiver.archiveRootObject(personClassObject, toFile: HelperClass.path())
  }
  
  // 类型方法。解档
  static func decode() -> Person? {
    let personClassObject = NSKeyedUnarchiver.unarchiveObjectWithFile(HelperClass.path()) as? HelperClass

    return personClassObject?.person
  }
}


extension Person {
  class HelperClass: NSObject, NSCoding {
    
    var person: Person?
    
    init(person: Person) {
      self.person = person
      super.init()
    }
    
    class func path() -> String {
      let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
      let path = documentsPath?.stringByAppendingString("/Person")
      return path!
    }
    
    required init?(coder aDecoder: NSCoder) {
      guard let firstName = aDecoder.decodeObjectForKey("firstName") as? String else { person = nil; super.init(); return nil }
      guard let lastName = aDecoder.decodeObjectForKey("lastName") as? String else { person = nil; super.init(); return nil }
      
      person = Person(firstName: firstName, lastName: lastName)
      
      super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
      aCoder.encodeObject(person!.firstName, forKey: "firstName")
      aCoder.encodeObject(person!.lastName, forKey: "lastName")
    }
  }
}

```

* 给结构体包一层，因为只能是NSObject 遵循NSCoding 协议，那么给他包一个中间类。


######Swift:什么时候不适合使用函数式方法

```
var minionImages = [UIImage]()
for i in 1...7 {
    if let minionImage = UIImage(named: "minionIcon-\(i)") {
        minionImages.append(minionImage)
    }
}

let minionImagesMapped = (1...7)
    .map { UIImage(named: "minionIcon-\($0)") }
```

##### map与flatmap
* map函数能够被数组调用，它接受一个闭包作为参数，作用于数组中的每个元素。闭包返回一个变换后的元素，接着将所有这些变换后的元素组成一个新的数组

```
let anotherArray = testArray.map { (string:String) -> Int? in
     let length = string.characters.count
     guard length > 0 else { return nil }
     return string.characters.count
}

print(anotherArray) //[Optional(5), Optional(8), nil, Optional(6)]
```

* flatMap很像map函数，但是它摒弃了那些值为nil的元素。

```
let anotherArray2 = testArray.flatMap { (string:String) -> Int? in
     let length = string.characters.count
     guard length > 0 else {
          return nil
     }
     return string.characters.count
}
print(anotherArray2) //[5, 8, 6]
```

#####Swift2.0中使用 try？ 关键字

**try?会试图执行一个可能会抛出异常的操作。如果成功抛出异常，执行的结果就会包裹在可选值(optional)里；如果抛出异常失败(比如：已经在处理 error)，那么执行的结果就是nil，而且没有 error。try?配合if let和guard一起使用效果更佳**

```
func produceGizmoUsingMagic() throws -> Gizmo {...}

if let result = try? produceGizmoUsingMagic() {return result}

```

#####Swift中最棒的特性
* 函数指针
* 协议扩展
* 错误处理(同步：异常处理机制 异步：泛型枚举)
* guard语句

```
guard condition else {
    // false branch
}
// true branch
```
* defer 语句

// 协议扩展难理解的地方

```
protocol P {
    func a()
}

extension P {
    func a() {
        print("default implementation of A")
    }

    func b() {
        print("default implementation of B")
    }
}

struct S: P {
    func a() {
        print("specialized implementation of A")
    }

    func b() {
        print("specialized implementation of B")
    }
}

let p: P = S()
p.a()
p.b()

```
*打印结果是”specialized implementation of A”后面跟着”default implementation of B.”。虽然Struct包含了b的实现，但是它没有能够覆盖协议的b方法，因为协议没有包含方法b的声明。本质区别在于，协议中声明的方法是有默认实现的，而协议扩展中的方法实现是依附于协议的。*

**协议扩展中实现的方法可能在协议本身中声明，也可能只存在于协议扩展中。只存在于协议扩展中的方法不能被动态调度且不能被重载。而同时也在协议本身中声明的方法可以被动态调度且可以被重载**

#####Swift 小贴士: 优雅地设置 IBOutlets

```
class ViewController: UIViewController {

    @IBOutlet weak var myLabel: UILabel! {
        didSet {
            myLabel.textColor = UIColor.purpleColor()
        }
    }
}
```

#####如何在 Swift 中优雅地使用 UIImage


```
extension UIImage {
    enum AssetIdentifier: String {
        // Image Names of Minions
        case Bob, Dave, Jorge, Jerry, Tim, Kevin, Mark, Phil, Stuart
    }
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}

let minionBobImage = UIImage(assetIdentifier: .Bob)
```

#####Swift2  try?抛出可选异常
** try? ,它在代码执行失败时会抛出错误并返回可选值 None,而在执行成功的情况下，会直接返回可选值 Some。**

##### 浅谈泛型

*参照泛型的特性，我们能够定义一个泛型类型，这看起来像一个占位符*
```
class Stack<T> {

  private var stackItems: [T] = []  

  func pushItem(item:T) {
    stackItems.append(item)
  }  
  
  func popItem() -> T? {
    let lastItem = stackItems.last
    stackItems.removeLast()
    return lastItem
  }

}
```

**泛型定义方式:由一对尖括号(<>)包裹，命名方式通常为大写字母开头(这里我们命名为T)。在初始化阶段，我们通过明确的类型(这里为Int)来定义参数,之后编译器将所有的泛型T替换成Int类型**

```
// 指定了泛型T 就是 Int 
// 编译器会替换所有T为Int
let aStack = Stack<Int>()

aStack.pushItem(10)
if let lastItem = aStack.popItem() {
  print("last item: \(lastItem)")
}
```

#####API可用性

```
// 方法1
// respondsToSelector用来判断是否有以某个名字命名的方法(被封装在一个selector的对象里传递)
// 只有iOS 9 才有forceTouchCapability方法。
if traitCollection.respondsToSelector(Selector("forceTouchCapability")) {
	 // 检查ForceTouch是否可用 倘若可用 进行配置
     if (traitCollection.forceTouchCapability == UIForceTouchCapability.Available) {
          //配置 Force touch
     }
}

// 方法2
// 判断是否在iOS9能够正常工作
if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)) {
	// 判断force touch 是否可用
     if (traitCollection.forceTouchCapability == UIForceTouchCapability.Available) {
          //配置 Force touch
     }
}


// 检查当前设备系统是否在iOS 9下可用
if #available(iOS 9.0,*){
	// 可用情况下 才执行如下代码
	if (traitCollection.forceTouchCapability == UIForceTouchCapability.Available) {
       //configure force touch
     } 
	}else {
     // Fallback on earlier versions
 }
 
 
//当然我们还可对类和方法执行可用性检查。在这种情况下，必须使用@available
@available(iOS 9.0, *)
     func configureForceTouch() {
          if (traitCollection.forceTouchCapability == UIForceTouchCapability.Available) {
               //configure force touch
           }    
     }
}
```

#####3Dtouch
** 3Dtouch ：重按 **

* 电子秤

```
override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {        
    if let touch = touches.first {
    // 只有iOS 9 才有3d touch
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == UIForceTouchCapability.Available {
                if touch.force >= touch.maximumPossibleForce {
                    forceLabel.text = "385+ grams"
                } else {
                // 按压百分比 
                    let force = touch.force/touch.maximumPossibleForce // 能承受的最大压力值
                    let grams = force * 385
                    let roundGrams = Int(grams)
                    forceLabel.text = "\(roundGrams) grams"
                }
            }
        }
    }
}
```

* 主屏幕的快捷操作


1.首先配置plist

```
添加UIApplicationShortcutItems数组。数组中的元素是包含一个快捷操作配置的字典：
UIApplicationShortcutItemType(必填)：快捷操作的唯一标识符（String 类型）。建议将 bundle ID 或者其他唯一字符串作为标识符前缀。

UIApplicationShortcutItemTitle（必填）：相当于快捷操作的 title（String 类型），用户可以看到。例如“显示最近一张照片”之类的文本。

UIApplicationShortcutItemSubtitle（可选）：快捷操作的副标题（String 类型）。例如“昨天拍摄的照片”。如果你想要给快捷操作添加一个 icon，可以自定义，也可以使用系统自带的。

UIApplicationShortcutItemIconType（可选）：表示你要选择哪种系统图标作为快捷操作的 icon（String 类型）。
UIApplicationShortcutItemIconFile（可选）：表示给快捷操作添加自定义 icon（String 类型）。

UIApplicationShortcutItemUserInfo（可选）：在快捷操作交互时传递的额外信息（译者注：类似于通知的 UserInfo 参数）（Dictionary 类型）。
```

2.实现用户触发快捷操作的处理流程。快捷方式需要在AppDelegate.swift的performActionForShortcutItem方法中处理。当使用快捷操作启动时，这个方法会被调用。所以，实现这个方法，并在方法中处理快捷操作：

```
func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
    // Handle quick actions  completionHandler(handleQuickAction(shortcutItem))
}

enum Shortcut: String {
    case openBlue = "OpenBlue"
}
func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
    var quickActionHandled = false
    let type = shortcutItem.type.componentsSeparatedByString(".").last!
    if let shortcutType = Shortcut.init(rawValue: type) {
        switch shortcutType {
        case .openBlue:
            self.window?.backgroundColor = UIColor(red: 151.0/255.0, green: 187.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            quickActionHandled = true
        }
    }
    return quickActionHandled
}
```

3. didFinish 方法拦截判断

```
 // Check if it's launched from Quick Action
    if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {

        isLaunchedFromQuickAction = true
        // Handle the sortcutItem
        handleQuickAction(shortcutItem)
    } else {
        self.window?.backgroundColor = UIColor.whiteColor()
    }
```

通过判断可选值的UIApplicationLaunchOptionsShortcutItemKey得到用户是否是通过快捷操作启动。UIApplicationShortcutItem可以作为可选值的类型。如果程序是通过快捷操作启动的，我们可以直接调用handleQuickAction方法将背景色改为蓝色。

因为我们已经在didFinishLaunchingWithOption方法中调用了handleQuickAction，所以没必要再在performActionForShortcutItem方法中调用一次。所以最后我们返回了一个false，告诉系统不要再去调用performActionForShortcutItem方法


####数组函数式 闭包
**map**

map用于将每个数组元素通过某个方法进行转换返回新的数组。

[ x1, x2, ... , xn].map(f) ->[f(x1), f(x2), ... , f(xn)]

**@noescape：表示transform这个闭包是非逃逸闭包，它只能在当前函数map中执行，不能脱离当前函数执行。这使得编译器可以明确的知道运行时的上下文环境（因此，在非逃逸闭包中可以不用写self），进而进行一些优化。**

* 对 Optionals进行map操作 如果这个可选值有值，那就解包，调用这个函数，之后返回一个可选值，需要注意的是，返回的可选值类型可以与原可选值类型不一致

* 我们可以使用map方法遍历数组中的所有元素，并对这些元素一一进行一样的操作（函数方法）。map方法返回完成操作后的数组。


**filter**

filter用于选择数组元素中满足某种条件的元素。并且返回这些元素组成的新数组

**Reduce**

reduce方法把数组元素组合计算为一个值(聚合)

**FlatMap**

* 对于可选值， flatMap 对于输入一个可选值时应用闭包返回一个可选值，之后这个结果会被压平，也就是返回一个解包后的结果。本质上，相比 map,flatMap也就是在可选值层做了一个解包。

* 压平

```
var values = [[1,3,5,7],[9]]
let flattenResult = values.flatMap{ $0 }
/// [1, 3, 5, 7, 9]
```

* 空值过滤

```
var values:[Int?] = [1,3,5,7,9,nil]
let flattenResult = values.flatMap{ $0 }
/// [1, 3, 5, 7, 9]
```

#####横竖屏
**plist 配置需要的横竖屏方向**

**实现方法**

```
override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
  return UIInterfaceOrientationMask.Portrait
}
```

#####响应者链条
**当用户点击了视图层级（view hierarchy）中的一个 view 时，iOS 会通过点击测试（hit test）来判定哪个响应者对象优先响应触摸事件。这个过程从最底层的 window 开始，沿着视图层级向上寻找并检查这个 touch 是不是发生在当前 view 边界内。该过程中被点击的最后一个 view 会先收到触摸事件。如果该 view 没有对触摸事件做出反应，触摸事件就会沿着响应链传递到下一个响应者。如果 view 告诉 iOS 它没有被点击，那它的子视图就不会被检查。**

**Target-Action 机制通过设置 target 为 nil来使用响应链。事件触发时，iOS 会询问第一响应者是否要处理传递过来的 action。如果不处理的话，第一响应者就会把该 action 传递给下一个响应者**

#####带有私有设置方法的公有属性
**Swift 可以很方便地创建带有私有设置方法的公有属性。这可以让你的代码更加安全和简洁。

* private(set) var area: Double = 0 ,通过在属性前面使用 private(set) ，属性就被设置为默认访问等级的 getter 方法，但是 setter 方法是私有的 

##### Contacts framework （联系人框架)
**联系人数据的主要来源是设备内置的数据库。然而，新的联系人框架不仅可以检索这个数据库，实际上，它还可以对别的来源进行数据的检索，比如通过你的 iCloud 账户（当然是在你已经连接了 iCloud 账户的情况下），并且返回检索到的联系人结果。这是非常有用的，因为你不需要单独再进行某个来源的检索，你一次就能够检索所有数据，并且可以随意管理。**

** 新的联系人框架包括了许多不同功能的类，所有类都非常重要，但其中使用最多的一个是 CNContactStore，它代表联系人数据库，并且提供了大量的操作方法，比如查询、保存、更新联系人记录、授权检查、授权请求等。 CNContact 表示一条联系人记录，并且它的内部属性都是不可变的，如果你想要创建或者更新一条已经存在的联系人记录，你应该使用它的可变版本 **

**CNMutableContact。值得注意的是，当你使用联系人框架时，尤其是进行联系人查找时，你应该总是在后台执行。如果一条联系人记录的查找花费较长的时间并且在主线程执行的话，你的应用会无法响应，这会使应用的用户体验非常糟糕。**

**当导入联系人数据到应用中时，几乎不需要导入所有的联系人属性。在所有联系人框架允许的搜索范围中检索所有已存在的联系人数据，是一个非常费资源的操作，你应该尽量避免这样去做，除非你确定你真的需要使用所有的联系人数据。可喜的是，新联系人框架提供了仅检索部分结果的方式，即检索一个联系人的部分属性。比如说，你可以只查找联系人的姓、名、家庭邮件地址和家庭电话号码，而撇开所有那些你不需要的数据。**

**文章链接** <http://swift.gg/2016/01/12/ios-contacts-framework/>

##### 推送证书配置
文章链接<http://swift.gg/2016/03/15/push-notification-ios/>


######断言
assert(x >= 0, "x 不能为负数")


#####“错误"的用Extension
**为了一眼就看出一个 Swift 类的公开方法（可以被外部访问的方法），我把内部实现都写在一个私有的 extension 中,分割代码块。组织代码较好用**

```
// 这样可以一眼看出来，这个结构体中，那些部分可以被外部调用

// 把所有内部逻辑和外部访问的 API 区隔开来
// MARK: 私有的属性和方法
private extension TodoItemViewModel {

    func appendAvatar(ofUser user: User, toText text: NSMutableAttributedString) {
        if let avatarImage = user.avatar {
            appendImage(avatarImage, toText: text)
        } else {
            appendDefaultAvatar(ofUser: user, toText: text)
            downloadAvatarImage(forResource: user.avatarResource)
        }
    }
    
}
```

#####Swift 化的CG

```
let rect  = CGRect(x: 0, y: 0, width: 100, height: 100) 
let rect  = CGRect.zero
let height = frame.height
let maxX   = frame.maxX

//现在，你不仅可以直接修改 frame 中某一个变量的值，并且你也可以直接对 frame 包含的 origin 与 size 结构体重新赋值
view.frame.origin.x += 10
view.frame.origin = CGPoint(x: 10, y: 10)
```


##Swift GG 进阶

##### 值类型嵌套引用类型

```
class Inner {
    var value = 42
}

struct Outer {
    var value = 42
    var inner = Inner()
}

var outer = Outer()
var outer2 = outer
outer.value = 43
outer.inner.value = 43
print("outer2.value=\(outer2.value) outer2.inner.value=\(outer2.inner.value)”)

// outer2.value=42 outer2.inner.value=43
```
**尽管outer2获取了value的一份拷贝，它只拷贝了inner的引用，因此两个结构体就共用了同一个inner对象。这样一来当改变outer.inner.value的值也会影响outer2.inner.value的值**

**你创建的结构体就具有写时拷贝功能（只有当你执行outer2.value = 43时才会真正的产生一个副本，否则outer2与outer仍指向共同的资源），这种高效的值语义的实现不会使数据拷贝得到处都是。Swift 中的集合就是这么做的**


#####序列的实现方式
**任何遵循 SequenceType 协议的类型，都可以用 for...in 的方式访问，并且同时获得像 map，flatMap，reduce等等很酷的方法。要遵循 SequenceType 协议，只有一个要求：实现 generate() 方法，该方法要求返回值遵循 GeneratorType 协议**

**Generator 是代表循环的有状态的对象。Generator 必须提供一个 next() 方法——该方法返回一个可选值**

```
public protocol SequenceType {
    typealias Generator : GeneratorType
    typealias SubSequence
    public func generate() -> Self.Generator
    public func underestimateCount() -> Int
    public func map<T>(@noescape transform: (Self.Generator.Element) -> T) -> [T]
    public func filter(@noescape includeElement: (Self.Generator.Element) -> Bool) -> [Self.Generator.Element]
    public func forEach(@noescape body: (Self.Generator.Element) -> ())
    public func dropFirst(n: Int) -> Self.SubSequence
    public func dropLast(n: Int) -> Self.SubSequence
    public func prefix(maxLength: Int) -> Self.SubSequence
    public func suffix(maxLength: Int) -> Self.SubSequence
    public func split(maxSplit: Int, allowEmptySlices: Bool, @noescape isSeparator: (Self.Generator.Element) -> Bool) -> [Self.SubSequence]
}
```

```
public protocol CollectionType : Indexable, SequenceType {
    typealias Generator : GeneratorType = IndexingGenerator<Self>
    public func generate() -> Self.Generator
    typealias SubSequence : Indexable, SequenceType = Slice<Self>
    public subscript (position: Self.Index) -> Self.Generator.Element { get }
    public subscript (bounds: Range<Self.Index>) -> Self.SubSequence { get }
    public func prefixUpTo(end: Self.Index) -> Self.SubSequence
    public func suffixFrom(start: Self.Index) -> Self.SubSequence
    public func prefixThrough(position: Self.Index) -> Self.SubSequence
    public var isEmpty: Bool { get }
    public var count: Self.Index.Distance { get }
    public var first: Self.Generator.Element? { get }
}
```

```
public protocol RangeReplaceableCollectionType : CollectionType {
    public init()
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Self.Index>, with newElements: C)
    public mutating func reserveCapacity(n: Self.Index.Distance)
    public mutating func append(x: Self.Generator.Element)
    public mutating func extend<S : SequenceType where S.Generator.Element == Generator.Element>(newElements: S)
    public mutating func insert(newElement: Self.Generator.Element, atIndex i: Self.Index)
    public mutating func splice<S : CollectionType where S.Generator.Element == Generator.Element>(newElements: S, atIndex i: Self.Index)
    public mutating func removeAtIndex(i: Self.Index) -> Self.Generator.Element
    public mutating func removeFirst() -> Self.Generator.Element
    public mutating func removeFirst(n: Int)
    public mutating func removeRange(subRange: Range<Self.Index>)  
    public mutating func removeAll(keepCapacity keepCapacity: Bool)
}
```

##### 实现序列和生成器<http://swift.gg/2015/09/11/sequencetype_and_generatortype/>

##### try？
**try？ 语法的优点在于你不必把可能会抛出错误的函数写在一个 do-catch 代码块当中。如果你使用了 try?，该函数的返回值就会是一个可选类型：成功返回 .Some，失败则返回 .None。你可以配合着 if-let 或者 guard 语句来使用 try? 语法。**