---
title: JVM内存结构
date: 2019-09-17 09:53:58
categories: Java虚拟机
tags:

---

### 虚拟内存与JVM内存结构
&emsp;在我们学习c语言/操作系统的时候，知道进程的内存结构有代码段，数据段[初始化数据段（初始化的全局和静态变量），未初始化数据段(又称bbs，未初始化的全局变量和静态变量)]，堆，共享库，栈，内核空间。详细了解可以搜索虚拟内存相关知识。 

![](jvm内存结构/虚拟内存结构.png)
<center>图1.虚拟内存结构</center>


 
&emsp;虚拟机的内存结构与进程的虚拟内存结构类似，那么Java虚拟机是怎么抽象它的内存结构的呢？根据Java虚拟机规范，JVM所管理的内存包含以下几个运行时区域。可以按线程隔离和共享来分类。共享的有堆、方法区，线程隔离的有PC程序计数器、虚拟机栈、本地方法栈。如下图所示：

![](jvm内存结构/JVM内存结构概览.png)
<center>图2.JVM内存结构概览</center>

### 程序计数器

&emsp;CPU的寄存器中有一个指令寄存器IP(也称为程序计数器PC),存放指令在内存中的地址。JVM内存结构中的PC可以理解为是CPU中的PC的抽象，指向的是内存中字节码指令的地址（可以简单理解为字节码指令的行号）。因为在多核CPU中，每个核跑一个线程，所以Java程序的多个线程可以同时运行，所以每个线程就需要各自的PC。如果是线程执行的是一个Java方法，那么PC记录的是指令的地址。如果是Native方法，则这个PC的值为空。

### Java虚拟机栈
&emsp;同样的Java的虚拟机栈也可以理解为虚拟内存中栈的抽象。也是线程私有的，它们功能都是一样的，存储的是方法执行的栈帧（Stack Fram）。方法的调用和返回代表的就是虚拟机栈的入栈和出栈操作。栈顶就是当前线程正在执行的方法的栈帧。栈帧中存储的就是方法执行需要的一些信息，如局部变量表、操作数栈、方法出口等。

&emsp;局部变量表存放了编译器就知道了的各种基本数据类型（boolean,byte,char,short,int,float,long,double）、对象引用、returnAddress类型（指向一条字节码指令的地址）。可以把局部变量表理解为一个数组，其中long和double占用占用2个槽位（slot）,其余的都是占用1个槽位。32位虚拟机long和double用2个槽位存储数据，即使是64位的虚拟机，long和double也是2个槽位（1个槽位存储64位数据，另一个槽位为空）。

&emsp;局部变量表的大小在编译期就确定了，在运行时是不会改变其大小的。如果是对象方法的局部变量表，第一个slot是this指针，这也是为什么每个非静态方法里可以访问this的原因，静态方法则不存在this指针。然后是方法入参，然后是方法体中的局部变量。就是这样即使是我们自己，也可以很好判断局部变量表的大小。

&emsp;在这个虚拟机栈中可能会出现两个异常：如果线程请求的栈的深度大于虚拟机所允许的深度，将抛出StackOverflowError异常；如果虚拟机栈动态扩展时申请不到足够的内存，就会抛出OutOfMemoryError异常。可以通过下方的代码进行测试

```java

	/**
	 * VM args: -Xss128k
	 *
	 */
	public class JavaVMStackSOF {
	
	    private int stackLength;
	
	    public void stackLeak() {
	        stackLength ++ ;
	        stackLeak();
	    }
	
	    public static void main(String[] args){
	        JavaVMStackSOF javaVMStackSOF = new JavaVMStackSOF();
	        try {
	            javaVMStackSOF.stackLeak();
	        } catch (Throwable e) {
	            System.out.println("stack length:"+javaVMStackSOF.stackLength);
	            throw e;
	        }
	    }
	}

```

&emsp;扩展，当后面学习了class文件，字节码指令后，可以使用命令javap -v -p classfile反解析出字节码,查看局部变量表的大小，以及每个槽位存储的是什么。如下代码所示：

```java  

	public static void staticMethod(String str){
	        System.out.println("static method "+str);
	    }
	
	public int virtualMethod(String word, Integer i){
	        System.out.println(word);
	        return i;
	    }
```

对应的字节码: 

