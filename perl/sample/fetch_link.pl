use strict;
use LWP::UserAgent;

my $TEMPLIST = "/tmp/templist";
my $DOWNLIST = "downlist.txt";

my $url=$ARGV[0];
my $type=$ARGV[1];
# my $url='http://www.ouravr.com/bbs/bbs_content.jsp?bbs_sn=3402316&bbs_page_no=1&search_mode=1&search_text=pdf&bbs_id=1000';
my $ua=new LWP::UserAgent();
my $re= $ua->get($url);
die "Couldn't get $url" unless defined $re;
my $html= $re->content;

#为wget创建批量下载文件
# open (templist,">temp.txt");
# close(templist);


# my $type=rar;
# my $type1=pdf;
# my $downpath = ;

while($html=~ /\<a href=(.*?)\>/gsi){
	open (templist,">>$TEMPLIST");
	print templist "$1\n";
	close(templist);
}

# system("rm -r downlist.txt");
unlink($DOWNLIST) if -e $DOWNLIST;

system("sed -n -e  '/\.$type/p' $TEMPLIST > $DOWNLIST");
# system("sed -n -e  '/\.$type1/p' $TEMPLIST >> $DOWNLIST");

#根据情况删除  有些 <a href=  > 中不光是路径  还有其他标签  看网页源码情况
system("sed -i 's/target=.*/ /g' $DOWNLIST >> $DOWNLIST");

unlink($TEMPLIST);

# 路径
system("wget -i $DOWNLIST -P ~/Downloads/");

