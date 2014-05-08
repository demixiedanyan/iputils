#
# Configuration
#配置

# CC
#指定cc为gcc编译程序的简称
CC=gcc
#----------------------------------------------------------------
#除了通过变量CC设置编译器之外，还可以通过CFLAGS和LDFLAGS分别指定编译和链接选项。
#一些常用的设置如下：
#CFLAGS=-O2          设置编译器优化级别为-O2
#CFLAGS="-D NDEBUG"    关闭所有assert()调试信息
#LDFLAGS=-static     进行交叉编译时必须链接到静态链接库
#可以在一条命令中同时指定多个选项，例如针对路由器进行交叉编译的make命令如下：
#env CC=/tools/dd/bin/misp-linux-gnu-gcc  CFLAGS="-O2 -D NDEBUG"  LDFLAGS=-static  make
#----------------------------------------------------------------

# Path to parent kernel include files directory
#母核路径包含文件的目录
LIBC_INCLUDE=/usr/include
# Libraries
ADDLIB=

# Linker flags
#wl选项告诉编译器将后面的参数传递给链接器
#-wl，-Bstatic告诉链接器使用-Bstatic选项，相应的，-Bdynamic告诉链接器使用-Bdynamic选项，该选项是告诉 链接器，对接下来的-l选项使用静态链接
LDFLAG_STATIC=-Wl,-Bstatic
LDFLAG_DYNAMIC=-Wl,-Bdynamic
# 指定需要加载的函数库有哪些，可以自行添加
# 下面加载的函数库是cap函数库、TLS加密函数库、crypto加密解密函数库、idn恒等函数库、resolv函数库、sysfs接口函数库等
LDFLAG_CAP=-lcap
LDFLAG_GNUTLS=-lgnutls-openssl
LDFLAG_CRYPTO=-lcrypto
LDFLAG_IDN=-lidn
LDFLAG_RESOLV=-lresolv
LDFLAG_SYSFS=-lsysfs

#
# Options
# 定义变量，设置开关

# Capability support (with libcap) [yes|static|no]
# Cap函数库的支持，用libcap表示，状态分别为：是，静态，没有
USE_CAP=yes
# sysfs support (with libsysfs - deprecated) [no|yes|static]
# sysfs函数库的支持，用libsysfs - deprecated表示，状态分别为：没有，是，静态
USE_SYSFS=no
# IDN support (experimental) [no|yes|static]
# IDN函数库的支持，用experimental表示，状态分别为：没有，是，静态
USE_IDN=no
# 默认状态为第一个


# Do not use getifaddrs [no|yes|static]
# 默认不使用gentifaddrs函数获得接口的相关信息
WITHOUT_IFADDRS=no
# arping default device (e.g. eth0) []
# arping默认设备，如网卡、以太网、无线
ARPING_DEFAULT_DEVICE=

# GNU TLS library for ping6 [yes|no|static]
# 默认GNU TLS库ping6的状态为：是
USE_GNUTLS=yes
# Crypto library for ping6 [shared|static]
# 默认加密解密库ping6的状态为：共享
USE_CRYPTO=shared
# Resolv library for ping6 [yes|static]
# 默认resolv库ping6的状态为：是
USE_RESOLV=yes
# ping6 source routing (deprecated by RFC5095) [no|yes|RFC3542]
# 默认ping6源路由的状态为：没有，这里不推荐使用RFC5095
ENABLE_PING6_RTHDR=no

# rdisc server (-r option) support [no|yes]
# 默认RDISC服务器是不支持-r选项的
ENABLE_RDISC_SERVER=no

# -------------------------------------
# What a pity, all new gccs are buggy and -Werror does not work. Sigh.
# CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
#-Wstrict-prototypes: 如果函数的声明或定义没有指出参数类型，编译器就发出警告，这个包括主函数，也要指出参数的类型，即便是空void
#另外，CFLAGS += -Wall -Wextra 指总是开启所有编译器警告选项
CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -g
#设置编译器优化级别为-O3
CCOPTOPT=-O3
# 关闭所有assert()调试信息
GLIBCFIX=-D_GNU_SOURCE
DEFINES=
LDLIB=

FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))

#----------------------------------------------------------------
#判断每个函数库中是否重复包含函数
# USE_GNUTLS: DEF_GNUTLS, LIB_GNUTLS
# USE_CRYPTO: LIB_CRYPTO
#判断crypto加密解密函数库中的函数是否重复
ifneq ($(USE_GNUTLS),no)
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
	DEF_CRYPTO = -DUSE_GNUTLS
else
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
endif

# USE_RESOLV: LIB_RESOLV
#判断crypto加密解密函数库中的函数是否重复
LIB_RESOLV = $(call FUNC_LIB,$(USE_RESOLV),$(LDFLAG_RESOLV))

# USE_CAP:  DEF_CAP, LIB_CAP
#判断CAP函数库中的函数是否重复
ifneq ($(USE_CAP),no)
	DEF_CAP = -DCAPABILITIES
	LIB_CAP = $(call FUNC_LIB,$(USE_CAP),$(LDFLAG_CAP))
