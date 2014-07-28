#!c:\perl\bin\perl.exe
################################################################################
#
#   下载各大报纸电子版
#   get_e-paper.pl -n paperName
#   -l      显示当前支持报纸,即-n后可以支持的paperName
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
    -l      显示当前支持报纸,即-n后可以支持的paperName
    zdl0812@163.com
END
    print $u;
    print "\n\n输入回车退出程序!\n";
    <>;
    exit -1;
}

sub showPaperList(){
    my $list=<<"END";
    -n dfwb    --东方卫报
    
END
    print $list;
    print "\n\n输入回车退出程序!\n";
    <>;
    exit 0;
}

#需要传入url绝对路径
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
    #if ($down_child_id) {#父进程
    #    print "这里是父进程! $$\n";
    #    print "下载临时文件为: $downloadFile_tmp\n";
    #    sleep 5;
    #    while ( -e $downloadFile_tmp ) {
    #        my $size = (-s $downloadFile_tmp);
    #        print "已经取得文件大小: $size bytes\n";
    #        sleep 1;
    #    }
    #} else { #子进程
    #    print "这里是子进程! $$\n";
    #    if ($us_download->mirror($list, $downloadFile)) {
    #        print "下载PDF报纸成功: $downloadFile\n";
    #    }
    #}
    
    if ($us_download->mirror($list, $downloadFile)) {
        print "下载PDF报纸成功: $downloadFile\n";
    }
    
    return $downloadFile;
}

sub downloadPDF{
    my $url = shift;
    
    my $browser = LWP::UserAgent->new;

    my $response = $browser->get($url);
    
    die "Can't get $url -- ", $response->status_line
        unless $response->is_success;
    
    #取得首页链接内容,分析当日报纸跳转页面
    my $html = $response->content;
    #print $html,"\n";
    
    if( $html =~ m/<META HTTP-EQUIV="REFRESH" CONTENT="0; URL=(.+?)">/ ){
        $url = URI->new_abs( $1, $response->base );
        print "$url\n";
    }else{
        print "没有匹配到需要跳转的当日报纸首页!取得内容为: \n$html\n";
        exit -1;
    }
    
    #从实际当日主页中获取PDF下载列表
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
        else        {print "暂时不支持这个报纸的下载!\n"}
    }
}

sub main{
    my %CmdOpertion;
    getopts('n:l', \%CmdOpertion);
    
    my $OptNum = keys %CmdOpertion;
    if ($OptNum != 1){
        print "参数个数不足: \$OptNum=$OptNum\n";
        &usage;
    }
    
    &showPaperList if (defined $CmdOpertion{l});
    
    &downloadPaper($CmdOpertion{n}) if (defined $CmdOpertion{n});
}
&main;

