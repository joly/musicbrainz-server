#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Moderation::MOD_EDIT_LINK_TYPE;

use ModDefs qw( :modstatus DARTIST_ID MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Link Type" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $node = $opts{'node'} or die; # a LinkType object
	my $name = $opts{'name'};
	MusicBrainz::TrimInPlace($name);
	die if $name eq "";

	my $c = $node->Parent->GetNamedChild($name);
	if ($c and $c->GetId != $node->GetId)
	{
		my $note = "There is already a link type called '$name' here";
		$self->SetError($note);
		die $self;
	}

	$self->SetArtist(DARTIST_ID);
	$self->SetTable($node->{_table}); # FIXME internal field
	$self->SetColumn("name");
	$self->SetRowId($node->GetId);
	$self->SetPrev($node->GetName);

	my %new = (
		types	=> $node->PackTypes,
		name	=> $name,
	);

	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
}

sub CheckPrerequisites
{
  	my $self = shift;

	my $link = MusicBrainz::Server::LinkType->newFromPackedTypes(
		$self->{DBH},
		$self->{'new_unpacked'}{'types'},
	);
	my $node = $link->newFromId($self->GetRowId);

	if (not $node)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This link type has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its name has not changed
	if ($node->GetName ne $self->GetPrev)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This link type has already been renamed");
		return STATUS_FAILEDPREREQ;
	}

	# Avert duplicate index entries: check for this name already existing
	my $name = $self->{'new_unpacked'}{'name'};
	my $c = $node->Parent->GetNamedChild($name);
	if ($c and $c->GetId != $node->GetId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "There is already a link type called '$name' here");
		return STATUS_FAILEDPREREQ;
	}

	# Save for ApprovedAction
	$self->{'node'} = $node;

	undef;
}

sub ApprovedAction
{
  	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;
	my $node = $self->{'node'};

	my $name = $self->{'new_unpacked'}{'name'};
	$node->SetName($name);
	$node->Update;

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_LINK_TYPE.pm