endif

# USE_SYSFS: DEF_SYSFS, LIB_SYSFS
#判断SYSFS接口函数库中的函数是否重复
ifneq ($(USE_SYSFS),no)
	DEF_SYSFS = -DUSE_SYSFS
	LIB_SYSFS = $(call FUNC_LIB,$(USE_SYSFS),$(LDFLAG_SYSFS))
endif

# USE_IDN: DEF_IDN, LIB_IDN
#判断IDN恒等函数库中的函数是否重复
ifneq ($(USE_IDN),no)
	DEF_IDN = -DUSE_IDN
	LIB_IDN = $(call FUNC_LIB,$(USE_IDN),$(LDFLAG_IDN))
endif

#----------------------------------------------------------------
#判断重复加载
# WITHOUT_IFADDRS: DEF_WITHOUT_IFADDRS
ifneq ($(WITHOUT_IFADDRS),no)
	DEF_WITHOUT_IFADDRS = -DWITHOUT_IFADDRS
endif

# ENABLE_RDISC_SERVER: DEF_ENABLE_RDISC_SERVER
ifneq ($(ENABLE_RDISC_SERVER),no)
	DEF_ENABLE_RDISC_SERVER = -DRDISC_SERVER
endif

# ENABLE_PING6_RTHDR: DEF_ENABLE_PING6_RTHDR
ifneq ($(ENABLE_PING6_RTHDR),no)
	DEF_ENABLE_PING6_RTHDR = -DPING6_ENABLE_RTHDR
ifeq ($(ENABLE_PING6_RTHDR),RFC3542)
	DEF_ENABLE_PING6_RTHDR += -DPINR6_ENABLE_RTHDR_RFC3542
endif
endif

# -------------------------------------
#设置IPV4和IPV6

#tracepath与traceroute功能相似，可以测试IP数据报文从源主机传到目的主机经过的路由
#ping可以测试计算机名和计算机的ip地址，验证与远程计算机的连接
#arping可以向目的主机发送ARP报文，通过目的主机的IP获得该主机的硬件地址
#tftpd是简单文件传送协议TFTP的服务端程序
#rarpd是逆地址解析协议的服务端程序使用
#clockdiff可以测算目的主机和本地主机的系统时间差
#rdisc是路由器发现守护程序
IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
IPV6_TARGETS=tracepath6 traceroute6 ping6
TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)

#
CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)
LDLIBS=$(LDLIB) $(ADDLIB)

#uname  means print system information,description '-n' means print the network node hostname
#git-describe show the most recent tag that is reachable from a commit 
#sed -e 使编辑命令在命令列 's/-.*//'上执行
UNAME_N:=$(shell uname -n)
LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')
#配置date
TODAY=$(shell date +%Y/%m/%d)
DATE=$(shell date --date $(TODAY) +%Y%m%d)
TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)


# -------------------------------------
#检查内核模块在编译过程中产生的中间文件即垃圾文件并加以清除
.PHONY: all ninfod clean distclean man html check-kernel modules snapshot

#COMPILE.c指C编译文件
#TAGET代表应用程序
all: $(TARGETS)

%.s: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@
%.o: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@
$(TARGETS): %: %.o
	$(LINK.o) $^ $(LIB_$@) $(LDLIBS) -o $@

#COMPILE.c=$(CC) $(CFLAGS) $(CPPFLAGS) -c
# $< 依赖目标中的第一个目标名字 
# $@ 表示目标
# $^ 所有的依赖目标的集合 
# 在$(patsubst %.o,%,$@ )中，patsubst把目标中的变量符合后缀是.o的全部删除,  变成执行文件的形式
# $(DEF_$(patsubst %.o,%,$@))指该目标文件所依赖的函数库
# LINK.o把.o文件链接在一起的命令行,缺省值是$(CC) $(LDFLAGS) $(TARGET_ARCH)

#以ping为例，翻译为
# gcc -O3 -fno-strict-aliasing -Wstrict-prototypes -Wall -g -D_GNU_SOURCE    -c ping.c -DCAPABILITIES   -o ping.o
#gcc   ping.o ping_common.o -lcap    -o ping


# -------------------------------------
# arping
#向相邻主机发送ARP请求
DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_arping = $(LIB_SYSFS) $(LIB_CAP) $(LIB_IDN)

#条件语句的开始
ifneq ($(ARPING_DEFAULT_DEVICE),)
DEF_arping += -DDEFAULT_DEVICE=\"$(ARPING_DEFAULT_DEVICE)\"
#在$(ARPING_DEFAULT_DEVICE)中存在结尾空格，在这句话中也会被作为makefile需要执行的一部分。
endif

