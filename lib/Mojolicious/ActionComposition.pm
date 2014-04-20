package Mojolicious::ActionComposition;

use Mojo::Util qw/ monkey_patch /;

require Exporter;
our @ISA = qw/ Exporter /;
our @EXPORT = qw/ Action Async Authenticated WithPermission /;

sub go {
  my ($controller, $inner) = @_;
  my $i = $inner;
  while($i) {
    my $res = $i->($controller) if ref($i) eq 'CODE';
    $i = ref($res) eq 'CODE' ? $res : undef;
  }
  return undef;
}

sub Action($$) {
  my ($action, $inner) = @_;
  monkey_patch caller, $action => sub { go(shift, $inner) }
}

sub Async(&) {
  my $inner = shift;
  return sub {
    my $controller = shift;
    $controller->render_later;
    go($controller, $inner);
  }
}

sub Authenticated(&) {
  my $inner = shift;
  return sub {
    my $controller = shift;
    if($controller->session('auth')) {
      go($controller, $inner);
    } else {
      $controller->render_exception('Unauthenticated');
    }
    return undef;
  }
}

sub WithPermission($&;&) {
  my ($permission, $inner, $error) = @_;
  return sub {
    my $controller = shift;
    if($permission eq 'blog.delete') {
      go($controller, $inner);
    } else {
      $error ? go($controller, $error) : $controller->render_exception('Unauthorised');
    }
    return undef;
  }
}

1;