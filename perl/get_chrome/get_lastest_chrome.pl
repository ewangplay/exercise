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
    #$ua->credentials('127.0.0.1:8080', '������', 'username' => 'passwd');
    
    my $content = $ua->get($new_throme_url);
    die "Couldn't get it: $!" unless defined $content;
    print $content->status_line,"\n";
    my $new_chrome_version = $content->content;
    print '���°汾��Ϊ: ',$new_chrome_version,"\n" if ($content->status_line eq '200 OK');
    
    my $new_chrome_file = qq(http://build.chromium.org/buildbot/snapshots/chromium-rel-xp/$new_chrome_version/chrome-win32.zip);
    
    #�����ӽ��������ļ�,�����̼���ļ���С,��ʾ����
    defined ( my $down_child_id = fork() ) or die "Fail to fork $!\n";
    
    my $down_file = qq(chrome-win32-$new_chrome_version.zip);
    my $tmp_file = qq($down_file-$down_child_id);
    
    if ($down_child_id) {#������
        print "�����Ǹ�����! $$\n";
        print "������ʱ�ļ�Ϊ: $tmp_file\n";
        
        sleep 5;
        
        while ( -e $tmp_file ) {
            my $size = (-s $tmp_file);
            print "�Ѿ�ȡ���ļ���С: $size\n";
            sleep 1;
        }
    } else { #�ӽ���
        print "�������ӽ���! $$\n";
        if ($ua->mirror($new_chrome_file, $down_file)) {
            print "�������°汾Chrome�ɹ�: $down_file\n";
        }
    }
}
else {
    print '���°汾��: ';
    getprint($new_throme_url);
    print "\n";

    if (mirror($new_throme_url, 'lastversion') == RC_OK) {
        open VER,'lastversion' or die "�򿪰汾�ļ�ʧ��: $!\n";
        my $new_chrome_version = <VER>;
        close VER or die "�رհ汾�ļ�ʧ��: $!\n";
        unlink 'lastversion' or die "ɾ���汾�ļ�ʧ��: $!\n";
        
        my $new_chrome_file = qq(http://build.chromium.org/buildbot/snapshots/chromium-rel-xp/$new_chrome_version/chrome-win32.zip);
        
        #�����ӽ��������ļ�,�����̼���ļ���С,��ʾ����
        defined ( my $down_child_id = fork() ) or die "Fail to fork $!\n";
        
        my $down_file = qq(chrome-win32-$new_chrome_version.zip);
        my $tmp_file = qq($down_file-$down_child_id);
        
        if ($down_child_id) {#������
            print "�����Ǹ�����! $$\n";
            print "������ʱ�ļ�Ϊ: $tmp_file\n";
            
            sleep 5;
            
            while ( -e $tmp_file ) {
                my $size = (-s $tmp_file);
                print "�Ѿ�ȡ���ļ���С: $size bytes\n";
                sleep 1;
            }
        } else { #�ӽ���
            print "�������ӽ���! $$\n";
            if (mirror($new_chrome_file, $down_file) == RC_OK) {
                print "�������°汾Chrome�ɹ�: $down_file\n";
            }
        }
    }else{
        print "���ذ汾�ļ�ʧ��!\n";
    }
}
my $a=<STDIN>;
exit 1;

