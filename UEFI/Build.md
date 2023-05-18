1. nasm版本较低引起的build错误 <error: parser: instruction expected>

解决方案来自于： https://edk2.groups.io/g/devel/topic/90276518
解决方案：更新nasm到最新版本

```bash
sudo apt purge nasm

wget http://www.nasm.us/pub/nasm/releasebuilds/2.16.01/
tar -xf nasm***
cd nasm***
./configure
make
sudo make install

```