
## Install Java 22 on mac
Download the java openjdk 22 [openjdk-22.0.2_macos-x64_bin.tar.gz](https://jdk.java.net/22/)
Copy folder into location  /Library/Java/JavaVirtualMachines/

Set JAVA_HOME in the ~/.bash_profile file
```shell
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-22.0.2.jdk/Contents/Home
```
Update the ~/.bash_profile
```shell
source ~/.bash_profile
``` 

## Reference 
* https://jdk.java.net/22/