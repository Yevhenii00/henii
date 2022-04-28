#!/bin/sh

test_description='verify safe.directory checks while running as root'

. ./test-lib.sh

if [ "$IKNOWWHATIAMDOING" != "YES" ]; then
	skip_all="You must set env var IKNOWWHATIAMDOING=YES in order to run thi
s test"
	test_done
fi

if ! test_have_prereq NOT_ROOT
then
	skip_all="this test uses sudo to run as root"
	test_done
fi

doalarm () {
	perl -e 'alarm shift; exec @ARGV' -- "$@"
}

test_lazy_prereq SUDO '
	doalarm 1 sudo id -u >u &&
	id -u root >r &&
	test_cmp u r
'

test_expect_success SUDO 'setup' '
	sudo rm -rf root &&
	mkdir -p root/r &&
	sudo chown root root &&
	(
		cd root/r &&
		git init
	)
'

test_expect_success SUDO 'sudo git status works' '
	(
		cd root/r &&
		git status &&
		sudo git status
	)
'

test_expect_success SUDO 'cleanup' '
	sudo rm -rf root
'

test_done
