//
//
//  Created by jiaohaitao on 2021/5/12.
//
//  扩展的辅助功能

import Foundation



//为Thread增加关联对象，
//此关联对象存储了父线程的调用栈
//例如：线程A、B、C   主线程->A -> B -> C
//A的关联对象存储[主线程启动A时的栈]
//B的关联对象存储[主线程启动A时的栈] + [A启动B时的栈]
//C的关联对象存储[主线程启动A时的栈] + [A启动B时的栈] + [B启动C时的栈]
//注：此功能需要对创建线程的代码进行一些修改,封装新方法，或者swizzle方式
//此处的DispatchQueue.async_ex简单，但对代码具有侵入性，仅供参考
//当然，线程名称也可方便定位，此处未做处理
extension Thread {
    static var KEY_parentCallStack = "KEY_parentCallStack"

    var parentCallStack: [String]? {
        get {
            return objc_getAssociatedObject(self, &Thread.KEY_parentCallStack) as? [String]
        }
        set {
            objc_setAssociatedObject(self, &Thread.KEY_parentCallStack, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension DispatchQueue {
    func async_ex(_ work: @escaping @convention(block) () -> Void){
        var curStack = [
            "------------------------------------------------",
            "Parent GCD stack: "
        ]
        curStack.append(contentsOf: Thread.callStackSymbols)
        if let parentCallStack = Thread.current.parentCallStack {
            curStack.append(contentsOf: parentCallStack)
        }
        
        self.async {
            Thread.current.parentCallStack = curStack
            work();
        }
    }
}

extension Thread {
    
    func start_ex(){
        var curStack = [
            "------------------------------------------------",
            "Parent Thread stack: "
        ]
        curStack.append(contentsOf: Thread.callStackSymbols)
        if let parentCallStack = Thread.current.parentCallStack {
            curStack.append(contentsOf: parentCallStack)
        }
        self.parentCallStack = curStack
        self.start()
    }
}

extension Operation {
    
    func start_ex(){
        var curStack = [
            "------------------------------------------------",
            "Parent Operation stack: "
        ]
        curStack.append(contentsOf: Thread.callStackSymbols)
        if let parentCallStack = Thread.current.parentCallStack {
            curStack.append(contentsOf: parentCallStack)
        }
        self.parentCallStack = curStack
        self.start()
    }
}

