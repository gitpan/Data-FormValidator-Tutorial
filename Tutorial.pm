package Data::FormValidator::Tutorial;

our $VERSION = sprintf '%s', q{$Revision: 1.3 $} =~ /\S+\s+(\S+)/ ;

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Data::FormValidator::Tutorial - Data::FormValidator tutorial

=head1 TUTORIAL

D::FV does two types of validation: existence and
readability. Existence means that a value exists that should
exist. Readability means that a value that exists is intelligible. For
example, if a field labeled C<website> has value of C<s)d--13>, then
it exists, but it is not readable.

Specification of data validation is done via a hashref which is known
as an input profile. Here are the keys which tell D::FV something. In
parenthesis is a description of what type of key it is.

=over 4

=item * required (existence)

This field basically does something like this:

 @missing = 
    grep { not defined $formdata{$_} } keys %{$profile{required}} ;

 @possibly_valid = 
    grep { defined $formdata{$_} } keys %{$profile{required}} ;

The fields are only possibly valid. They have to move through a 
readability test before they can be considered truly valid.

=item * optional (existence)

=item * required_regexp (existence)

This basically says that all fields which match the regular expression
are required.

 @missing = 
    grep { not defined $formdata{$_} or $_ =~ /$profile{required_regexp} } 
       keys %formdata;

 @possibly_valid = 
    grep { not defined $formdata{$_} and $_ =~ /$profile{required_regexp} } 
       keys %formdata;

=item * optional_regexp (existence)

This does the same except says that the fields are optional. Note that
a side effect of finding such an optional field will result in a
check of the
C<dependencies> and C<dependency_groups> parts of the input profile.

=item * dependencies (existence)

Only relates to optional fields. Since there are 2 types of ways that 
optional fields can show up, it has two ways of dealing with them, both shown
in this example:

 dependencies   => {
    "cc_no" => [ qw( cc_type cc_exp ) ],
    "pay_type" => {
	check => [ qw( check_no ) ],
    }
 },

In the first case, when the C<cc_no> is bound, then the fields C<cc_type>
and C<cc_exp> must also be bound. The second one is used when a field is bound
but the resulting dependencies vary based on what is bound. This will happen
if you have a pull-down menu for C<pay_type> and based on which one is chosen
certain dependencies follow.

=item * dependency_groups (existence)

This is used to say: "if neither field is filled, then fine, but if either
field is filled, then the other must be filled."

Speaking in terms far too haughty: the dependencies field dictates a 
uni-directional (hierarchical and asymmetric) dependency between an optional 
field and the fields which will be required upon fill in. 
The C<dependency_groups> field dictates a bidirectional (flat and symmetric)
dependency between the listed fields.

=item * defaults (existence - sort of)

This is a hash reference which contains defaults which should be
substituted if the user hasn't filled the fields. So I guess it deals more 
with non-existence rather than existence.
Key is
field name and value is default value which will be
returned in the list of valid fields.

=item * filters (neither)

This is a reference to an array of filters that will be applied to ALL
optional or required fields. This can be the name of a built-in filter
(trim,digit,etc) or an anonymous subroutine which should take one
parameter, the field value and return the (possibly) modified value.

=item * field_filters (neither)

Same as above, but it allows selective application of filters to 
particular fields.

=item * constraints (readability)

See manual for details.

=item * constraint_regexp_map (readability)

See manual for details.

=back

Given the two tests that this module does, it makes sense that the
return data would belong to one of 4 classes:

=over 4

=item * exists and is readable

Returned in C<$valid> position of return array (position 0)

=item * exists but is not readable

Returned in C<$invalid> position of return array (position 1)

=item * should exist but doesn't

Returned in C<$missing> position of return array (position 1)

Fields which should exist were specified either as C<required> or as one 
of the C<dependencies> which kicked in as a result of a bound 
optional field.

=item * shouldn't exist but does

This means that an unrecognized field was bound but no specification of it 
as required, optional, or dependent was made.

These are returned in the C<$unknown> array position.

=back

=head1 AUTHOR

T. M. Brannon, <tbone@cpan.org>

=cut
