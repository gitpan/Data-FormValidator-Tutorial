package Data::FormValidator::Tutorial;

our $VERSION = '1.50';



1;
__END__
=head1 NAME

Data::FormValidator::Tutorial

=head1 TUTORIAL

=head2 Introduction

  Trust the user.  Don't trust their data.

Have you ever needed some code to verify the user entered the right data, much less even entered it at all in the first place?  You may start off with an if branch, then more and more.  Then you may start with a fancy C<%required> hash with the field name keys and description values.  And you copy-n-paste that code everywhere?  Sound familiar?  It does to me and I wish I had someone point me in the direction of this module a long time ago.  I hope we are reaching you in time!

This tutorial will start off really basic and then get into how it can help even with complex situations.  So let's get started!

=head2 And so we begin...

To begin with, I'm going to assume that you're a Web developer, working on a CGI or mod_perl program.  You can also use this module for other application types and these examples will still apply, but it will help me if I can relate to what you're doing.  This tutorial is also based on the latest & greatest version - 3.62.  I hope I just didn't date myself.

So let's start off with a subroutine (let's call it C<process>) that handles when the user submits their input:

  use CGI;
  # This is called from a simple registration page, where we
  # prompt the user for a username, e-mail address and two
  # password fields
  sub process {
    my ( $cgi );

    $cgi = new CGI;
    # We need to make sure they provided all those fields!
  }

So now let's create a new Data::FormValidator (you know, let's call it B<dfv> for short from here on out, ok?) object.  First, we'll need to add the C<use Data::FormValidator;> line at the top of your code and then call dfv's C<check> method on the $cgi object.  Here's what that code looks like so far:

  use CGI;
  use Data::FormValidator;
  sub process {
    my ( $cgi, $dfv_profile, $results );

    $cgi = new CGI;
    # We need to make sure they provided all those fields!
    $dfv_profile = {};
    $results = Data::FormValidator->check( $cgi, $dfv_profile );
  }

I<I hope you don't object to me taking out those comments ... just showing the pertinent lines now that you have the grasp of what we're trying to do.>

That code won't work (yet).  The C<$dfv_profile> data structure is blank.  So dfv doesn't have anything to check, so everything will be hunky-dorey.  As you get this framework meshed out, you'll find yourself refining the C<$dfv_profile> data structure long after (What?  Management changes their mind on what's important?  Or how something looks?), so some people actually remove it to a separate subroutine:

  ...
    $results = Data::FormValidator->check( $cgi, dfv_profile() );
  ...
  sub dfv_profile {
    return {
      };
  }

So now we have two big TODO's left: 1) Work out the dfv_profile hashref and 2) Finish up the framework.  PoB<ta>to/B<Po>tato on what's easiest... let's finish the framework!

So after establishing the C<$results> variable through the C<check()> call, we can then use it to call dfv's support methods: C<has_invalid> and C<has_missing>

  ...
    $results = Data::FormValidator->check( $cgi, dfv_profile() );
    if ( $results->has_missing() || $results->has_invalid() ) {
      # There was something wrong w/ the data...
    } else {
      # We're in the clear!  The user has provided you with
      # good data
    }
  ...

You know, one thing that will help you understand the C<$results> variable is if you C<Data::Dumper> it while you're getting the grasp of it:

  ...
    $results = Data::FormValidator->check( $cgi, dfv_profile() );
    # Comment/take out the line below when we go live!
    use Data::Dumper; print "Content-type: text/html\n\n", Dumper( $results );
  ...

So what do you want to do if data is missing or invalid?  If you're looking at pre-existing code, you probably are already doing I<something>, so you could just envelope your existing code in that if branch code above.  In my opinion, the best usability thing to do is re-present the preceding form with an error message.  There are other frameworks (L<CGI::Application>, L<HTML::FillInForm> and L<HTML::Template>) that make that type of thing B<very> easy.  But let's assume you're either coming from a form on a static HTML page or that some other subroutine printed out the form.  Actually, let's assume you're printing it out from another subroutine and if you're not, you can make a subroutine and just suck in the static HTML page and return it easily enough.  Something like this:

  sub first_page {
    $output = <<_EOF_;
<html>
<head>
...
<!-- ERROR_MSG -->
_EOF_
    $output;
  }
  ...
    if ( $results->has_missing() || $results->has_invalid() ) {
      my ( $html, $fif );
      $html = first_page();
      $html =~ s/<!-- ERROR_MSG -->/$results->msgs/;
      # this is where HTML::FillInForm would come in handy - it will
      # pre-populate the form with the user's previous attempts
      $fif = HTML::FillInForm->new();
      $html = $fif->fill(
          'scalarref' => \$html,
          'fobject'   => $cgi
        );
      print $html;
      exit;
    }

