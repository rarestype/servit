this directory contains an HTTPS demo application. when stripped, the compiled release binary is just 10 MB large!

```bash
$ swift build -c release --package-path Examples --product Demo
$ strip Examples/.build/x86_64-unknown-linux-gnu/release/Demo
$ ls -l Examples/.build/x86_64-unknown-linux-gnu/release/Demo
```

```text
-rwxr-xr-x 1 ubuntu ubuntu 10056856 Mar 14 02:39 Examples/.build/x86_64-unknown-linux-gnu/release/Demo
```
