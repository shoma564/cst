#FROM ubuntu:18.04
FROM centos:centos7
# openss-serverをインストール
RUN yum -y update && yum install -y openssh-server iputils-ping net-tools dnsutils sudo nmap-ncat gcc zip unzip make wget bzip2 bunzip2 httpd epel-release nkf nano python3 file ltrace strace vim nodejs default-mysql-client language-pack-ja-base language-pack-ja glibc-common  openssh-clients
RUN yum -y reinstall glibc

RUN useradd -m -G wheel BUS_A && echo BUS_A:tmcit_cyber | chpasswd && echo "BUS_A   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN useradd -m -G wheel BUS_B && echo BUS_B:tmcit_cyber | chpasswd && echo "BUS_B   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN useradd -m -G wheel user01 && echo user01:cst_2021 | chpasswd && echo "user01   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN useradd -m -G wheel user02 && echo user02:cst_2021 | chpasswd && echo "user02   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN useradd -m -G wheel user03 && echo user03:cst_2021 | chpasswd && echo "user03   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN useradd -m -G wheel user04 && echo user04:cst_2021 | chpasswd && echo "user04   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


RUN mkdir -p /home/BUS_A/log
RUN mkdir -p /home/BUS_B/log

RUN mkdir -p /home/user01/question_files
RUN mkdir -p /home/user02/question_files
RUN mkdir -p /home/user03/question_files
RUN mkdir -p /home/user04/question_files


COPY ./question_files /home/user01/question_files
COPY ./question_files /home/user02/question_files
COPY ./question_files /home/user03/question_files
COPY ./question_files /home/user04/question_files


RUN  cp -rp /home/user01/question_files /home/user01/bk
RUN  cp -rp /home/user02/question_files /home/user02/bk
RUN  cp -rp /home/user03/question_files /home/user03/bk
RUN  cp -rp /home/user04/question_files /home/user04/bk



RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8


ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"



COPY ./bus_restart/BUS_restart.py /BUS_restart.py



RUN rm /bin/ssh




# ssh用のディレクトリ作成
# このディレクトリがないとsshdが動かないっぽい。
RUN mkdir /var/run/sshd
# パスワードの設定（root:の後の値がパスワードになる。今回はpassword）
RUN echo 'root:centostos' | chpasswd
# rootでのSSHログインを許可
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# password認証を許可
RUN sed -i 's/#PasswordAuthetication/PasswordAuthetication/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN sshd-keygen

# sshdの起動
CMD ["/usr/sbin/sshd", "-D"]