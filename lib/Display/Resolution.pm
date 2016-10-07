package Display::Resolution;

# DATE
# VERSION

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       get_display_resolution_name
                       get_display_resolution_size
                       list_display_resolution_names
               );

our %SPEC;

our $size_re = qr/\A(\d+)\s*[x*]\s*(\d+)\z/;

our %res_sizes = (
    'QQVGA'     => '160x120', # one fourth QVGA
    'qqVGA'     => '160x120',

    'HQVGA'     => '240x160', # half QVGA

    'QVGA'      => '320x240', # one quarter VGA

    'WQVGA'     => '400x240',

    # XXX there are actually variants of HVGA, e.g. 480x270, 640x240, ...
    'HVGA'      => '480x320', # half VGA

    'VGA'       => '640x480',
    'SD'        => '640x480',

    '480p'      => '720x480',

    'WVGA'      => '768x480',
    'WGA'       => '768x480',

    'FWVGA'     => '854x480',

    '576p'      => '720x576',

    'qHD'       => '960x540', # one quarter of full HD

    'SVGA'      => '800x600',
    'UVGA'      => '800x600',

    # XXX WSVGA also has resolution 1024x576
    'WSVGA'     => '1024x600',

    'DGA'       => '960x640', # double-size vga

    'HD'        => '1280x720',
    '720p'      => '1280x720',
    'WXGA 16:9' => '1280x720',

    'XGA'       => '1024x768',

    'WXGA 5:3'  => '1280x768',

    'WXGA 16:10'=> '1280x800',

    'XGA+'      => '1152x864',

    'WXGA+'     => '1440x900',

    'HD+'       => '1600x900',

    'SXGA'      => '1280x1024',

    'Full HD'   => '1920x1080',
    'FHD'       => '1920x1080',
    '1080p'     => '1920x1080',

    'DCI 2K'    => '2048x1080',
    'Cinema 2K' => '2048x1080',

    'UXGA'      => '1600x1200',

    'WUXGA'     => '1920x1200',

    'QHD'       => '2560x1440', # four times HD
    'WQHD'      => '2560x1440',
    '1440p'     => '2560x1440',

    'UWQHD'     => '3440x1440',

    'WQXGA'     => '2560x1600',

    'WQXGA+'    => '3200x1800',
    'QHD+'      => '3200x1800',

    'UHD 4K'    => '3840x2160',
    '4K UHD'    => '3840x2160',
    'UHDTV-1'   => '3840x2160',
    '4K'        => '3840x2160',

    'DCI 4K'    => '4096x2160',
    'Cinema 4K' => '4096x2160',

    'UHD+'      => '5120x2880',
    '5K'        => '5120x2880',

    'UHD 8K'    => '7680x4320',
    '8K UHD'    => '7680x4320',
    'UHDTV-2'   => '7680x4320',
    '8K'        => '7680x4320',

    'UHD 16K'   => '15360x8640',
    '16K UHD'   => '15360x8640',
    '16K'       => '15360x8640',
);

my @res_names = sort keys %res_sizes;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Convert between display resolution size (e.g. 1280x720) '.
        'and name (e.g. HD, 720p)',
};

$SPEC{get_display_resolution_name} = {
    v => 1.1,
    summary => 'Get the known name for a display resolution size',
    description => <<'_',

Will return undef if there is no known name for the resolution size.

_
    args => {
        size => {
            schema => ['str*', match => $size_re],
            pos => 0,
        },
        width => {
            schema => ['posint*'],
        },
        height => {
            schema => ['posint*'],
        },
        all => {
            summary => 'Return all names instead of the first one',
            schema => 'bool',
            description => <<'_',

When set to true, an arrayref will be returned instead of string.

_
            cmdline_aliases => {a=>{}},
        },
    },
    args_rels => {
        choose_all => [qw/width height/],
        req_one    => [qw/size width/],
    },
    result => {
        schema => ['any*', of=>['str', ['array*', of=>'str*']]],
    },
    result_naked => 1,
    examples => [
        {
            summary => 'You can specify width and height ...',
            args    => {width => 640, height => 480},
        },
        {
            summary => '... or size directly (in "x x y" or "x*y" format)',
            args    => {size => "1280x720"},
        },
        {
            summary => "Return all names",
            args    => {size => "1280x720", all => 1},
        },
        {
            summary => "Unknown resolution size",
            args    => {size => "999x666"},
        },
    ],
};
sub get_display_resolution_name {
    my %args = @_;

    my $all = $args{all};

    my ($x, $y, $size);
    if (defined $args{size}) {
        ($x, $y) = $args{size} =~ $size_re;
    } else {
        $x = $args{width};
        $y = $args{height};
    }
    $size = "${x}x${y}";

    my @res;
    for my $name (@res_names) {
        if ($res_sizes{$name} eq $size) {
            push @res, $name;
            last unless $all;
        }
    }

    if ($all) {
        return \@res;
    } else {
        return $res[0];
    }
}

$SPEC{get_display_resolution_size} = {
    v => 1.1,
    summary => 'Get the size of a display resolution name',
    description => <<'_',

Will return undef if the name is unknown.

_
    args => {
        name => {
            schema => ['str*'],
            completion => sub {
                require Complete::Util;
                my %args = @_;
                Complete::Util::complete_hash_key(
                    word => $args{word},
                    hash => \%res_sizes,
                );
            },
            req => 1,
            pos => 0,
        },
#        all => {
#            summary => 'Return all names instead of the first one',
#            schema => 'bool',
#            description => <<'_',
#
#When set to true, an arrayref will be returned instead of string.
#
#_
#            cmdline_aliases => {a=>{}},
#        },
    },
    result => {
        #schema => ['any*', of=>['str', ['array*', of=>'str*']]],
        schema => 'str',
    },
    result_naked => 1,
    examples => [
        {
            args    => {name => 'VGA'},
        },
        {
            summary => 'Unknown name',
            args    => {name => 'foo'},
        },
    ],
};
sub get_display_resolution_size {
    my %args = @_;

    #my $all = $args{all};

    my $name = $args{name};

    return $res_sizes{$name};

    #my @res;
    #if ($all) {
    #    return \@res;
    #} else {
    #    return $res[0];
    #}
}

$SPEC{list_display_resolution_names} = {
    v => 1.1,
    result => {
        schema => ['hash*', of=>'str*'],
    },
    result_naked => 1,
    examples => [
        {args=>{}},
    ],
};
sub list_display_resolution_names {
    return \%res_sizes;
}

1;
# ABSTRACT:
