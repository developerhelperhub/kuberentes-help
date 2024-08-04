# ADR-MCS-00004

## Requirement

Microservices should scale rapidly and use resources efficiently.

Version: 1.0.0

----------
## Design Consideration 1
****- We need to compile source code AOT (Ahead of Time) compilation, it helps to increase the startup time and utilise the memory efficiently
- AOT compilation occurs before runtime, meaning the code is compiled into a native executable or intermediate form during the build process.
- Can result in faster startup times since the code is already compiled before execution.
- Generally, AOT compiled applications use less memory at runtime because there is no need for the JIT compiler or runtime data structures.
- Example GraalVM Native Image, Angular AOT compiler, Xamarin.
----------
## Design Consideration 2 
- Application needs to run in the container, it helps us to start application very quickly compare to VM
- Containers are lightweight and use fewer resources compared to virtual machines (VMs) because they share the host OS kernel.
- Containers can start and stop much faster than VMs, enabling quicker scaling and deployment.
- Containers are ideal for microservices, allowing developers to break down applications into smaller, manageable services that can be developed, deployed, and scaled independently.
- Containers provide an additional layer of isolation between applications, improving security by limiting the impact of vulnerabilities and breaches.
- By running multiple containers on a single host OS, organizations can optimize resource usage and reduce infrastructure costs.
- Reduced need for large, monolithic servers and the ability to run workloads on smaller, more cost-effective instances.
----------
## Design Consideration 3
- Compress the execute binary to reduce the size of the binary
- UPX compression tool in the build process to reduce the image size
- UPX will typically reduce the file size of programs and DLLs by around 50%-70%, 
- Thus reducing disk space, network load times, download times and other distribution and storage costs.
----------
## Design Consideration 4
- We can use Virtual Threads based on the requirement to increase the performance and throughput 
- Virtual threads are designed to be much lighter than traditional threads. This allows for the creation of thousands or even millions of threads without significant performance overhead
- The API for virtual threads is often designed to be similar to that of traditional threads, making it easy for developers to adopt and integrate into existing codebases.
- Virtual threads make it easier to write and reason about concurrent code. Developers can create many virtual threads without worrying about the typical constraints and complexities associated with traditional threads.
- Virtual threads can improve the performance of applications that handle a large number of concurrent tasks. This is especially beneficial for applications such as web servers, databases, and other I/O-bound systems.
- In traditional threading models, blocking I/O operations can waste resources by tying up threads that are waiting for I/O to complete. Virtual threads are designed to handle blocking operations more efficiently, allowing the runtime to manage thread states and optimize resource usage.
----------
## Reference
- REF000000012
- REF000000013
- REF000000014

