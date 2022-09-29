#1664323200
use Term::ANSIColor;
use Data::Dumper;

sub compare{
   $an = substr $a, -1;
   $bn = substr $b, -1;
   if($an eq "L"){
     $an = 7;
   }
   else{
     $an = int($an);
   }
   if($bn eq "L"){
     $bn = 7;
   }
   else{
     $bn = int($bn);
   }
   if($an < $bn){
      return -1;
   }elsif($an == $bn){
      return 0;
   }else{
      return 1;                       
   }
}

sub guess_word{
  while(1){
    print("Enter your guess: ");
    chomp(my $guess = <STDIN>);
    $guess = lc($guess);
    #print($guess);
    if(length($guess) == 5){
      if(check_word($guess)){
        return $guess;
      }
      else{
        print("\nWord entered not in the word list\n");
      }
    }
    else{
      print("\nWords guessed must be 5 letters long\n");
    }
  }
}

sub check_word{
  my ($guess) = @_;
  my $res = system "grep -e $guess /Users/jcomonitski/Desktop/Perl/perl-dle/words.txt";
  return $res == 0 ? 1 : 0;
}

sub get_next_day{
  my ($now, $today) = @_;
  while($today < $now){
    $today = $today + 86400;
  }
  $res = $today - 86400;
  return $res;
}

sub check_players{
  my ($user, $today) = @_;
  my $now = time();
  $today = int($today);
  my $tomorrow = $today + 86400;
  if($now >= $tomorrow){
    #new day
    open(FH, '>', '/Users/jcomonitski/Desktop/Perl/perl-dle/user.txt') or die $!;
    my $new_date = get_next_day($now, $today);
    print FH "$new_date";
    close FH;
    return 0;
  }
  elsif($now < $tomorrow && $now >= $today){
    my $res = system "grep -e $user /Users/jcomonitski/Desktop/Perl/perl-dle/user.txt";
    return $res == 0 ? 1 : 0;
  }
}

sub get_game_state{
  my %state = { scores => () };

  open(FH, '<', '/Users/jcomonitski/Desktop/Perl/perl-dle/user.txt') or die $!;
  my $count = 0;
  while(<FH>){
    if($count == 0){
      $state{"today"} = $_;
    }
    else{
      chomp(my $tmp = $_);
      push(@{$state{"scores"}}, ($tmp));
    }
    $count++;
  }
  close FH;
  return %state
}

sub print_title{
  print color 'green';
  print("    ____            __           ____   \n");
  print("   / __ \\___  _____/ /     ____/ / /__ \n");
  print("  / /_/ / _ \\/ ___/ /_____/ __  / / _ \\\n");
  print(" / ____/  __/ /  / /_____/ /_/ / /  __/\n");
  print("/_/    \\___/_/  /_/      \\____/_/\\___/ \n");
  print color 'reset';
  print("Worlde in Perl!\n\n");
}

sub select_word{ 
  my ( $today ) = @_;
  my $stop = (int($today / 86400) - 19263) + 6;
  open(FH, '<', '/Users/jcomonitski/Desktop/Perl/perl-dle/sol.txt') or die $!;
  my $count = 0;
  while(<FH>){
    if($count == $stop){
      close FH;
      return $_; 
    } 
    $count++;
  }
  close FH;
  return "Hello";
}

sub add_user{
  my ($user, $score) = @_;
  open(FH, '>>', '/Users/jcomonitski/Desktop/Perl/perl-dle/user.txt') or die $!;
  print FH "\n$user $score";
  close FH;
}

sub update_board{
  my ($guess, $solution, $index) = @_;
  my @row;
  if($index == 0){
    push(@row, ("+---+---+---+---+---+\n"));
  }
  
  my %Letters;
  for(my $i = 1; $i <= 5; $i++){
    my $char = substr($solution, $i-1,1);
    if(! exists $Letters{$char}){
      $Letters{$char} = 1;
    }
    else{
      $Letters{$char} = $Letters{$char} + 1;
    }
  }

  my $res = "|";
  my @resRow = ("| ");
  for(my $i = 1; $i <= 5; $i++){
    my $guess_char = substr($guess, $i-1, 1);
    my $solution_char = substr($solution, $i-1, 1);
    if($guess_char eq $solution_char){
      #Green
      $res = "$res*$guess_char*|";
      push(@resRow, ({Letter => $guess_char, Color => 'green'}, " | "));
      $Letters{$guess_char} = $Letters{$guess_char} - 1;
    }
    elsif(index($solution, $guess_char) != -1){
      #Yellow 
      if($Letters{$guess_char} != 0){
        $res = "$res#$guess_char#|";
        push(@resRow, ({Letter => $guess_char, Color => 'yellow'}, " | "));
        $Letters{$guess_char} = $Letters{$guess_char} - 1;
      }
      else{
        #Gray
        $res = "$res $guess_char |";
        push(@resRow, ({Letter => $guess_char, Color => 'white'}, " | "));
      }
    }
    else{
      #Gray
      $res = "$res $guess_char |";
      push(@resRow, ({Letter => $guess_char, Color => 'white'}, " | "));
    }
  }
  push(@resRow, ("\n"));
  $res = "$res\n";
  push(@row, (@resRow));
  push(@row, ("+---+---+---+---+---+\n"));
  return @row;
}

sub print_board{
  system "clear";
  print_title();
  my (@board) = @_;
  my $size = @board;
  for(my $i = 0; $i < $size; $i++){
    if(exists ${$board[$i]}{"Letter"}){
      print color ${$board[$i]}{"Color"};
      print(${$board[$i]}{"Letter"});
      print color "reset";
    }
    else{
      print($board[$i]);
    }
  }
}

sub print_score{
  my (@scores) = @_;
  @scores = @{$scores[0]};
  @scores = sort compare @scores;
  my $size = @scores;
  print("\n+------------------+\n");
  print("|  ");
  print color "green";
  print("Today's Scores");
  print color 'reset';
  print("  |\n");
  print("+------------------+\n");
  for(my $i = 1; $i < $size+1; $i++){
    print("$i: $scores[$i-1]\n");
  } 
}

#Game Prep
my $user = $ENV{ LOGNAME };
my %state = get_game_state();
my $has_user_played = check_players($user, $state{today});
chomp(my $solution = select_word($state{today}));
system "clear";

#Game Loop
if($has_user_played == 0){
  print_title();
  my @board;
  for(my $i = 0; $i < 6; $i++){
    my $guess = guess_word();

    my @next_row = update_board($guess, $solution, $i);
    push(@board, @next_row);

    print_board(@board);
    if($guess eq $solution){
      print("\n$user is a WINNER!\n");
      add_user($user, $i+1);
      my $tmp = $i+1;
      $i = 6
    }
    if($i == 5){
      print("\n$user is a LOSER!\nThe solution was ");
      print color "green";
      print("$solution\n");
      print color 'reset';
      add_user($user, "L");
    }
  }

  %state = get_game_state();
  print_score(\@{$state{scores}});
}
else{
  print("You've already played today's Perl-dle\n");
  print_score(\@{$state{scores}});
}
