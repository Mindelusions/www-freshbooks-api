#!/usr/bin/perl
use warnings;
use strict;

use lib 'lib';
use Data::Dumper;
use WWW::FreshBooks::API;

my $url = "https://mindelusions.freshbooks.com/api/2.1/xml-in";
my $key = "6972558badf698ab672e19a2ec3619f1";

#my $method = "category.get";
#my $args = {category_id => 1};
#my $query = "category_id";

my $method = "invoice.list";
my $args = {};
my $query = "invoice_id";

my $list_tests = [
	{
		method  => "client.list",
		args	=> {},
		query	=> "client_id",
	},
	{
		method  => "invoice.list",
		args	=> {},
		query	=> "invoice_id",
	},
];

my $lists = [qw/client category item expense project invoice/];

my $fb = WWW::FreshBooks::API->new({svc_url => $url, auth_token => $key});
my ($ref, $resp);
#my ($ref, $resp) = $fb->call($method, $args);

foreach my $l(@{$lists}) {
	my $method = $l . ".list";
	my $args = {};
	my $query = $l . "_id";

	$fb->call($method, $args);
	my $fields = $fb->item_fields->{$fb->item_class};
	print "FIELDS: $fields\n";
	my $results = $fb->results;
	my $items = $results->items;

	my $litem;
	print "--------- " . $method . " ----------\n";
	while (my $item = $results->iterator->next()) {
		print "ITER: " . $item->$query . "\n";
		$litem = $item;

		map { print $_ . " --> " . $item->$_ . "\n" } @{$fields};
		exit;
	}

	my $r2 = $fb->call($l . ".get", {$query => $litem->$query});
	my $i2 = $r2->iterator->next;
	print Data::Dumper->Dump([$i2]);
}

exit;


=pod

curl -u 6972558badf698ab672e19a2ec3619f1:x https://mindelusions.freshbooks.com/api/2.1/xml-in -d \
'<?xml version="1.0" encoding="utf-8"?><request method="client.list"></request>'

=cut
