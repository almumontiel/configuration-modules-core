# ${license-info}
# ${developer-info}
# ${author-info}

#
# ofed - NCM OFED configuration component
#
# Configure the ntp time daemon
#
################################################################################

package NCM::Component::ofed;

#
# a few standard statements, mandatory for all components
#

use strict;
use LC::Check;
use NCM::Check;
use NCM::Component;
use vars qw(@ISA $EC);
@ISA = qw(NCM::Component);
$EC=LC::Exception::Context->new->will_store_all;

use CAF::FileWriter;

my $base = '/software/components/ofed/openib';

use constant OPENIBCONFIG => "/etc/infiniband/openib.conf";
use constant OPENIBOPTIONS => qw(
    onboot
    renice_ib_mad
    set_ipoib_cm
    set_ipoib_channels
    srpha_enable
    srp_daemon_enable
    ipoib_mtu
    run_sysctl
    run_affinity_tuner
    node_desc
    node_desc_time_before_update
);
use constant OPENIBMODULES => qw(
    ucm
    rdma_cm
    rdma_ucm
    ipoib
    e_ipoib
    sdp
    srp
    srpt
    rds
    iser
    mlx4_vnic
    mlx4_fc
);
use constant OPENIBHARDWARE => qw(
    mthca
    mlx4
    mlx5
    mlx_en
    ipath
    qib
    qlgc_vnic
    cxgb3
    nes
);

##########################################################################
sub Configure {
##########################################################################

    my ($self,$config)=@_;

    my ($result,$tree,$contents);

    # write the config file
    ## check for location first
    my $cfg = OPENIBCONFIG;
    if ($config->elementExists("$base/config")) {
        $cfg = $config->getValue("$base/config");
    }
    ## for now, warn when using non-default location
    $self->info("Using non-default loaction $cfg") if ( ! ($cfg eq OPENIBCONFIG) );

    my $cfgfh = CAF::FileWriter->new( $cfg,
                                      backup => ".old",
                                      mode => 0644,
                                      log => $self,
                                    );

    # walk through the openib parts and generate the config

    print $cfgfh "#\n# File generated by ncm-ofed\n#\n";

    ## main options
    $self->getcfg($config,$cfgfh,"options",OPENIBOPTIONS);

    ## module options
    $self->getcfg($config,$cfgfh,"modules",OPENIBMODULES);

    ## hardware module options
    $self->getcfg($config,$cfgfh,"hardware",OPENIBHARDWARE);

    # TODO: opensm

    $cfgfh->close();

    return 1;
}

# simple function to convert the configuration tree into values
# most values are boolean that need to be converted in yes/no, some
# keys also have to get a LOAD suffix
sub getcfg {
    my ($self, $config, $cfgfh, $p, @options) = @_;

    print $cfgfh "\n";

    my $suff="_LOAD";
    $suff='' if ( $p eq "options");

    my $tr = $config->getElement("$base/$p")->getTree;
    foreach my $option (@options) {
        my $ans="no";

        if ($option eq "ipoib_mtu") {
            $ans=$tr->{$option};
        } else {
            $ans = "yes" if (exists($tr->{$option}) && $tr->{$option});
        };
        print $cfgfh uc($option)."$suff=$ans\n";
    }
    foreach my $option (keys(%$tr)) {
        $self->warn("Unknown option $option in $p") if (! (grep {$_ eq $option} @options));
    }
    print $cfgfh "\n";

}


# Required for end of module
1;
