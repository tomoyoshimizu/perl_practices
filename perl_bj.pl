use strict;
use warnings;
use List::Util;

## デッキ・カードの準備
sub init_deck {
  my @deck;

  my @suits = ("spades", "hearts", "diams", "clubs");
  my @ranks = (2..10);
  push(@ranks, ("J", "Q", "K", "A"));

  foreach my $suit (@suits){
    foreach my $rank (@ranks){
      my $card = {is_open => 0, suit => $suit, rank => $rank};
      push(@deck, $card)
    }
  }

  return List::Util::shuffle @deck;
}

## カードを引く
sub draw_card {
  my ($person, $deck, $order) = @_;

  foreach (@$order) {
    my $card = shift(@$deck);
    $card->{is_open} = $_;
    push(@{$person->{hand}}, $card);
  }
}

## スコア計算
sub calculate_score {
  my ($person) = @_;

  my $score = 0;
  my $num_of_ace = 0;

  foreach my $card (@{$person->{hand}}) {
    next unless $card->{is_open};
    if ($card->{rank} eq "A") {
      $num_of_ace += 1;
    } elsif ($card->{rank} =~ /^[JQK]$/) {
      $score += 10;
    } else {
      $score += $card->{rank}
    }
    while ($num_of_ace > 0) {
      $score += $score <= 10 ? 11 : 1;
      $num_of_ace--;
    }
  }

  return $score;
}

## コンソール出力
sub message {
  my ($message) = @_;

  sleep(1);
  printf "%s\n", $message;
}

sub show_table {
  my $symbols = {spades => "♠", hearts => "♥", diams => "♦", clubs => "♣"};

  local *line = sub {
    my ($name) = @_;
    return defined $name ? $name."-" x (64 - length($name)) : "-" x 64;
  };

  local *hand = sub {
    my ($person) = @_;
    my @result;
    foreach (@{$person->{hand}}) {
      push(@result, $_->{is_open} ? $symbols->{$_->{suit}}.$_->{rank} : "???");
    }
    return join(',', @result);
  };

  foreach (@_) {
    printf "%s\n", &line($_->{name});
    printf "%s\n", "hand:".&hand($_);
    printf "%s\n", "score:".&calculate_score($_);
    printf "%s\n", &line();
  }
}

## ゲーム開始
my @deck = &init_deck;
my $dealer = {name => "DEALER", hand => [], judge_score => 0};
my $player = {name => "YOU",    hand => [], judge_score => 0};
my $count;

&draw_card($dealer, \@deck, [1, 0]);
&draw_card($player, \@deck, [1, 1]);

&message("Game start!");
&message("DEALER dealt cards.");
&show_table($dealer, $player);

$count = 1;
while ($count) {
  if (&calculate_score($player) == 21) {
    &message(($count == 1) ? 'You get natural 21!' : 'You get 21!');
    $player->{judge_score} = ($count == 1) ? 22 : 21;
    last;
  } elsif (&calculate_score($player) > 21) {
    &message('You bust!');
    $player->{judge_score} = -1;
    last;
  }

  &message('Would you like to draw another card? [y(hit)/n(stand)]');
  my $command = <STDIN>;
  chomp($command);

  if ($command =~ /^(y|yes|hit)$/i) {
    &draw_card($player, \@deck, [1]);
    &message('You draw card.');
    &show_table($dealer, $player);
  } elsif ($command =~ /^(n|no|stand)$/i) {
    &message('You stand.');
    $player->{judge_score} = &calculate_score($player);
    last;
  } else {
    &message('Invalid command.');
  }

  $count += 1;
}

$_->{is_open} = 1 foreach @{$dealer->{hand}};
&message('Hole card open!');
&show_table($dealer, $player);

$count = 1;
while ($count) {
  if (&calculate_score($dealer) == 21) {
    &message(($count == 1) ? 'DEALER get natural 21!' : 'DEALER get 21!');
    $dealer->{judge_score} = ($count == 1) ? 22 : 21;
    last;
  } elsif (&calculate_score($dealer) > 21) {
    &message('DEALER bust!');
    $dealer->{judge_score} = 0;
    last;
  }

  last if &calculate_score($player) == 22;

  if (&calculate_score($dealer) < 17) {
    &draw_card($dealer, \@deck, [1]);
    &message('DEALER draw card.');
    &show_table($dealer, $player);
  } else {
    $dealer->{judge_score} = &calculate_score($dealer);
    last;
  }

  $count += 1;
}

if ($player->{judge_score} > $dealer->{judge_score}) {
  &message('You win!')
} elsif ($player->{judge_score} == $dealer->{judge_score}) {
  &message('Draw game.')
} else {
  &message('You lose.')
}
