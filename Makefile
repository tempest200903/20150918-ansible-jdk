ansible-playbook-jdk: ansible-ping
	ansible-playbook -i hosts playbook-jdk.yaml -s ; echo ES $?

ansible-ping: .make.ansible.available
	ansible -i hosts 192.168.33.14 -m ping
	ansible -i hosts 211.17.181.228 -m ping || make when-fail-ansible-ping

.make.ansible.available: 
	which ansible && date > .make.ansible.available || ( echo "NEXT ACTION: make .make.install.ansible" ; false )

.make.install.ansible: 
	which yum
	sudo yum -y install ansible
	ansible --version
	which ansible
	date > .make.install.ansible

when-fail-ansible-ping: 
	make about-paramiko
	make about-pycrypto

about-paramiko: 
	echo "If 'Incompatible ssh peer' occured, read this. http://www.randomhacks.co.uk/paramiko-sshexception-incompatible-ssh-peer-no-acceptable-kex-algorithm-ubuntu-14-04/"
	echo "To fix the issue, you need to upgrade Paramiko to at least 1.15.1. You can do this by using PIP which is a Python package management system."
	make show-paramiko-version
	which pip || echo "NEXT ACTION: make .make.pip"
	echo "NEXT ACTION: if Version is less than 1.15.1 then make .make.install-paramiko"

show-paramiko-version:
	echo paramiko Version is 
	pip show paramiko | grep Version

.make.pip: 
	sudo easy_install pip
	which pip
	date > .make.pip

.make.install-paramiko: .make.pip
	which pip
	echo https://www.versioneye.com/python/paramiko/1.15.1
	sudo pip install https://pypi.python.org/packages/2.6/p/paramiko/paramiko-1.15.1-py2.py3-none-any.whl || make when-fail-install-paramiko
	make show-paramiko-version
	date > .make.install-paramiko
	echo "NEXT ACTION: make ansible-ping" 

when-fail-install-paramiko: 
	echo "If install-paramiko failed, read this. http://stackoverflow.com/questions/17639889/installing-paramiko-pycrypto-gives-compile-error"
	echo 'In CentOS/RHEL 6 "yum install python-devel" will fix this problem. (You need the Python headers so pycrypto can be installed.)'
	echo "NEXT ACTION: make .make.python-devel"

.make.python-devel: 
	sudo yum -y install python-devel
	date > .make.python-devel
	echo "NEXT ACTION: make .make.install-paramiko"

about-pycrypto: 
	echo 'If ansible failed at "ansible/runner/__init__.py", then read this. http://fujikkoooooo.hateblo.jp/entry/2015/04/28/121040"'
	echo "pycrypto 2.3 をインストールすると正常に動作することを確認し、2.4、2.6.1(執筆時点での最新バージョン)インストール状態で動作確認した際はエラーとなりました。"
	make show-pycrypto-version
	echo "NEXT ACTION: make .make.install-pycrypto"

show-pycrypto-version: 
	pip show pycrypto | grep Version

.make.install-pycrypto: .make.pip
	make show-pycrypto-version
	sudo pip install pycrypto==2.3
	make show-pycrypto-version
	echo "You shoud use pycrypto 2.3 "
	echo "NEXT ACTION: make ansible-ping"

