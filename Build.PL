#!/usr/bin/perl -w
use Module::Build;
my $build = Module::Build->new(
		module_name	=>	'Data::FormValidator::Tutorial',
		license		=>	'perl',
		requires	=>	{ 'perl' => '5.6.1' },
		dist_author	=>	[
						'William McKee <william@knowmad.com>',
						'Jason Purdy <jason@purdy.info>'
					],
		dist_abstract	=>	'Data::FormValidator Tutorial',
	);
$build->create_build_script;
