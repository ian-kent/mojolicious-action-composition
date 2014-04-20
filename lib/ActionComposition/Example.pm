package ActionComposition::Example;
use Mojo::Base 'Mojolicious::Controller';

use Mojolicious::ActionComposition;

my $i = 1;

Action 'welcome' => sub {
  my $self = shift;
  $self->render(text => $i++);
};

Action 'login' => Async {
  my $self = shift;
  Mojo::IOLoop->timer(0.25 => sub {
    $self->session(auth => 1);
    $self->render(text => $i++);
  });
};

Action 'logout' => sub {
  my $self = shift;
  delete $self->session->{auth};
  $self->render(text => $i++);
};

Action 'private1' => Async { Authenticated {
  WithPermission 'blog.post' => sub {
    my $self = shift;
    $self->render(text => $i++);
  }, sub {
    my $self = shift;
    $self->render(text => 'not authenticated');
  }
}};

Action 'private2' => Async { Authenticated {
  my $self = shift;
  Mojo::IOLoop->timer(0.25 => sub {
    $self->render(text => $i++);
  });
}};

1;
