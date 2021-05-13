//
//  CrashManager.swift
//
//  Created by jiaohaitao on 2021/5/12.
//
//  功能入口类

import UIKit

#if os(iOS)

//此系统设计目的：方便测试过程中发现和定位Crash,不要在对外发布的版本中使用(建议采用条件编译)
//调试时，XCode调试器会拦截异常，此系统功能是不工作的
public final class CrashManager{
    public static let instance = CrashManager()
    
    //调用栈上很多系统内部的方法，显示时可以隐藏掉，方便查看
    private let ignoreKeywords = ["libdispatch.dylib","libsystem_platform.dylib","UIKitCore","libswiftUIKit.dylib","libdyld.dylib","libsystem_pthread.dylib","libswiftCore.dylib","libswiftCore.dylib","GraphicsServices"]
        
    
    public func installUncaughtExceptionHandler()
    {
        NSSetUncaughtExceptionHandler { e in
            print("UncaughtException: " + e.description)
            CrashManager.instance.showCrashStack()
        }
        signal(SIGABRT) { n in
            print("signal: " + "SIGABRT")
            CrashManager.instance.showCrashStack()
        }
        signal(SIGILL) { n in
            print("signal: " + "SIGILL");
            CrashManager.instance.showCrashStack()
        }
        signal(SIGSEGV) { n in
            print("signal: " + "SIGSEGV");
            CrashManager.instance.showCrashStack()
        }
        signal(SIGFPE) { n in
            print("signal: " + "SIGFPE");
            CrashManager.instance.showCrashStack()
        }
        signal(SIGBUS) { n in
            print("signal: " + "SIGBUS");
            CrashManager.instance.showCrashStack()
        }
        signal(SIGPIPE) { n in
            print("signal: " + "SIGPIPE");
            CrashManager.instance.showCrashStack()
        }
    }
    
    //捕获Crash后，调用此方法显示栈信息，此后App原功能不应该继续使用
    //简单场景下，调用栈可方便定位，但如果多线程时，最终Crash的线程的调用栈信息可能不全
    //多线程场景下，请参考：Crash-extensions.swift => extension DispatchQueue,
    private func showCrashStack() {
        var crashStack = ["\n\n***CRASH*** :"]
        
        let threadName = (Thread.current.isMainThread) ? ("Main") : ("Not Main:" + Thread.current.name!)
        crashStack.append(threadName)
        
        crashStack.append(contentsOf: Thread.callStackSymbols)

        if let parentStack = Thread.current.parentCallStack {
            crashStack.append(contentsOf: parentStack)
        }
        
        print(crashStack.joined(separator: "\n"))

        crashStack = self.filterStack(crashStack)
        if Thread.current.isMainThread{
            UIApplication.shared.windows[0].rootViewController = CrashViewController(crashStack:crashStack)
            RunLoop.current.run()
        }else{
            print("not main");
            DispatchQueue.main.sync {
                UIApplication.shared.windows[0].rootViewController = CrashViewController(crashStack:crashStack)
                RunLoop.current.run()
            }
        }
        
    }
    
    //过滤掉栈里无效的行
    private func filterStack(_ crashStack:[String]) -> [String]{
        var r = [String]()
        for line in crashStack{
            var b = false
            for ignore in self.ignoreKeywords{
                if line.contains(ignore){
                    b = true
                    break
                }
            }
            if b{
                r.append("----")
            }else{
                r.append(line)
            }
        }
        return r
    }
}

#endif
