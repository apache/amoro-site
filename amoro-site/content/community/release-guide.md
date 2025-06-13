---
title: "Release Guide"
url: release-guide
disableSidebar: true
---
# How to release a new version

## Preparation

### Apache release documentation
Please refer to the following link to understand the ASF release process:

- [Apache Release Guide](http://www.apache.org/dev/release-publishing)
- [Apache Release Policy](http://www.apache.org/dev/release.html)
- [Publishing Maven Artifacts](http://www.apache.org/dev/publishing-maven-artifacts.html)

### Environmental requirements

- JDK 11
- Apache Maven 3.x
- GnuPG 2.x
- Git
- SVN

### GPG signature

Follow the Apache release guidelines, you need the GPG signature to sign the release version, users can also use this to determine if the downloaded version has been tampered with.

Create a pgp key for version signing, use `<your Apache ID>@apache.org` as the USER-ID for the key.

For more details, refer to [Apache Releases Signing documentation](https://infra.apache.org/release-signing)，[Cryptography with OpenPGP](http://www.apache.org/dev/openpgp.html).

Brief process for generating a key：

* Generate a new GPG key using `gpg --gen-key`, set the key length to 4096 and set it to never expire
* Upload the key to the public key server using `gpg --keyserver keys.openpgp.org --send-key <your key id>`
* Export the public key to a text file using `gpg --armor --export <your key id> >> gpgapachekey.txt`
* Obtain the keys of other committers for signing (optional)
* Add the generated key to the KEYS file (uploaded to the svn repository by the release manager)

You can follow the steps below to create the GPG key:

{{< hint info >}}
You should replace `amoro` with your `Apache ID` in following guides.
{{< /hint >}}

```shell
$ gpg --full-gen-key
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
(1) RSA and RSA (default)
(2) DSA and Elgamal
(3) DSA (sign only)
(4) RSA (sign only)
(14) Existing key from card
Your selection? 1 # Please enter 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 4096 # Please enter 4096 here
Requested keysize is 4096 bits
Please specify how long the key should be valid.
0 = key does not expire
<n> = key expires in n days
<n>w = key expires in n weeks
<n>m = key expires in n months
<n>y = key expires in n years
Key is valid for? (0) 0 # Please enter 0
Key does not expire at all
Is this correct? (y/N) y # Please enter y here

GnuPG needs to construct a user ID to identify your key.

Real name: amoro # Please enter 'gpg real name'
Email address: amoro@apache.org # Please enter your apache email address here
Comment: amoro # Please enter some comments here
You selected this USER-ID:
    "amoro (amoro) <amoro@apache.org>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O # Please enter O here
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

# At this time, a dialog box will pop up, asking you to enter the key for this gpg. 
# you need to remember that it will be used in subsequent steps.
┌─────────────────────────────────────────────────────┐
│ Please enter this passphrase to                     │
│ protect your new key                                │
│                                                     │
│ Passphrase: _______________________________________ │
│                                                     │
│     <OK>                    <Cancel>                │
└─────────────────────────────────────────────────────┘

# Here you need to re-enter the password in the previous step.
┌─────────────────────────────────────────────────────┐
│ Please re-enter this passphrase                     │
│                                                     │
│ Passphrase: _______________________________________ │
│                                                     │
│     <OK>                    <Cancel>                │
└─────────────────────────────────────────────────────┘
gpg: key ACFB69E705016886 marked as ultimately trusted
gpg: revocation certificate stored as '/root/.gnupg/openpgp-revocs.d/DC12398CCC33A5349EB9663DF9D970AB18C9EDF6.rev'
public and secret key created and signed.

pub   rsa4096 2023-05-01 [SC]
      85778A4CE4DD04B7E07813ABACFB69E705016886
uid                      amoro (amoro) <amoro@apache.org>
sub   rsa4096 2023-05-01 [E]

```

Then you can follow the steps below to upload the GPG key to the public server:

```shell
$ gpg --keyid-format SHORT --list-keys
/root/.gnupg/pubring.kbx
------------------------
pub   rsa4096/05016886 2023-05-01 [SC]
      85778A4CE4DD04B7E07813ABACFB69E705016886
uid         [ultimate] amoro (amoro) <amoro@apache.org>
sub   rsa4096/0C5A4E1C 2023-05-01 [E]

# Send public key to keyserver via key id
$ gpg --keyserver keyserver.ubuntu.com --send-key 05016886 # send key should be found in the --list-keys result
# Among them, keyserver.ubuntu.com is the selected keyserver, it is recommended to use this, because the Apache Nexus verification uses this keyserver
```

Check if the key is uploaded successfully:

```shell
$ gpg --keyserver keyserver.ubuntu.com --recv-keys 05016886   # If the following content appears, it means success
gpg: key ACFB69E705016886: "amoro (amoro) <amoro@apache.org>" not changed
gpg: Total number processed: 1
gpg:              unchanged: 1

```

Add the GPG public key to the KEYS file of the Apache SVN project warehouse:

```shell
# Add public key to KEYS in dev branch
$ mkdir -p ~/amoro_svn/dev
$ cd ~/amoro_svn/dev
$ svn co https://dist.apache.org/repos/dist/dev/incubator/amoro
$ cd ~/amoro_svn/dev/amoro
# Append the KEY you generated to the file KEYS, and check if it is added correctly
$ (gpg --list-sigs amoro@apache.org && gpg --export --armor amoro@apache.org) >> KEYS 

$ svn ci -m "add gpg key for amoro"

# Add public key to KEYS in release branch
$ mkdir -p ~/amoro_svn/release
$ cd ~/amoro_svn/release

$ svn co https://dist.apache.org/repos/dist/release/incubator/amoro/
$ cd ~/amoro_svn/release/amoro

# Append the KEY you generated to the file KEYS, and check if it is added correctly
$ (gpg --list-sigs amoro@apache.org && gpg --export --armor amoro@apache.org) >> KEYS 

$ svn ci -m "add gpg key for amoro"
```

### Maven settings

During the release process, frequent access to your Apache password is required. To prevent exposure in plaintext storage, we need to encrypt it.

```shell
# Generate master password
$ mvn --encrypt-master-password <apache password>
{EM+4/TYVDXYHRbkwjjAS3mE1RhRJXJUSG8aIO5RSxuHU26rKCjuS2vG+/wMjz9te}
```

Create the file `${user.home}/.m2/settings-security.xml` and configure the password created in the previous step:

```xml
<settingsSecurity>
 <master>{EM+4/TYVDXYHRbkwjjAS3mE1RhRJXJUSG8aIO5RSxuHU26rKCjuS2vG+/wMjz9te}</master>
</settingsSecurity>
```

In the maven configuration file `~/.m2/settings.xml`, add the following item:

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
  <servers>
    <server>
        <id>apache.snapshots.https</id>
        <!-- APACHE LDAP UserName --> 
        <username>amoro</username>
        <!-- APACHE LDAP password (Fill in the password you just created with the command `mvn --encrypt-password <apache passphrase>`) -->
        <password>{/ZLaH78TWboH5IRqNv9pgU4uamuqm9fCIbw0gRWT01c=}</password>
    </server>
    <server>
        <id>apache.releases.https</id>
        <!-- APACHE LDAP UserName --> 
        <username>jinsongzhou</username>
        <!-- APACHE LDAP password (Fill in the password you just created with the command `mvn --encrypt-password <apache passphrase>`) -->
        <password>{/ZLaH78TWboH5IRqNv9pgU4uamuqm9fCIbw0gRWT01c=}</password>
    </server>
  </servers>

  <profiles>
        <profile>
          <id>apache-release</id>
          <properties>
            <gpg.keyname>05016886</gpg.keyname>
            <!-- Use an agent: Prevents being asked for the password during the build -->
            <gpg.useagent>true</gpg.useagent>
            <gpg.passphrase>passphrase for your gpg key</gpg.passphrase>
          </properties>
        </profile>
  </profiles>
</settings>
```

Generate the final encrypted password and add it to the `~/.m2/settings.xml` file:

```shell
$ mvn --encrypt-password <apache password>
{/ZLaH78TWboH5IRqNv9pgU4uamuqm9fCIbw0gRWT01c=}
```

## Build release

### Cut the release branch

Cut the release branch:

```shell
$ cd ${AMORO_SOURCE_HOME}
$ git checkout -b 0.8.x
```

Change the project version to the release version in the `tools/change-version.sh`:

```bash
OLD="0.8-SNAPSHOT"
NEW="0.8.0-incubating"

HERE=` basename "$PWD"`
if [[ "$HERE" != "tools" ]]; then
    echo "Please only execute in the tools/ directory";
    exit 1;
fi

# change version in all pom files
find .. -name 'pom.xml' -type f -exec perl -pi -e 's#<version>'"$OLD"'</version>#<version>'"$NEW"'</version>#' {} \;
```

Then run the scripts and commit the change:

```shell
$ cd tools
$ bash change-version.sh
$ cd ..
$ git add *
$ git commit -m "Change project version to 0.8.0-incubating"
$ git push apache 0.8.x
```

### Create the release tag

Create the release tag and push it to the Apache repo:

```shell
$ git tag -a v0.8.0-rc1 -m "Release Apache Amoro 0.8.0 rc1"
$ git push apache v0.8.0-rc1
```

### Build binary and source release

Build Amoro binary release with scripts:

```shell
$ cd ${AMORO_SOURCE_HOME}/tools
$ RELEASE_VERSION=0.8.0-incubating bash ./releasing/create_binary_release.sh
```

Then build source release with scripts:

```shell
$ cd ${AMORO_SOURCE_HOME}/tools
$ RELEASE_VERSION=0.8.0-incubating bash ./releasing/create_source_release.sh
```

Validate the source and binary packages according to the [How to validate a new version](#how-to-validate-a-new-version) guides.
After that, ublish the dev directory of the Apache SVN warehouse of the material package:

```shell
$ cd ~/amoro_svn/dev/amoro
$ mkdir 0.8.0-incubating-RC1
$ cp ${AMORO_SOURCE_HOME}/tools/releasing/release/* 0.8.0-incubating-RC1
$ svn add 0.8.0-incubating-RC1
$ svn commit -m "Release Apache Amoro 0.8.0 rc1"

```

### Release Apache Nexus

Next, we will publish the required JAR files to the ​Apache Nexus​ repository to achieve the final goal of releasing them to the ​Maven Central Repository.

```shell
$ cd ${$AMORO_SOURCE_HOME}/tools
$ RELEASE_VERSION=0.8.0-incubating bash ./releasing/deploy_staging_jars.sh
```

You can visit https://repository.apache.org/ and log in to check the publishment status. You can find the publishment process in the `Staging Repositories` section. You nedd to close the process when all jars are publised.

## Vote for the new release

Next, vote for the new release via email. First complete the vote within the Amoro community, and upon approval, complete the vote within the Amoro community in the Incubator community. For detailed voting guidelines, please refer to [voting process](https://www.apache.org/foundation/voting.html).

### Vote in the Amoro community

Send a vote email to `dev@amoro.apache.org` to start the vote process in Apache Amoro community, you can take [[VOTE] Release Apache Amoro(incubating) 0.8.0-incubating rc3](https://lists.apache.org/thread/22rrpzwtzkby8vnhfvcwzmpfxxz8qhns) as a example.

After 72 hours, if there are at least 3 binding votes in favor and no votes against, send the result email to celebrate the release of the version like [[RESULT][VOTE] Release Apache Amoro(incubating) 0.8.0-incubating rc3](https://lists.apache.org/thread/gokj30ldgh3p5866tw40h41mhdw90whs).

### Vote in the Incubator community

Then send a vote email to `general@incubator.apache.org` to start the vote process in Apache Incubator community, you can take [[VOTE] Release Apache Amoro(incubating) 0.8.0-incubating rc3](https://lists.apache.org/thread/22rrpzwtzkby8vnhfvcwzmpfxxz8qhns) as a example.

After 72 hours, if there are at least 3 binding votes in favor and no votes against, send the result email to celebrate the release of the version like [[RESULT][VOTE] Release Apache Amoro(incubating) 0.8.0-incubating rc3](https://lists.apache.org/thread/qmvg3tcds0p0pbn05w0mzchm85o581rv).

## Complete the final publishing steps

### Migrate source and binary packages

Migrate the source and binary packages to the release directory of the Apache SVN warehouse:

```shell
$ svn mv https://dist.apache.org/repos/dist/dev/incubator/amoro/0.8.0-incubating-RC1 https://dist.apache.org/repos/dist/release/incubator/amoro/0.8.0-incubating  -m "Release Apache Amoro 0.8.0-incubating"
```

### Publish releases in the Apache Staging repository

- Log in to http://repository.apache.org , log in with your Apache account
- Click Staging repositories on the left
- Select your most recently uploaded warehouse, the warehouse specified in the voting email
- Click the Release button above, this process will perform a series of checks

> It usually takes 24 hours for the warehouse to synchronize to other data sources

### Send announcement email

Finally, we need to send the announcement email to these mailing lists: `dev@amoro.apache.org`, `general@incubator.apache.org`. Here is an example of an announcement email:  [[ANNOUNCE] Apache Amoro (Incubating) 0.8.0-incubating available](https://lists.apache.org/thread/h3cy8f2mfmp4zms4cs3tq4hdlq64qyw0).

Congratulations! You have successfully completed all steps of the Apache Amoro release process. Thank you for your contributions!

# How to validate a new version

## Download candidate

```shell
# If there is svn locally, you can clone to the local
$ svn co https://dist.apache.org/repos/dist/dev/incubator/amoro/${release_version}-${rc_version}/
# or download the material file directly
$ wget https://dist.apache.org/repos/dist/dev/incubator/amoro/${release_version}-${rc_version}/
```

## validate candidate

### Check GPG signature

Download the KEYS and import it:

```shell
$ curl  https://downloads.apache.org/incubator/amoro/KEYS > KEYS # Download KEYS
$ gpg --import KEYS # Import KEYS to local
```

Trust the KEY used in this version:

```shell
$ gpg --edit-key xxxxxxxxxx #KEY user used in this version
gpg (GnuPG) 2.2.21; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.
gpg> trust #trust
Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5 #choose 5
Do you really want to set this key to ultimate trust? (y/N) y  #choose y
```

Check the gpg signature:

```shell
$ for i in *.tar.gz; do echo $i; gpg --verify $i.asc $i; done
```

### Check sha512 hash

```shell
# Command for Linux
$ for i in *.tar.gz; do echo $i; sha512sum --check  $i.sha512; done
# Command for MacOS
$ for i in *.tar.gz; do echo $i; shasum -a 512 -c $i.sha512; done
```

### Check the binary package

Unzip the binary pakcages: `apache-amoro-${AMORO_VERSION}-bin-${HADOOP_VERSION}.tar.gz`:

```shell
# Hadoop2
$ tar -xzvf apache-amoro-0.8.0-incubating-bin-hadoop2.tar.gz

# Hadoop3 
$ tar -xzvf apache-amoro-0.8.0-incubating-bin-hadoop3.tar.gz
```

check as follows:
- Check whether the package contains unnecessary files, which makes the tar package too large
- Folder contains the word incubating
- There are LICENSE and NOTICE files
- There is a DISCLAIMER file
- Check for extra files or folders, such as empty folders, etc.

### Check the source package

Unzip the binary pakcages: `apache-amoro-${AMORO_VERSION}-src.tar.gz`:

```shell
# Hadoop2
$ tar -xzvf apache-amoro-0.8.0-incubating-src.tar.gz
```

Check as follows:
- There are LICENSE and NOTICE files
- There is a DISCLAIMER file
- All source files have ASF license at the beginning
- Only source files exist, not binary files

Compile from source:

```shell
# Compile from source
$ mvn clean package

# Or skip the unit test
$ mvn clean package -DskipTests
```

## vote for the release

If all verifications pass, please vote for the new release! Thanks a lot for your contribution!