Note the C<E<lt>!-- ERROR_MSG --E<gt>> tag in the HTML code.  You probably don't have that in there, but you can put that in there as a template tag to put the dynamic error message in later.

Ok, so now let's hammer out the dfv profile.  Let's first start off by saying we have 4 fields named username, email, password1 and password2 and all the fields are required.  So here's how that would look:

  sub dfv_profile {
    return {
        'required' => [ qw( username email password1 password2 ) ],
        # FYI, I always leave a comma at the end to make future changes easy
      };
  }

So if the user doesn't provide any of those fields (or if the field only contains spaces), it will trigger C<has_missing()> to return true.

So this is great!  Now you have a system in place to verify that the user is providing all of the information in an user-friendly method as well as easy-to-maintain/read code for you.

Now the pointed-haired boss steps into your office and says "Hey, we're getting a lot of registrations with bogus email information and Marketing can't spam 'em!  Fix that code to only accept valid email addresses."  This is where I<constraints> comes into the picture.  Constraints take a closer look at the input to see if it's valid.  If not, it will trigger C<has_invalid()> to return true.

  sub dfv_profile {
    return {
        'required'    => [ qw( username email password1 password2 ) ],
        'constraints' => {
            'email' => qr/\w+\@\w+\.\w+/,
          },
      };
  }

This is saying that the C<email> field is valid only when the regex pattern fits the input.  Now I just gave a very rough (and probably inaccurate) pattern, just so you get the idea.  So many people have come across this type of thing, that there's a I<shortcut> for the bona-fide and accurate email address pattern that's built into the dfv package (you can see L<Data::FormValidator::Constraints> for other built-in constraint types, too).

  ...
            'email' => 'email',
  ...

Pretty sweet, huh?  There are other things you can do on the right-hand side of a constraint, too.  Right now, you've seen a regexp pattern and using a built-in constraint, but you can also point to a subroutine and do your own methodology:

  ...
            'email' => sub {
                my $email = shift;
                if ( $email =~ /purdy\.info$/ ) {
                  # only accepting emails from my domain
                  return 1;
                } else {
                  return 0;
                }
              },
  ...

You could also bump that subroutine outside the data structure somewhere and refer to it by name:

  ...
            'email' => \&my_domain_email(),
  ...
  sub my_domain_email {
    ...
  }

Lastly, either you or the PHB (pointed-haired boss) will note that password1 and password2 should be confirmed to be the same thing, to make sure the user didn't typo the password wrong.  I think you can handle that yourself, given the ammo I've given above, but it does use a twist, so let me introduce it.  First off, it would be a C<constraint> and it would point to a subroutine, but there are multiple parameters involved: C<password1> and C<password2>.  Whenever that happens, you define the constraint like so:

  ...
        'constraints' => {
            'email'     => 'email',
            'password1' => {
                'constraint' => "check_passwords",
                'params'     => [ qw( password1 password2 ) ],
              },
          },
  ...

So what this is saying is to check C<password1>, but instead of pointing to a regexp pattern, a built-in constraint or a subroutine, it's actually pointing to a more complex hashref.  Within that hashref is C<constraint>, which could be confusing, but it simply is the name of a subroutine that will be called.  Also within the hashref is C<params>, which is a list of the parameters to pass in as arguments to the subroutine.  So then somewhere in your code, you'll have the C<check_passwords> method:

  sub check_passwords {
    my ( $pw1, $pw2 ) = @_;
    if ( $pw1 eq $pw2 ) {
      return 1;
    } else {
      return 0;
    }
  }

=head1 TODO

This is just an early release of this tutorial - we're using the release early & often mentality, so there's still a few things left to do.  We want to address the msgs part of the response and then get into the more complicated aspects of dfv.

=head1 SEE ALSO

L<Data::FormValidator> and the dfv mailing list: L<http://lists.sourceforge.net/lists/listinfo/cascade-dataform>

=head1 AUTHORS

Originally written by 
T. M. Brannon, <tbone@cpan.org>

And re-written by
William McKee, <william@knowmad.com> and Jason Purdy, <jason@purdy.info>

=head1 LICENSE

Copyright (C) 2004 William McKee, <william@knowmad.com> and Jason Purdy, <jason@purdy.info>

This library is free software. You can modify and or distribute it under the same terms as Perl itself.

=cut