#linux环境下一些实用的网络工具的集合iputils软件包，以下包含的工具：clockdiff， ping / ping6，rarpd，rdisc，tracepath， tftpd。
# clockdiff
#测算目的主机和本地主机的系统时间差，clockdiff程序由clockdiff.c文件构成。
DEF_clockdiff = $(DEF_CAP)
LIB_clockdiff = $(LIB_CAP)

# ping / ping6
#测试计算机名和计算机的ip地址，验证与远程计算机的连接。ping程序由ping.c
DEF_ping_common = $(DEF_CAP) $(DEF_IDN)
DEF_ping  = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_ping  = $(LIB_CAP) $(LIB_IDN)
DEF_ping6 = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS) $(DEF_ENABLE_PING6_RTHDR) $(DEF_CRYPTO)
LIB_ping6 = $(LIB_CAP) $(LIB_IDN) $(LIB_RESOLV) $(LIB_CRYPTO)

ping: ping_common.o
ping6: ping_common.o
ping.o ping_common.o: ping_common.h
ping6.o: ping_common.h in6_flowlabel.h

# rarpd
#逆地址解析协议的服务端程序，rarpd程序由rarpd.c文件构成。
DEF_rarpd =
LIB_rarpd =

# rdisc
#路由器发现守护程序，rdisc程序由rdisc.c文件构成。 
DEF_rdisc = $(DEF_ENABLE_RDISC_SERVER)
LIB_rdisc =

# tracepath
#与traceroute功能相似，使用tracepath测试IP数据报文从源主机传到目的主机经过的路由，tracepath程序由tracepath.c tracepath6.c traceroute6.c 文件构成。
DEF_tracepath = $(DEF_IDN)
LIB_tracepath = $(LIB_IDN)

# tracepath6
DEF_tracepath6 = $(DEF_IDN)
LIB_tracepath6 =

# traceroute6
DEF_traceroute6 = $(DEF_CAP) $(DEF_IDN)
LIB_traceroute6 = $(LIB_CAP) $(LIB_IDN)

# tftpd
#简单文件传送协议TFTP的服务端程序，tftpd程序由tftp.h tftpd.c tftpsubs.c文件构成。
DEF_tftpd =
DEF_tftpsubs =
LIB_tftpd =

tftpd: tftpsubs.o
tftpd.o tftpsubs.o: tftp.h

# -------------------------------------
# ninfod
ninfod:
	@set -e; \       
#若指令传回值不等于0，则立即退出shell。
		if [ ! -f ninfod/Makefile ]; then \      
#立即跟文件名也可以正常压缩和解压缩
			cd ninfod; \
			./configure; \
			cd ..; \
		fi; \
#then 和 fi 在shell里面被认为是分开的语句，fi为if语句的结束,相当于end if
		$(MAKE) -C ninfod

# -------------------------------------
# modules / check-kernel are only for ancient kernels; obsolete
#将某个程序实体标记为一个建议不再使用的实体。每次使用被标记为已过时的实体时，随后将生成警告或错误，这取决于属性是如何配置的。
check-kernel:
ifeq ($(KERNEL_INCLUDE),)
	@echo "Please, set correct KERNEL_INCLUDE"; false
else
	@set -e; \
#若字符串中出现以下字符，则特别加以处理，而不会将它当成一般文字输出
	if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \
		echo "Please, set correct KERNEL_INCLUDE"; false; fi
endif

modules: check-kernel
	$(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules
#删除已生成的目标文件
# -------------------------------------
man:
	$(MAKE) -C doc man

html:
	$(MAKE) -C doc html

 #容错处理
clean:
	@rm -f *.o $(TARGETS)
	@$(MAKE) -C Modules clean
	@$(MAKE) -C doc clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod clean; \
		fi

distclean: clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod distclean; \
		fi

# -------------------------------------
#snapshot是CRecordset类的成员变量，通常作为CRecordset::Open()函数的参数，代表在记录集中可双向移动的快照。
snapshot:
	@if [ x"$(UNAME_N)" != x"pleiades" ]; then echo "Not authorized to advance snapshot"; exit 1; fi
	@echo "[$(TAG)]" > RELNOTES.NEW
	@echo >>RELNOTES.NEW
	@git log --no-merges $(LASTTAG).. | git shortlog >> RELNOTES.NEW
	@echo >> RELNOTES.NEW
	@cat RELNOTES >> RELNOTES.NEW
	@mv RELNOTES.NEW RELNOTES
	@sed -e "s/^%define ssdate .*/%define ssdate $(DATE)/" iputils.spec > iputils.spec.tmp
	@mv iputils.spec.tmp iputils.spec
	@echo "static char SNAPSHOT[] = \"$(TAG)\";" > SNAPSHOT.h
	@$(MAKE) -C doc snapshot
	@$(MAKE) man
	@git commit -a -m "iputils-$(TAG)"
	@git tag -s -m "iputils-$(TAG)" $(TAG)
	@git archive --format=tar --prefix=iputils-$(TAG)/ $(TAG) | bzip2 -9 > ../iputils-$(TAG).tar.bz2

