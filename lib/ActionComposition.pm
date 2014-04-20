package ActionComposition;
use Mojo::Base 'Mojolicious';

sub startup {
  my $self = shift;

  my $r = $self->routes;
  $r->get('/')->to('example#welcome');
  $r->get('/login')->to('example#login');
  $r->get('/logout')->to('example#logout');
  $r->get('/private1')->to('example#private1');
  $r->get('/private2')->to('example#private2');
}

1;
