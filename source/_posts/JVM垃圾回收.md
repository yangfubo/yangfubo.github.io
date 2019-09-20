---
title: JVM垃圾回收
comment: false
date: 2019-09-20 11:29:54
categories: Java虚拟机
tags: JVM垃圾回收
---

&emps;垃圾收集是C++与Java的一大不同点，C++中需要手动释放内存，编写析构函数。而JVM则由后台垃圾收集线程帮我们处理垃圾对象，减少了开发人员写代码忘记编写析构，或错误析构的可能。在JVM内存结构中已经大致了解过heap堆的分代。现在的垃圾收集器基本都采用分代收集算法。因为某论文中证明大多数对象是朝生夕死的，分代算法提高垃圾收集的效率。

### 标记垃圾对象

#### 引用计数法

#### GCRoots

### Stop-The-World

#### 安全点

#### 安全区

### 垃圾收集算法

#### 标记-清除

#### 复制

#### 标记-整理

#### 分代收集算法

### 垃圾收集器

Serial 新生代，单线程

Serial Old 老年代，单线程

ParNew serial多线程版本

Parallel Old 老年代多线程版本

Parallel Scavenge（新生代、多线程并行、控制吞吐量、自适应分区比例）

CMS(Concurrent Mark Sweep、老年代、多线程、并发)

G1（Garbage-First）

### 内存分配与回收策略

### GC日志
