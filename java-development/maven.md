
mvn --encrypt-master-password

~/.m2/settings-security.xml

<settingsSecurity>
  <master>{jSMOWnoPFgsHVpMvz5VrIt5kRbzGpI8u+9EF1iFQyJQ=}</master>
</settingsSecurity>

<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <servers>
        <server>
            <id>my-app-virtual-snapshot</id>
            <username>admin</username>
            <password>encrypted passwrod by master password</password>
        </server>
        <server>
            <id>my-app-central-snapshot</id>
            <username>admin</username>
            <password>encrypted passwrod by master password</password>
        </server>
    </servers>

    <profiles>
        <profile>
            <id>my-app</id>
            <repositories>
                <repository>
                    <id>my-app-virtual-snapshot</id>
                    <name>my-app-virtual-snapshot</name>
                    <url>http://jfrog.devops.com/artifactory/my-app-virtual-snapshot/</url>
                    <layout>default</layout>
                </repository>
            </repositories>
        </profile>
    </profiles>

    <activeProfiles>
        <activeProfile>my-app</activeProfile>
    </activeProfiles>

    <mirrors>
        <mirror>
            <id>my-app-central-snapshot</id>
            <mirrorOf>*</mirrorOf>
            <url>http://jfrog.devops.com/artifactory/my-app-central-snapshot</url>
            <name>Artifactory</name>
            <blocked>false</blocked>
        </mirror>
    </mirrors>
</settings>

## Reference
* https://maven.apache.org/guides/mini/guide-encryption.html
* https://www.baeldung.com/maven-settings-xml