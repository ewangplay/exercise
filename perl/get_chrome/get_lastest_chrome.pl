#!c:\perl\bin\perl.exe

use LWP::Simple;
#use LWP::Debug qw(+);
use warnings;
use strict;
use Data::Dumper;

my $new_throme_url = q(http://build.chromium.org/buildbot/snapshots/chromium-rel-xp/LATEST);

my $use_proxy = 0;
if ( $use_proxy ) {
    #$ENV{HTTPS_PROXY}          = q(http://127.0.0.1:8080/);
    #$ENV{HTTPS_PROXY_USERNAME} = q(username);
    #$ENV{HTTPS_PROXY_PASSWORD} = q(passwd);
    
    use LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->agent('ReportsBot/1.01');
    
    #$ua->env_proxy;
    
    $ua->proxy(['http', 'ftp', 'https'], 'http://127.0.0.1:8080/');
    #$ua->credentials('127.0.0.1:8080', '域名称', 'username' => 'passwd');
    
    my $content = $ua->get($new_throme_url);
    die "Couldn't get it: $!" unless defined $content;
    print $content->status_line,"\n";
    my $new_chrome_version = $content->content;
    print '最新版本号为: ',$new_chrome_version,"\n" if ($content->status_line eq '200 OK');
    
    my $new_chrome_file = qq(http://build.chromium.org/buildbot/snapshots/chromium-rel-xp/$new_chrome_version/chrome-win32.zip);
    
    #启动子进程下载文件,主进程监控文件大小,显示进度
    defined ( my $down_child_id = fork() ) or die "Fail to fork $!\n";
    
    my $down_file = qq(chrome-win32-$new_chrome_version.zip);
    my $tmp_file = qq($down_file-$down_child_id);
    
    if ($down_child_id) {#父进程
        print "这里是父进程! $$\n";
        print "下载临时文件为: $tmp_file\n";
        
        sleep 5;
        
        while ( -e $tmp_file ) {
            my $size = (-s $tmp_file);
            print "已经取得文件大小: $size\n";
            sleep 1;
        }
    } else { #子进程
        print "这里是子进程! $$\n";
        if ($ua->mirror($new_chrome_file, $down_file)) {
            print "下载最新版本Chrome成功: $down_file\n";
        }
    }
}
else {
    print '最新版本号: ';
    getprint($new_throme_url);
    print "\n";

    if (mirror($new_throme_url, 'lastversion') == RC_OK) {
        open VER,'lastversion' or die "打开版本文件失败: $!\n";
        my $new_chrome_version = <VER>;
        close VER or die "关闭版本文件失败: $!\n";
        unlink 'lastversion' or die "删除版本文件失败: $!\n";
        
        my $new_chrome_file = qq(http://build.chromium.org/buildbot/snapshots/chromium-rel-xp/$new_chrome_version/chrome-win32.zip);
        
        #启动子进程下载文件,主进程监控文件大小,显示进度
        defined ( my $down_child_id = fork() ) or die "Fail to fork $!\n";
        
        my $down_file = qq(chrome-win32-$new_chrome_version.zip);
        my $tmp_file = qq($down_file-$down_child_id);
        
        if ($down_child_id) {#父进程
            print "这里是父进程! $$\n";
            print "下载临时文件为: $tmp_file\n";
            
            sleep 5;
            
            while ( -e $tmp_file ) {
                my $size = (-s $tmp_file);
                print "已经取得文件大小: $size bytes\n";
                sleep 1;
            }
        } else { #子进程
            print "这里是子进程! $$\n";
            if (mirror($new_chrome_file, $down_file) == RC_OK) {
                print "下载最新版本Chrome成功: $down_file\n";
            }
        }
    }else{
        print "下载版本文件失败!\n";
    }
}
my $a=<STDIN>;
exit 1;

