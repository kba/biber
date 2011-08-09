# -*- cperl -*-
use strict;
use warnings;
use utf8;
no warnings 'utf8';

use Test::More tests => 1;

use Biber;
use Biber::Output::BBL;
use Log::Log4perl qw(:easy);
chdir("t/tdata");

# Set up Biber object
my $biber = Biber->new(noconf => 1);
Log::Log4perl->easy_init($ERROR);
$biber->parse_ctrlfile('biblatexml.bcf');
$biber->set_output_obj(Biber::Output::BBL->new());

# Options - we could set these in the control file but it's nice to see what we're
# relying on here for tests

# Biber options
Biber::Config->setoption('fastsort', 1);
Biber::Config->setoption('sortlocale', 'C');

# Now generate the information
$biber->prepare;
my $out = $biber->get_output_obj;
my $section = $biber->sections->get_section(0);
my $main = $section->get_list('MAIN');
my $bibentries = $section->bibentries;

my $l1 = q|  \entry{BulgakovRozenfeld:1983}{book}{}
    \true{morelabelname}
    \name{labelname}{3}{}{%
      {{hash=7b4da3df896da456361ae44dc651770a}{Булгаков}{Б\bibinitperiod}{Павел\bibnamedelima Георгиевич}{П\bibinitperiod\bibinitdelim Г\bibinitperiod}{}{}{}{}}%
      {{hash=ee55ff3b0e4268cfb193143e86c283a9}{Розенфельд}{Р\bibinitperiod}{Борис-ZZ\bibnamedelima Aбрамович}{Б\bibinithyphendelim Z\bibinitperiod\bibinitdelim A\bibinitperiod}{Билл}{Б\bibinitperiod}{}{}{}{}}%
      {{hash=e708d5a31534e937578abf161c867a25}{Aхмедов}{A\bibinitperiod}{Ашраф\bibnamedelima Ахмедович}{А\bibinitperiod\bibinitdelim А\bibinitperiod}{}{}{}{}}%
    }
    \true{moreauthor}
    \name{author}{3}{}{%
      {{hash=7b4da3df896da456361ae44dc651770a}{Булгаков}{Б\bibinitperiod}{Павел\bibnamedelima Георгиевич}{П\bibinitperiod\bibinitdelim Г\bibinitperiod}{}{}{}{}}%
      {{hash=ee55ff3b0e4268cfb193143e86c283a9}{Розенфельд}{Р\bibinitperiod}{Борис-ZZ\bibnamedelima Aбрамович}{Б\bibinithyphendelim Z\bibinitperiod\bibinitdelim A\bibinitperiod}{Билл}{Б\bibinitperiod}{}{}{}{}}%
      {{hash=e708d5a31534e937578abf161c867a25}{Aхмедов}{A\bibinitperiod}{Ашраф\bibnamedelima Ахмедович}{А\bibinitperiod\bibinitdelim А\bibinitperiod}{}{}{}{}}%
    }
    \list{language}{1}{%
      {Russian}%
    }
    \list{location}{1}{%
      {Москва}%
    }
    \list{publisher}{1}{%
      {Наука}%
    }
    \strng{namehash}{80e524d8402a5619e59ea67ea2d937a5}
    \strng{fullhash}{afcf3a11058ba0a3fc7609c2a29ae6da}
    \field{sortinit}{Б}
    \field{labelyear}{1983}
    \field{eventday}{16}
    \field{eventendday}{17}
    \field{eventendmonth}{05}
    \field{eventendyear}{1990}
    \field{eventmonth}{05}
    \field{eventyear}{1990}
    \field{origday}{02}
    \field{origmonth}{04}
    \field{origyear}{1985}
    \field{pagetotal}{240}
    \field{series}{Научно-биографическая литература}
    \field{title}{Mukhammad al-Khorezmi. Ca. 783 – ca. 850}
    \field{urlday}{01}
    \field{urlendyear}{}
    \field{urlmonth}{07}
    \field{urlyear}{1991}
    \field{year}{1983}
  \endentry

|;

is( $out->get_output_entry($main, 'bulgakovrozenfeld:1983'), $l1, 'Basic BibLaTeXML test - 1') ;
