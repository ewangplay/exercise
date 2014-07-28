#!c:\perl\bin\perl.exe
################################################################################
#
#   ���ظ���ֽ���Ӱ�
#   get_e-paper.pl -n paperName
#   -l      ��ʾ��ǰ֧�ֱ�ֽ,��-n�����֧�ֵ�paperName
#
################################################################################
use warnings;
use strict;
use Getopt::Std;
use LWP;
use URI;
use HTTP::Status;
use Switch;
#use LWP::Debug qw(+);
#use Data::Dumper;

use constant    url_dfwb=>'http://dfwb.njnews.cn/';

sub usage(){
    my $u=<<'END';
    get_e-paper.pl -n paperName
    -l      ��ʾ��ǰ֧�ֱ�ֽ,��-n�����֧�ֵ�paperName
    zdl0812@163.com
END
    print $u;
    print "\n\n����س��˳�����!\n";
    <>;
    exit -1;
}

sub showPaperList(){
    my $list=<<"END";
    -n dfwb    --��������
    
END
    print $list;
    print "\n\n����س��˳�����!\n";
    <>;
    exit 0;
}

#��Ҫ����url����·��
sub downUrlFile{
    my ($list) = shift;
    my $downloadFile = substr($list,rindex($list,'/')+1);
    
    use LWP::UserAgent;
    my $us_download = LWP::UserAgent->new;
    #$us_download->timeout(10);
    #$us_download->agent('ReportsBot/1.01');
    #
    #defined ( my $down_child_id = fork() ) or die "Fail to fork $!\n";
    #my $downloadFile_tmp = $downloadFile.'-'.$down_child_id;
    #if ($down_child_id) {#������
    #    print "�����Ǹ�����! $$\n";
    #    print "������ʱ�ļ�Ϊ: $downloadFile_tmp\n";
    #    sleep 5;
    #    while ( -e $downloadFile_tmp ) {
    #        my $size = (-s $downloadFile_tmp);
    #        print "�Ѿ�ȡ���ļ���С: $size bytes\n";
    #        sleep 1;
    #    }
    #} else { #�ӽ���
    #    print "�������ӽ���! $$\n";
    #    if ($us_download->mirror($list, $downloadFile)) {
    #        print "����PDF��ֽ�ɹ�: $downloadFile\n";
    #    }
    #}
    
    if ($us_download->mirror($list, $downloadFile)) {
        print "����PDF��ֽ�ɹ�: $downloadFile\n";
    }
    
    return $downloadFile;
}

sub downloadPDF{
    my $url = shift;
    
    my $browser = LWP::UserAgent->new;

    my $response = $browser->get($url);
    
    die "Can't get $url -- ", $response->status_line
        unless $response->is_success;
    
    #ȡ����ҳ��������,�������ձ�ֽ��תҳ��
    my $html = $response->content;
    #print $html,"\n";
    
    if( $html =~ m/<META HTTP-EQUIV="REFRESH" CONTENT="0; URL=(.+?)">/ ){
        $url = URI->new_abs( $1, $response->base );
        print "$url\n";
    }else{
        print "û��ƥ�䵽��Ҫ��ת�ĵ��ձ�ֽ��ҳ!ȡ������Ϊ: \n$html\n";
        exit -1;
    }
    
    #��ʵ�ʵ�����ҳ�л�ȡPDF�����б�
    $response = $browser->get($url);
    die "Can't get $url -- ", $response->status_line
        unless $response->is_success;
    
    $html = $response->content;
    #print $html,"\n";
    my $paper_page=0;
    while( $html =~ m/<a href=(.+?)>/g ) {  
        my $u=$1;
        if ($u =~ m/\_pdf\.pdf/){
            #print $u ,"\n";
            my $pdf_u = URI->new_abs( $u, $response->base );
            print $pdf_u,"\n";
            my $pdf_file = &downUrlFile($pdf_u);
            $paper_page++;
            #exit if $paper_page == 3;
        }
    }

    
    exit;
}

sub downloadPaper{
    my ($parerName) = shift;
    
    switch($parerName){
        case "dfwb" {&downloadPDF(url_dfwb)}
        #case ""    {}
        else        {print "��ʱ��֧�������ֽ������!\n"}
    }
}

sub main{
    my %CmdOpertion;
    getopts('n:l', \%CmdOpertion);
    
    my $OptNum = keys %CmdOpertion;
    if ($OptNum != 1){
        print "������������: \$OptNum=$OptNum\n";
        &usage;
    }
    
    &showPaperList if (defined $CmdOpertion{l});
    
    &downloadPaper($CmdOpertion{n}) if (defined $CmdOpertion{n});
}
&main;

