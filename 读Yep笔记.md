#Yep

##### debugPrint

```
func println(@autoclosure item: () -> Any) {
    #if DEBUG
        Swift.print(item())
    #endif
}

```


##### 通知

```
// 创建一个全局的结构体，将通知写在统一的地方，方便维护
  struct Notification {
        static let applicationDidBecomeActive = "applicationDidBecomeActive"
    }
    
NSNotificationCenter.defaultCenter().postNotificationName(Notification.applicationDidBecomeActive, object: nil)
```

##### YepConfig (全局性的配置文件，可以替代pch 来用。因为swift 中没有宏可以用了)
全局性的配置，里面有一些一些头像 按钮旷告尺寸，通用的url，全局性的通知结构体， 常用的颜色自己 全局性的类方法返回通用的参数 （里面不同模块不同种类的参数都不是大杂烩的写在一起的，而是用各个不同的结构体包装起来的）

##### YepHelp 用于写一些通用的extension。为例如UIImage 添加分类方法等

```
隐藏导航栏下面的黑线

   private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
       if let view = view as? UIImageView where view.bounds.height <= 1.0 {
           return view
       }

       for subview in view.subviews {
           if let imageView = hairlineImageViewInNavigationBar(subview) {
               return imageView
           }
       }

       return nil
   }
    
  func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView?.hidden = true
    }
```

#####SafeDispatch

```

public class SafeDispatch {

    private let mainQueueKey = UnsafeMutablePointer<Void>.alloc(1)
    private let mainQueueValue = UnsafeMutablePointer<Void>.alloc(1)

    private static let sharedSafeDispatch = SafeDispatch()

    private init() {
        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, mainQueueValue, nil)
    }

    public class func async(onQueue queue: dispatch_queue_t = dispatch_get_main_queue(), forWork block: dispatch_block_t) {
        if queue === dispatch_get_main_queue() {
            if dispatch_get_specific(sharedSafeDispatch.mainQueueKey) == sharedSafeDispatch.mainQueueValue {
                block()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    block()
                }
            }
        } else {
            dispatch_async(queue) {
                block()
            }
        }
    }
}

```

##### 一些陌生api 
```
 NSUUID().UUIDString
 let progress = NSProgress()
 ```

