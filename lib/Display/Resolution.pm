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

# sorted by horizontal pixel size, then vertical size, then name
our %res_sizes = (
    'QQVGA'     => '160x120', # one fourth QVGA
    'qqVGA'     => '160x120',

    'HQVGA'     => '240x160', # half QVGA

    'CGA1'      => '320x200',
    'QVGA'      => '320x240', # one quarter VGA

    'NTSC VCD'  => '352x240', # video cd
    'PAL VCD'   => '352x288',
    'SECAM VCD' => '352x288',

    'WQVGA'     => '400x240', # XXX there are actually variants of WQVGA, apple's ipod nano 7G's WQVGA is 432x240, etc.
    'qSVGA'     => '400x300', # quarter SVGA

    'HVGA'      => '480x320', # half VGA. XXX there are actually variants of HVGA, e.g. 480x270, 640x240, ...
    'NTSC SVCD' => '480x480', # super video cd
    'PAL SVCD'  => '480x576',
    'SECAM SVCD'=> '480x576',

    'KVCDx3 480p'  => '528x480',
    'KVCDx3 576p'  => '528x576',
    'KVCDx3A 480p' => '544x480',
    'KVCDx3A 576p' => '544x576',

    'CGA2'      => '640x200',
    'EGA'       => '640x350',
    'MCGA'      => '640x480',
    'SD'        => '640x480',
    'VGA'       => '640x480',

    'HGC'       => '720x348',
    'MDA'       => '720x350',
    '480p'      => '720x480',

    'WGA'       => '768x480',
    'WVGA'      => '768x480',
    '576p'      => '720x576',

    'SVGA'      => '800x600',
    'UVGA'      => '800x600',

    'FWVGA'     => '854x480',

    'DGA'       => '960x640', # double-size vga
    'DVGA'      => '960x640', # double-size vga
    'qHD'       => '960x540', # one quarter of full HD

    'WSVGA'     => '1024x600', # XXX WSVGA also has resolution 1024x576
    'XGA'       => '1024x768',

    '720p'      => '1280x720',
    'HD'        => '1280x720',
    'WXGA 16:9' => '1280x720',
    'SXGA'      => '1280x1024',

    'XGA+'      => '1152x864',

    'WXGA 5:3'  => '1280x768',
    'WXGA 16:10'=> '1280x800',

    'WXGA+'     => '1440x900',

    'HD+'       => '1600x900',
    'UXGA'      => '1600x1200',

    '1080p'     => '1920x1080',
    'FHD'       => '1920x1080',
    'Full HD'   => '1920x1080',
    'WUXGA'     => '1920x1200',

    'Cinema 2K' => '2048x1080',
    'DCI 2K'    => '2048x1080',

    '1440p'     => '2560x1440',
    'QHD'       => '2560x1440', # four times HD
    'WQHD'      => '2560x1440',
    'WQXGA'     => '2560x1600',

    'QSXGA+'    => '2800x2100',

    'UWQHD'     => '3440x1440',

    'QHD+'      => '3200x1800',
    'WQXGA+'    => '3200x1800',
    'WQSXGA'    => '3200x2048',
    'QUXGA'     => '3200x2400',

    'UW4K'      => '3840x1600',
    '2160p'     => '3840x2160', # blu-ray
    '4K'        => '3840x2160',
    '4K UHD'    => '3840x2160',
    '4K UHD-1'  => '3840x2160',
    'UHD-1'     => '3840x2160',
    'UHD 4K'    => '3840x2160',
    'UHDTV-1'   => '3840x2160',
    'WQUXGA'    => '3840x2400',

    'Cinema 4K' => '4096x2160',
    'DCI 4K'    => '4096x2160',
    'HXGA'      => '4096x3072',
    'True 4K'   => '4096x2160',

    'UW5K'      => '5120x2160',
    '5K'        => '5120x2880',
    'UHD+'      => '5120x2880',
    'WHXGA'     => '5120x3200',
    'HSXGA'     => '5120x4096',

    'WHSXGA'    => '6400x4096',
    'HUXGA'     => '6400x4800',

    '4320p'     => '7680x4320',
    '8K'        => '7680x4320',
    '8K UHD'    => '7680x4320',
    '8K UHD-2'  => '7680x4320',
    'UHD-2'     => '7680x4320',
    'UHD 8K'    => '7680x4320',
    'UHDTV-2'   => '7680x4320',
    'WHUXGA'    => '7680x4800',

    'Cinema 8K' => '8192x4320',
    'DCI 8K'    => '8192x4320',
    'True 8K'   => '8192x4320',

    'UW10K'     => '10240x4320',

    '16K'       => '15360x8640',
    '16K UHD'   => '15360x8640',
    '8640p'     => '15360x8640',
    'UHD 16K'   => '15360x8640',

    'Cinema 16K'=> '16384x8640',
    'DCI 16K'   => '16384x8640',
    'True 16K'  => '16384x8640',
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
        schema => ['any', of=>['str', ['array*', of=>'str*']]],
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

=head1 SEE ALSO

L<https://en.wikipedia.org/wiki/Display_resolution>

L<https://en.wikipedia.org/wiki/List_of_common_resolutions>
