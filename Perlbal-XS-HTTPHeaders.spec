name:      perl-Perlbal-XS-HTTPHeaders
summary:   perl-Perlbal-XS-HTTPHeaders - Perlbal acceleration module for header handling written in C++/XS
version:   0.18
release:   1
vendor:    Brad Fitzpatrick <brad@danga.com>
packager:  Jonathan Steinert <rpm@hachi.kuiki.net>
license:   Artistic
group:     Applications/CPAN
buildroot: %{_tmppath}/%{name}-%{version}-%(id -u -n)
source:    Perlbal-XS-HTTPHeaders-%{version}.tar.gz
buildrequires: perl-Perlbal
requires:  perl-Perlbal

%description
Perlbal acceleration module for header handling written in C++/XS

%prep
rm -rf "%{buildroot}"
%setup -n Perlbal-XS-HTTPHeaders-%{version}

%build
%{__perl} Makefile.PL PREFIX=%{buildroot}%{_prefix}
make all
make test

%install
make pure_install

[ -x /usr/lib/rpm/brp-compress ] && /usr/lib/rpm/brp-compress


# remove special files
find %{buildroot} \(                    \
       -name "perllocal.pod"            \
    -o -name ".packlist"                \
    -o -name "*.bs"                     \
    \) -exec rm -f {} \;

# no empty directories
find %{buildroot}%{_prefix}             \
    -type d -depth -empty               \
    -exec rmdir {} \;

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files
%defattr(-,root,root)
%{_mandir}/man3/*
%{_libdir}/perl5/*