```java

	public int virtualMethod(java.lang.String, java.lang.Integer);
	    descriptor: (Ljava/lang/String;Ljava/lang/Integer;)I
	    flags: ACC_PUBLIC
	    Code:
	      stack=2, locals=3, args_size=3
	         0: getstatic     #11                 // Field java/lang/System.out:Ljava/io/PrintStream;
	         3: aload_1
	         4: invokevirtual #13                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
	         7: aload_2
	         8: invokevirtual #16                 // Method java/lang/Integer.intValue:()I
	        11: ireturn
	      LineNumberTable:
	        line 29: 0
	        line 30: 7
	      LocalVariableTable:
	        Start  Length  Slot  Name   Signature
	            0      12     0  this   Lpractice/bytecode/BytecodeCommand;
	            0      12     1  word   Ljava/lang/String;
	            0      12     2     i   Ljava/lang/Integer;
	
	public static void staticMethod(java.lang.String);
	    descriptor: (Ljava/lang/String;)V
	    flags: ACC_PUBLIC, ACC_STATIC
	    Code:
	      stack=2, locals=1, args_size=1
	         0: getstatic     #11                 // Field java/lang/System.out:Ljava/io/PrintStream;
	         3: aload_0
	         4: invokevirtual #13                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
	         7: return
	      LineNumberTable:
	        line 41: 0
	        line 42: 7
	      LocalVariableTable:
	        Start  Length  Slot  Name   Signature
	            0       8     0   str   Ljava/lang/String;
```

### 本地方法栈
&emsp;这个栈与虚拟机栈结构类似，是Native方法执行时的栈帧。不同的虚拟机有不同的实现，但是Hotspot虚拟机是将两者合二为一的。

### Java堆
&emsp;在C中，堆是动态内存区域，由malloc()函数分配内存，Hotspot虚拟机是由C++实现的，那么内存分配可能是由new操作符。具体的可能要看虚拟机源码才能清楚，总之，先不管是由什么实现，先理解Java虚拟机的中的堆。Java堆可以说是虚拟机中最大的一块内存了，它的唯一目的就是存放实例对象的数据，通过new出的对象和数组一般都是放到堆中的。随着JIT编译器的发展和逃逸分析技术的成熟，**栈上分配、标量替换**优化技术使得不再完全是堆上分配。

&emsp;Java堆是垃圾收集器管理的主要区域，这里有大量对象朝生夕死，也有老顽固存活下来。垃圾收集器现在基本上是**分代收集算法**，所以垃圾收集器把Java堆分为 年轻代{eden区、survivor区[survivor from(s0)、survicor to(s1)]}、老年代，可见上图内存结构总览。从内存分配角度来看，为了解决并发分配对象的效率，线程共享的堆中又各自有各自的**TLAB分配缓冲区**（Thread Local Allocation Buffer）使用-XX:+/-UseTLAB开启关闭（默认开启）。

&emsp;Java堆内存大小由Xms初始大小（memory start）,Xmx最大内存(memory max)这两个参数控制。形成可扩展的堆内存。如果申请内存时不能再扩展了，就会抛出OutOfMemoryError异常。

![](jvm内存结构/堆内存分代结构.jpg)
<center>图3.堆内存分代结构</center>

### 方法区
&emsp;从名字就可以看出来，这个区域主要是存储方法的。class文件的字节码经过类加载后就进入了方法区变成class对象，所以方法区存储的是类的信息（方法、常量池、静态属性）、即时编译器JIT编译后的代码等数据。GC垃圾收集器在1.7及以前把该区域叫做永久代（和堆是逻辑上连续的），1.8后叫做元空间metaspace，使用Native Memory来分配空间，这样元空间的大小就由32/64位系统的虚拟内存可用大小决定，但也可用MaxMetaspaceSize参数限制。元空间是Hotspot对方法区的具体实现。并且JDK1.7及以后把在永久代的字符串常量池移到堆内存中了。

### 运行时常量池
&emsp;Class文件除了类的版本、字段、方法、接口等信息外，还有一项信息是常量池（Constants Pool Table），用于存放编译期生成的各种**字面量和符号引用**，这部分内容将在类加载后进入方法区每个类的运行时常量池，当然也会把翻译出的直接引用存储在运行时常量池中。

&emsp;扩展：比较了解 class文件常量池，运行时常量池，字符串常量池 与类加载过程的关系（待总结）

### 直接内存
&emsp;直接内存并不是虚拟机运行时数据区的一部分，也不是Java虚拟机规范中定义的内存区域。但是这部分内存也被频繁的使用，而且也可能导致OOM异常出现。
在JDK1.4中新加入的NIO(New Input/Output)类，引入了一种基于通道channel的与缓冲区buffer的I/O方式，它可以使用Native函数库直接分配堆外内存，然后通过一个存储在Java堆中的DirectByteBuffer对象作为这块内存的引用进行操作。这样显著提升了性能，因为避免了在堆内存和Native堆中来回复制数据。

&emsp;虽然直接内存的分配不会收到Java堆的大小限制，但是会收到本机总物理内存或虚拟内存地址空间大小限制。如果配置Xmx时忽略了这部分直接内存，导致运行时加起来超过了限制，动态扩展时就会出现OOM异常。

