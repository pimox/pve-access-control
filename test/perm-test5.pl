#!/usr/bin/perl -w

use strict;
use PVE::Tools;
use PVE::AccessControl;
use PVE::RPCEnvironment;
use Getopt::Long;

my $rpcenv = PVE::RPCEnvironment->init('cli');

my $cfgfn = "test5.cfg";
$rpcenv->init_request(userconfig => $cfgfn);

sub check_roles {
    my ($user, $path, $expected_result) = @_;

    my $roles = PVE::AccessControl::roles($rpcenv->{user_cfg}, $user, $path);
    my $res = join(',', sort keys %$roles);

    die "unexpected result\nneed '${expected_result}'\ngot '$res'\n"
	if $res ne $expected_result;

    print "ROLES:$path:$user:$res\n";
}


check_roles('User1@pve', '/vms', 'Role1');
check_roles('User1@pve', '/vms/100', 'Role1');
check_roles('User1@pve', '/vms/100/a', 'Role1');
check_roles('User1@pve', '/vms/100/a/b', 'Role2');
check_roles('User1@pve', '/vms/100/a/b/c', 'Role2');
check_roles('User1@pve', '/vms/200', 'Role1');

check_roles('User2@pve', '/kvm', 'Role2');
check_roles('User2@pve', '/kvm/vms', 'Role1');
check_roles('User2@pve', '/kvm/vms/100', '');
check_roles('User2@pve', '/kvm/vms/100/a', 'Role3');
check_roles('User2@pve', '/kvm/vms/100/a/b', '');

print "all tests passed\n";

exit (0);
