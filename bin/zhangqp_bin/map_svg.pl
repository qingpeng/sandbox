#!/usr/local/bin/perl
#Author:Li Shengting
#E-mail:lishengting@genomics.org.cn
#Program Date:2002-10-14 13:57
#Last Update:2003-09-16 16:48
#Describe:画线性分布图
my $ver=1.00; #2002-10-30 0:00 基本横向基因分布图
$ver=1.01; #2002-12-16 17:29 修改空白字符的输出('xml:space',"preserve")
$ver=1.02; #2003-1-5 11:52 增加字体倾斜、矩形箭头表示、顶部颜色列表、行背景区分等
$ver=1.12; #2003-7-5 17:59 增加好多功能
$ver=1.13; #2003-07-10 16:15 画线移到底层
$ver=1.23; #2003-07-18 00:49 增加文字移动功能
$ver=1.24; #2003-07-20 20:41 修改BUG
$ver=2.00; #2003-09-16 16:48 添加一堆功能，修改一堆bug
use strict;
#use diagnostics;
use Svg::File;
use Svg::Graphics;
use Getopt::Long;

######################################################################################################################
#	Usage
######################################################################################################################
my $usage= <<"USAGE";
#$ver Usage: $0 <map_list> <svg_file> [-s start] [-l length] [-e end] [-t type] [-z zero] [-long long] [-scale scale] [-nohead] [-nopop] [-nosmark] [-width1st]
USAGE
my $argvNumber=2;
my %opts;
GetOptions(\%opts,"s:s","l:s","e:s","t:s","z:s","long:s","scale:s","nohead!","nopop!","nosmark!","width1st!");
die $usage if (@ARGV<$argvNumber);
undef($argvNumber);
######################################################################################################################
#	Constant
######################################################################################################################
use constant PI => 3.1415926;
my $SPECIAL_CHAR='<&>';

my %s=(
	XOFFSET => 50,
	YOFFSET => 20,
	CHRH => 12,
	XSPACE => 2,
	YSPACE => 2,
	LINE_GAP => 20,
	ROW_GAP => 30,
	XGAP1 => 20,
	YGAP1 => 20,
	BKWIDTH => 20,
	LMGRP_SCALE => 4/3,
	TITLE_SCALE => 3/2,
);

my %d=(
	path=>{
		'stroke'=>"#000000",
		'fill'=>"none",
		'stroke-width'=>3,
		'stroke-linecap'=>'round'
	},
	font=>{
		'fill'=>"#000000",
		'font-size'=>32,
		'font-family'=>"ArialNarrow-Bold"
	},
	rect=>{
		'fill'=>"none",
		'stroke'=>"black",
		'stroke-width'=>1
	},
	circle=>{
		'fill'=>"none",
		'stroke'=>"black"
	},
	polygon=>{
		'fill'=>"black",
		'stroke'=>"black"
	},
);
my %i=(
	s=>0,
	e=>1,
	dir=>2,
	color=>3,
	name=>4,
	label=>5,
	layer=>6,
);
my %t=(
	Scale=>'Scale',
	Rect=>'Rect',
	Text=>'Text',
	TextScale=>'TextScale',
	TextBar=>'TextBar',
	Space=>'Space',
	V_Line=>'V_Line',
);

my %w=(
	Line=>3,
	Scale=>10,
	Rect=>20,
	ArrowLine=>3,
	ArrowSize=>8,
	Char=>$s{CHRH}*$d{font}{'font-size'}/10,
	ConnectLine=>1,
);

######################################################################################################################
#	Variable
######################################################################################################################
my ($mapL,$svgF)=@ARGV;
my $START=$opts{s};
my $LEN=$opts{l};
my $END=$opts{e};
if ($START && ($END > $START)) {
	$LEN=$END-$START+1;
}
my $LONG=$opts{long};
my $SCALE=$opts{scale};
my $ZERO_VAL=$opts{z};
my $type=$opts{t};
my $nohead=$opts{nohead};
my $nosmark=$opts{nosmark};
my $width1st=$opts{width1st};
my (%param,@list,%rect,%mrect,@note,@errhis,@color,@info,@lmgroup,@rowHeight);
my ($rowNum,$rowLong,$rowWidth,$maxMarkLen,$maxCMarkLen,$maxLMGroupLen,$forText,$rectStrokeWidth,
$borderWidth,$vbW,$vbH,$freeColor);
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#	Begin
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
my $svg = Svg::File->new($svgF,\*OUT);
$svg->open("public","encoding","iso-8859-1");
my $g = $svg->beginGraphics();

{
	my @keys=(
	"Type","WholeScale","Long","LongScale","Title",
	"Length","Start","End","ZeroVal","Compact",
	"Unit","UnitDiv","ScaleUnit","ExtScale",
	"MarkPos","MarkBorder","MarkScale","MarkRows",
	"LMarkAlign","LMarkScale","NeedRMark",#"MarkStyle",
	"FontSize","FontFamily","FontBold",
	"AvailDigit","Note","LineWidth","PointSize","NoBackground",
	"NoPop","ColorX","ColorY",
	);
	my @lkeys=(
	"Type","Mark","Color","Compact","Connect","NoPop","IsHead","Prolong","Mix","Shift",
	#Line
	"NoScale","NoScaleLine","ScaleAside","ScaleUp","ScaleLineUp","NoScaleMark",
	"Unit","UnitDiv","ScaleUnit","LineWidth","Split","Start","End",
	#Rect
	"WithArrow","IsArrow","NoOutLine","WithLabel","ExtScale",
	"StrokeWidth","StrokeColor","LongScale",
	#Arrow
	#Text
	"AutoAlign","LayerNum","Pos","FontRotate","FontScale","Background","BackgroundTransparence",
	#Space
	"Width",
	#V_Line
	"StartLine","EndLine","LineDash",
	);
	my @stict_keys=();
	my (@mm);
	my($lineNum,$ltype,$i,$tmp,$tmp2,$width,$fontScale,$prolong);
	
	open(F,$mapL) || die "Can't open $mapL!\n";
	while (<F>) {
		last if ($_!~/\S/);
		if (/^\s*Note:/i) {
			while (<F>) {
				last if ($_=~/^:End$/i);
				chomp;
				push(@note,$_);
			}
		}elsif (/^\s*ColorList:/i) { 
			while (<F>) {
				last if ($_=~/^:End$/i);
				chomp;
				$_=~ s/([$SPECIAL_CHAR])/sprintf("&#%d;", ord($1))/ge;
				$tmp=[];
				@$tmp=split /:/;
				push(@color,$tmp);
			}
		}elsif (/^\s*LMarkGroup:/i) {
			while (<F>) {
				last if ($_=~/^:End$/i);
				chomp;
				$_=~ s/([$SPECIAL_CHAR])/sprintf("&#%d;", ord($1))/ge;
				$tmp=[];
				@$tmp=split /:/;
				push(@lmgroup,$tmp);
			}
		}elsif (/(\S+?):(.+)/) {
			$param{lc($1)}=$2;
		}
	}
	foreach (@keys) {
		if (exists($param{lc($_)})) {
			$param{$_}=$param{lc($_)};
		}
	}

	$d{font}{'font-weight'}='bold' if ($param{FontBold});
	$d{font}{'font-size'}=$param{FontSize} if ($param{FontSize}!=0);
	$d{font}{'font-family'}=$param{FontFamily} if ($param{FontFamily} ne '');
	$g->setFontFamily($d{font}{'font-family'});
	$g->setFontColor($d{font}{fill});
	$g->setCharSpacing(0);
	$g->setWordSpacing(0);
	$maxMarkLen=0;
	$maxCMarkLen=0;
	$maxLMGroupLen=0;
	$d{font}{'font-size'}*=$s{LMGRP_SCALE};
	$g->setFontSize($d{font}{'font-size'});
	foreach (@lmgroup) {
		$maxLMGroupLen=txtWidth($_->[0]) if ($maxLMGroupLen<txtWidth($_->[0]));
	}
	$d{font}{'font-size'}/=$s{LMGRP_SCALE};
	$g->setFontSize($d{font}{'font-size'});
	foreach (@color) {
		$maxCMarkLen=txtWidth($_->[1]) if ($maxCMarkLen<txtWidth($_->[1]));
	}

	if (!$START) {
		if (exists($param{Start})) {
			$START=$param{Start};
		}else{
			$START=0;
		}
	}else{
		$param{Start}=$START;
	}
	$LEN=$param{Length} if (!$LEN);
	$LONG=$param{Long} if (!$LONG);
	#print "$LEN\t$LONG\n";
	$param{LongScale}= $param{LongScale} ? $param{LongScale} : 1;
	$SCALE=$param{LongScale} if (!$SCALE);
	$param{MarkScale}= ($param{MarkScale} ? $param{MarkScale} : 1);
	$param{LMarkScale}= ($param{LMarkScale} ? $param{LMarkScale} : 1);

	foreach (@stict_keys) {
		if (!exists($param{$_})) {
			die "$_ must be defined!\n";
		}
	}
	if (!exists($param{End}) && !$LEN) {
		die "Either End or Length must be defined!\n";
	}elsif (exists($param{End}) && !$LEN) {
		$LEN=$param{End}-$param{Start}+1;
	}
	die "Length <= 0 !!!\n" if ($LEN<=0);
	$LONG=$LEN if (!$LONG);

	$rowLong=$LONG*$SCALE;
	$rowWidth=0;
	$lineNum=0;
	$borderWidth=0;
	while (!eof(F)) {
		while (<F>) {
			if ($_=~/^\s*[\+-]?\d/ || $_=~/^\s*:/ || $_!~/\S/) {
				seek(F,-length,1);
				last;
			}
			if (/(\S+?):(.+)/) {
				$list[$lineNum]{lc($1)}=$2;
				$list[$lineNum]{lc($1)}=$2;
			}
		}
		foreach (@lkeys) {
			if (exists($list[$lineNum]{lc($_)})) {
				$list[$lineNum]{$_}=$list[$lineNum]{lc($_)};
			}
		}

		$width=0;
		if (exists($list[$lineNum]{Type})){
			$ltype=$list[$lineNum]{Type};
		}else{
			<F>;
			next;
		}

		$i=0;
		$fontScale=(defined($list[$lineNum]{FontScale}) ? $list[$lineNum]{FontScale} : 1);
		if (defined($list[$lineNum]{LayerNum}) && $list[$lineNum]{LayerNum}<1) {
			$list[$lineNum]{LayerNum}=1;
		}
		@mm=split(/\\n/,$list[$lineNum]{Mark});
		foreach (@mm) {
			$maxMarkLen=txtWidth($_) if ($maxMarkLen<txtWidth($_));
		}
		$prolong=$list[$lineNum]{Prolong} ? $list[$lineNum]{Prolong} : 1;
		while (<F>) {
			last if ($_!~/\S/);
			if ($_!~/^\s*[\+-]?\d/ && $_!~/^\s*:/) {
				next;
			}
			chomp;
			#print  "$_\n";
			$tmp=[];
			@$tmp=split(/:/,$_);
			$tmp2=(split(/\|/,$tmp->[$i{label}]))[0];
			$tmp->[0]*=$prolong;
			$tmp->[1]*=$prolong;
			$list[$lineNum]{Data}[$i]=$tmp;
			$list[$lineNum]{MaxNameLen}=txtWidth($tmp->[$i{name}]) if ($list[$lineNum]{MaxNameLen}<txtWidth($tmp->[$i{name}]));
			$list[$lineNum]{MaxLabelLen}=txtWidth($tmp2) if ($list[$lineNum]{MaxLabelLen}<txtWidth($tmp2));
			#print @$tmp,"\n",$tmp->[$i{label}],"\n";
			$i++;
		}
		$tmp2=(defined($list[$lineNum]{AutoAlign}) && defined($list[$lineNum]{LayerNum})) ? $list[$lineNum]{LayerNum} : 1;
		if ($list[$lineNum]{FontRotate}) {
			$tmp=($list[$lineNum]{MaxNameLen} ? $list[$lineNum]{MaxNameLen} : $list[$lineNum]{MaxLabelLen});
			if ($tmp) {
				$list[$lineNum]{wChar}=
						($tmp*sin($list[$lineNum]{FontRotate}/180*PI)
						+$w{Char}*cos($list[$lineNum]{FontRotate}/180*PI))
						#-$s{YSPACE}*2)
						*$fontScale*$tmp2;
						#*($fontScale==1 ? 1 : $fontScale*7/10);
			}
		}else{
			$list[$lineNum]{wChar}=$w{Char}*$fontScale*$tmp2;
		}
		if ($ltype !~ /^V_/) {
			if ($ltype eq $t{Scale}) {
				$width+= defined($list[$lineNum]{LineWidth}) ? $list[$lineNum]{LineWidth} : $w{Line};
				if (!$list[$lineNum]{NoScaleLine}) {
					$width+=$w{Scale};
				}
				if (!$list[$lineNum]{NoScale}) {
					if ($list[$lineNum]{ScaleAside}) {
						$tmp=txtWidth(max($LEN,$LONG))+txtWidth($list[$lineNum]{ScaleUnit});
					}else{
						$tmp=txtWidth(max($LEN,$LONG))/2+txtWidth($list[$lineNum]{ScaleUnit});
						$width+=$w{Char};
					}
					$borderWidth=$tmp if ($borderWidth<$tmp);
				}
				$width-=$s{LINE_GAP}+$s{YSPACE};
			}elsif ($ltype eq $t{Rect}) {
				$width+=$w{Rect};
				if ($list[$lineNum]{WithLabel} && $list[$lineNum]{WithLabel} !~ /^[lr]/i) {
					$width+=$list[$lineNum]{wChar};
				}
				if ($list[$lineNum]{WithArrow}) {
					$width+=$s{LINE_GAP}/2;
					$width+=$w{ArrowLine};
				}
			}elsif ($ltype eq $t{Text}) {
				$width+=$list[$lineNum]{wChar};
				$list[$lineNum]{Compact}=1;
			}elsif ($ltype eq $t{TextScale}) { #文字标尺
				$forText=1;
				$width+=$w{Char};
				$width+=$w{Line};
			}elsif ($ltype eq $t{TextBar}) { #序列
				$forText=1;
				$width+=$w{Char};
			}elsif ($ltype eq $t{Space}) {
				$width+=defined($list[$lineNum]{Width}) ? $list[$lineNum]{Width}-($s{LINE_GAP}+$s{YSPACE}) : 0;
			}
	#		if ($list[$lineNum]{IsHead}) {
	#			$width*=$param{MarkScale};
	#			$list[$lineNum]{wChar}*=$param{MarkScale};
	#		}
			if (!$list[$lineNum]{Compact}) {
				$width+=$s{LINE_GAP}+$s{YSPACE};
			}
			$rowWidth+=$width;
			$list[$lineNum]{Width}=$width;
			$g->setFontSize($d{font}{'font-size'}*$param{LMarkScale}) if ($param{LMarkScale}!=1);
			$borderWidth=txtWidth($list[$lineNum]{Mark}) if ($borderWidth<txtWidth($list[$lineNum]{Mark}));
			$g->setFontSize($d{font}{'font-size'}/$param{LMarkScale}) if ($param{LMarkScale}!=1);
		}else{
			$list[$lineNum]{Width}=0;
		}

		$lineNum++;
	}
	$END=$START+$LEN-1;
	#print "$LEN\t$LONG\$rowNum\n";
	$rowNum=uint($LEN / $LONG);
}

#####################################################################################################################
#	SET param
#####################################################################################################################
$param{Type}=$type if ($type ne '');
$type=$param{Type};
$type='Horizontal' if ($type eq '');
$ZERO_VAL=$param{ZeroVal} if (!$ZERO_VAL && exists($param{ZeroVal}));
$param{Unit}= ($param{Unit} ? $param{Unit} : int($LONG/10));
$param{UnitDiv}= ($param{UnitDiv} ? $param{UnitDiv} : 1);
$param{MarkRows}= ($param{MarkRows} ? $param{MarkRows} : 2);
$param{MarkPos}= ($param{MarkPos} ? $param{MarkPos} : 'top');
#$param{MarkStyle}= ($param{MarkStyle} ? $param{MarkStyle} : 'horizontal');
$param{PointSize}= ($param{PointSize} ? $param{PointSize} : 5);
$param{WholeScale}= ($param{WholeScale} ? $param{WholeScale} : 1);
$param{NoPop}= $opts{nopop} ? 1 : $param{NoPop};
$param{NoBackground}= ($param{NoBackground} ? $param{NoBackground} : ($LONG>=$LEN ? 1 : 0));
$param{LMarkAlign}= $param{LMarkAlign} ? $param{LMarkAlign} : 'r';
$param{Note}=~ s/([$SPECIAL_CHAR])/sprintf("&#%d;", ord($1))/ge; 
$rectStrokeWidth=$SCALE < 1 ? $SCALE : 1;

$freeColor=(defined($param{ColorX}) || defined($param{ColorY})) ? 1 : 0;
$rect{left}=$s{XOFFSET}+$borderWidth+$s{XGAP1}+($maxLMGroupLen ? $maxLMGroupLen+$s{BKWIDTH}*2+$s{XSPACE}*2 : 0);
$mrect{left}=$rect{left}+(defined($param{ColorX}) ? $param{ColorX}*$SCALE : 0);
$rect{top}=$s{YOFFSET}+$s{YGAP1}+@note*($w{Char}+$s{YSPACE}*2)+(defined($param{Title}) ? $w{Char}*$s{TITLE_SCALE}+$s{YSPACE}*3 : 0);
if ($param{MarkPos} ne 'top') {
}else{
	$mrect{top}=(defined($param{ColorY}) ? $param{ColorY} : $rect{top}-$s{YGAP1});
	$rect{top}+=($freeColor ? 0 : min($param{MarkRows},scalar @color)*($w{Char}+$s{YSPACE}*2)*$param{MarkScale});
}

if ($forText) {
	$rowLong=($LONG)*txtWidth('A');
}
$rect{width}=$rowLong < $LEN*$SCALE ? $rowLong : $LEN*$SCALE;
$rect{height}=($rowWidth+$s{ROW_GAP})*$rowNum;
$vbW=$rect{left}*2+$rect{width};
$vbH=$rect{top}*2+$rect{height};
#####################################################################################################################
#	画图
#####################################################################################################################
$g->b("svg","viewBox","0 0 ".($vbW*$param{WholeScale})." ".($vbH*$param{WholeScale}),"width",$vbW*$param{WholeScale},"height",$vbH*$param{WholeScale});
$g->svgPrint("\n<Author>Li Shengting</Author>\n");
$g->svgPrint("<E-mail>lishengting\@genomics.org.cn</E-mail>");
$g->svgPrint("\n<Version>$ver</Version>");
my $drawer=getlogin()."@".(`hostname`);
chomp $drawer;
$g->svgPrint("\n<Drawer>$drawer</Drawer>");
$g->svgPrint("\n<Date>".(localtime())."</Date>");
$g->b("g","transform","scale($param{WholeScale})",'xml:space',"preserve");
#背景
if (!$param{NoBackground}) {
	$g->b("g","transform","translate($rect{left},$rect{top})");
	{
		$d{rect}{fill}='#EEEEEE';
		$d{rect}{stroke}='none';
		for (my $i=0;$i<$rowNum;$i+=2) {
			$g->d("rect",
				  "xval",0,
				  "yval",$i*($rowWidth+$s{ROW_GAP}),
				  "width",$rect{width},
				  "height",($rowWidth+$s{ROW_GAP}/2),
				  "style",style($d{rect}),
				 );
		}
	}
	$g->e();
}

#Clip
{
	$d{rect}{fill}='none';
	$d{rect}{stroke}='none';
	$g->b("clipPath","id","rectClip");
		$g->d("rect",
		  "xval",0,
		  "yval",0,
		  "width",$rect{width},
		  "height",$rowNum*($rowWidth+$s{ROW_GAP}),
		  "style",style($d{rect}),
		 );		
	$g->e();		
}

#颜色标签
if (!$nohead) {
	$g->b("g","transform","translate($mrect{left},$mrect{top}) scale($param{MarkScale})");
	{
		my ($x,$y,$xx,$yy,$i,$j,$rows,$lExt,$defaultGrp);
		my (%colorGroup,@tmpc,@tmpcc);
		$lExt=20;
		$defaultGrp='@_@';
		$j=1;
		for ($i=0;$i<@color;$i++) {
			if ($color[$i][2]) {
				push(@{$colorGroup{$color[$i][2]}{colors}},$color[$i]);
				if (!$colorGroup{$color[$i][2]}{index}) {
					$colorGroup{$color[$i][2]}{index}=$j++;
				}
			}else{
				push(@{$colorGroup{$defaultGrp}{colors}},$color[$i]);
			}
		}
		if (defined($colorGroup{$defaultGrp})) {
			$colorGroup{$defaultGrp}{index}=0;
		}
		$x=0;
		foreach $i (sort {$colorGroup{$a}{index} <=> $colorGroup{$b}{index}} keys %colorGroup) {
			$yy=0;
			$rows=min($param{MarkRows},$#{$colorGroup{$i}{colors}}+1);
			if ($param{MarkRows}>$rows) {
				$yy=($param{MarkRows}-$rows)*($w{Char}+$s{YSPACE}*3)/2;
			}
			if ($i ne $defaultGrp) {
				$y=($rows*$w{Char}+($rows-1)*$s{YSPACE}*3)/2;
				$g->d("txtLM",$i,
				  "xval",$x,
				  "yval",$y+$yy,
				  "style",style($d{font}),
				);
				$x+=txtWidth($i)+$s{XSPACE}*3;
				$g->d("line","x1",$x,"y1",$w{Char}/2+$yy,"x2",$x+$lExt,"y2",$w{Char}/2+$yy,"style",style($d{path}));
				$g->d("line","x1",$x,"y1",$y*2-$w{Char}/2+$yy,"x2",$x+$lExt,"y2",$y*2-$w{Char}/2+$yy,"style",style($d{path}));
				$g->d("line","x1",$x,"y1",$w{Char}/2+$yy,"x2",$x,"y2",$y*2-$w{Char}/2+$yy,"style",style($d{path}));
				$x+=$lExt+$s{XSPACE}*3;
			}
			next if (!defined($colorGroup{$i}{colors}));
			@tmpc=@{$colorGroup{$i}{colors}};
			for ($j=0;$j<@tmpc;$j++) {
				@tmpcc=split(/\|/,$tmpc[$j][0]);
				$d{rect}{fill}=$tmpcc[0];
				$d{rect}{stroke}=$tmpcc[1] ? $tmpcc[1] : 'none';
				$xx=$x+int($j/$param{MarkRows})*($w{Char}+$s{XSPACE}*3+$maxCMarkLen+$s{XGAP1});
				$y=$j%$param{MarkRows}*($w{Char}+$s{YSPACE}*3);
				$g->d("rect",
					  "xval",$xx,
					  "yval",$y+$yy,
					  "width",$w{Char},
					  "height",$w{Char},
					  "style",style($d{rect}),
					 );
				$g->d("txtLM",$tmpc[$j][1],
					  "xval",$xx+$w{Char}+$s{XSPACE}*3,
					  "yval",$y+$w{Char}/2+$yy,
					  "style",style($d{font}),
					 );
			}
			$x=$xx + $w{Char}+$s{XSPACE}*3+$maxCMarkLen+$s{XGAP1}*3;
		}
	}
	$g->e();
}

#说明标签
if (!$nohead) {
	my ($x,$y);
	$g->b("g","transform","translate($s{XOFFSET},$s{YOFFSET})");
	$x=0;$y=0;
	if (defined($param{Title})) {
		$d{font}{'font-size'}*=$s{TITLE_SCALE};
		$g->setFontSize($d{font}{'font-size'});
		$g->d("txtLT",$param{Title},
			  "xval",0,
			  "yval",0,
			  "style",style($d{font}),
			 );
		$d{font}{'font-size'}/=$s{TITLE_SCALE};
		$g->setFontSize($d{font}{'font-size'});
		$x+=$s{XGAP1};
		$y+=$w{Char}*$s{TITLE_SCALE}+$s{YSPACE}*3;
	}
	for (my $i=0;$i<@note;$i++) {
		foreach (keys %param) {
			$note[$i]=~s/%$_%/$param{$_}/eg;
		}
		$note[$i]=~s/_START_/$START/eg;
		$note[$i]=~s/_END_/$END/eg;
		$g->d("txtLT",$note[$i],
			  "xval",$x,
			  "yval",$i*($w{Char}+$s{YSPACE}*2)+$y,
			  "style",style($d{font}),
			 );
	}
	$g->e();
}
#画图
$g->b("g","transform","translate($rect{left},$rect{top})");
{
	my ($ltype,$i,$j,$k,$tmp,$ti,$tj,$tmpAlign,$tmpx,$curRowPos,$lastRowPos,$needCut,$tmpm);
	my (%con,@conn,@label,@mm);
	my ($x,$y,$start,$yOffset,$yHeight,$reduce,$Shift);
	$curRowPos=$lastRowPos=0;
	$reduce=0;
	@rowHeight=();
	for ($i=0;$i<@list;$i++) {
		$Shift=$list[$i]{Shift} ? $list[$i]{Shift} : 0 ;
		if (!$list[$i]{IsHead}) {
			$curRowPos-=$reduce;
			$reduce=0;
		}
		if ($list[$i]{Mix}) {
			$curRowPos=$lastRowPos;
		}
		$rowHeight[$i]=$curRowPos;
		$ltype=$list[$i]{Type};
		$info[$i]{type}=$ltype;
		if ($list[$i]{Connect}) {
			$yOffset=0;
			$yHeight=0;
			if ($ltype eq $t{Scale}) {
				if (!$list[$i]->{NoScale} && !$list[$i]->{ScaleAside} && $list[$i]->{ScaleUp}) {
					$yOffset+=$w{Char};
				}
				if (!$list[$i]->{NoScaleLine} && $list[$i]->{ScaleLineUp}){
					$yOffset+=$w{Scale};
				}
				$yHeight=0;
			}elsif ($ltype eq $t{Rect}) {
				if ($list[$i]->{WithLabel} && $list[$i]->{WithLabel} !~ /^[lr]/i) {
					$yOffset+=$list[$i]->{wChar};
				}
				$yHeight=$w{Rect};
			}elsif ($ltype eq $t{Text}) {
			}elsif ($ltype eq $t{TextScale}) {
			}elsif ($ltype eq $t{TextBar}) {
			}elsif ($ltype eq $t{Space}) {
			}
			foreach $j (@{$list[$i]->{Data}}) {
				if ($j->[$i{dir}]=~/-/) {
					$start=$j->[$i{e}]+$Shift;
					$tmpm=-1/2;
				}elsif ($j->[$i{dir}]=~/\+/) {
					$start=$j->[$i{s}]+$Shift;
					$tmpm=1/2;
				}else{
					$start=($j->[$i{s}]+$j->[$i{e}])/2+$Shift;
					$tmpm=0;
				}
				$y = $curRowPos+$yOffset;
				($x,$y)=getRealXY($start-$START+1,$START,$y);
				$tmp=++$#{$info[$i]{pos}};
				$info[$i]{pos}[$tmp]{label}=$j->[$i{label}] ? $j->[$i{label}] : '#';
				$info[$i]{pos}[$tmp]{x1}=$x*$SCALE;
				$info[$i]{pos}[$tmp]{y1}=$y;
				$info[$i]{pos}[$tmp]{y2}=$y+$yHeight;
				$info[$i]{pos}[$tmp]{i}=$i;
				$info[$i]{pos}[$tmp]{lineMove}=$tmpm;
				if ($start < $START) {
					$info[$i]{pos}[$tmp]{out_range}=-1;
				}
				if ($start > $START+$LEN-1) {
					$info[$i]{pos}[$tmp]{out_range}=1;
				}
			}
		}
		$lastRowPos=$curRowPos;
		$curRowPos+=$list[$i]{Width};
		if (!$list[$i]{Mix} && $list[$i]{IsHead}) {
			$reduce+=$list[$i]{Width}*(1-$param{MarkScale});
		}
	}
	$rowHeight[$i]=$curRowPos;
	$d{font}{'font-size'}*=$s{LMGRP_SCALE};
	$g->setFontSize($d{font}{'font-size'});
	foreach $i (@lmgroup) {
		$tmpx=-$s{XGAP1}-$maxMarkLen-$s{XSPACE}*2;
		$g->d("line",
			"x1",$tmpx-$s{BKWIDTH},
			"y1",($rowHeight[$i->[1]]+$rowHeight[$i->[1]-1])/2,
			"x2",$tmpx,
			"y2",($rowHeight[$i->[1]]+$rowHeight[$i->[1]-1])/2,
			"style",style($d{path})
			);
		$g->d("line",
			"x1",$tmpx-$s{BKWIDTH},
			"y1",($rowHeight[$i->[1]]+$rowHeight[$i->[1]-1])/2,
			"x2",$tmpx-$s{BKWIDTH},
			"y2",($rowHeight[$i->[2]]+$rowHeight[$i->[2]-1])/2,
			"style",style($d{path})
			);
		$g->d("line",
			"x1",$tmpx-$s{BKWIDTH},
			"y1",($rowHeight[$i->[2]]+$rowHeight[$i->[2]-1])/2,
			"x2",$tmpx,
			"y2",($rowHeight[$i->[2]]+$rowHeight[$i->[2]-1])/2,
			"style",style($d{path})
			);
		$g->d("txtRM",$i->[0],
			  "xval",$tmpx-$s{BKWIDTH}*2,
			  "yval",($rowHeight[$i->[1]]+$rowHeight[$i->[1]-1]+$rowHeight[$i->[2]]+$rowHeight[$i->[2]-1])/4,
			  "style",style($d{font}),
			 );
		if ($param{NeedRMark}) {
			$tmpx=$rect{width}+$s{XGAP1}+$maxMarkLen+$s{XSPACE}*2;
			$g->d("line",
				"x1",$tmpx,
				"y1",($rowHeight[$i->[1]]+$rowHeight[$i->[1]-1])/2,
				"x2",$tmpx+$s{BKWIDTH},
				"y2",($rowHeight[$i->[1]]+$rowHeight[$i->[1]-1])/2,
				"style",style($d{path})
				);
			$g->d("line",
				"x1",$tmpx+$s{BKWIDTH},
				"y1",($rowHeight[$i->[1]]+$rowHeight[$i->[1]-1])/2,
				"x2",$tmpx+$s{BKWIDTH},
				"y2",($rowHeight[$i->[2]]+$rowHeight[$i->[2]-1])/2,
				"style",style($d{path})
				);
			$g->d("line",
				"x1",$tmpx,
				"y1",($rowHeight[$i->[2]]+$rowHeight[$i->[2]-1])/2,
				"x2",$tmpx+$s{BKWIDTH},
				"y2",($rowHeight[$i->[2]]+$rowHeight[$i->[2]-1])/2,
				"style",style($d{path})
				);
			$g->d("txtLM",$i->[0],
				  "xval",$tmpx+$s{BKWIDTH}*2,
				  "yval",($rowHeight[$i->[1]]+$rowHeight[$i->[1]-1]+$rowHeight[$i->[2]]+$rowHeight[$i->[2]-1])/4,
				  "style",style($d{font}),
				 );
		}
	}
	$d{font}{'font-size'}/=$s{LMGRP_SCALE};
	$g->setFontSize($d{font}{'font-size'});

	for ($i=0;$i<@list;$i++) {
		if ($list[$i]{Connect} && defined($info[$i]{pos}) && @{$info[$i]{pos}} > 0) {
			push(@{$con{$list[$i]{Connect}}},@{$info[$i]{pos}});
		}
	}
	foreach $i (keys %con) {
		@{$con{$i}} = sort {$a->{label} cmp $b->{label} || ($a->{i} <=> $b->{i})} @{$con{$i}};
		for ($j=0;$j<@{$con{$i}};$j++) {
			next if ($con{$i}[$j]{label} eq '');
			@label=split(/\|/,$con{$i}[$j]{label});
			next if ($label[$#label] eq '#');
			$d{path}{'stroke'}= defined($label[1]) ? $label[1] : $i;
			$d{path}{'stroke-width'}= defined($label[2]) ? $label[2] : $param{LineWidth} ? $param{LineWidth} : $w{ConnectLine};
			@conn=();
			++$#conn;
			while ($j+1<@{$con{$i}} && $con{$i}[$j]{label} eq $con{$i}[$j+1]{label}) {
				$ti=++$#{$conn[$#conn]};
				$conn[$#conn][$ti]=$con{$i}[$j];
				if ($con{$i}[$j]{i}!=$con{$i}[$j+1]{i}) {
					$#conn++;
				}
				$j++;
			}
			$ti=++$#{$conn[$#conn]};
			$conn[$#conn][$ti]=$con{$i}[$j];
			
			for ($k=0;$k<$#conn;$k++) {
				for ($ti=0;$ti<@{$conn[$k]};$ti++) {
					for ($tj=0;$tj<@{$conn[$k+1]};$tj++) {
						next if ($conn[$k][$ti]{out_range} && $conn[$k+1][$tj]{out_range} && $conn[$k][$ti]{out_range} == $conn[$k+1][$tj]{out_range});
						if ($conn[$k][$ti]{out_range} || $conn[$k+1][$tj]{out_range}) {
							$needCut=1;
						}else{
							$needCut=0;
						}
						con($conn[$k][$ti],$conn[$k+1][$tj],$label[0],$needCut);
					}
				}
			}
		}
	}
	$curRowPos=$lastRowPos=0;
	$reduce=0;
	for ($i=0;$i<@list;$i++) {
		if (!$list[$i]{IsHead}) {
			$curRowPos-=$reduce;
			$reduce=0;
		}
		if ($list[$i]{Mix}) {
			$curRowPos=$lastRowPos;
		}
		$ltype=$list[$i]{Type};
		#print $list[$i]{Mark};
		if ($list[$i]{Mark} ne '' && !$nohead) {
			if ($param{LMarkScale}!=1) {
				$d{font}{'font-size'}*=$param{LMarkScale};
				$g->setFontSize($d{font}{'font-size'});
			}
			for ($j=0;$j<$rowNum;$j++) {
				@mm=split(/\\n/,$list[$i]{Mark});
				for ($k=0;$k<@mm;$k++) {
					if ($param{LMarkAlign}=~/l/i) {
						$tmpAlign="LM";
						$tmpx=-$s{XGAP1}-$maxMarkLen;
					}else{
						$tmpAlign="RM";
						$tmpx=-$s{XGAP1};
					}
					$g->d("txt".$tmpAlign,$mm[$k],
						  "xval",$tmpx,
						  "yval",$curRowPos+$j*($rowWidth+$s{ROW_GAP})+($list[$i]{Width}-($list[$i]{Compact} ? 0 : $s{LINE_GAP}+$s{YSPACE}))/2
								 -((@mm-1)/2-$k)*($w{Char}-$s{YSPACE}*3),
						  "style",style($d{font}),
						 );

					if ($param{NeedRMark}) {
						$tmpx=$rect{width}+$s{XGAP1};
						$g->d("txtLM",$mm[$k],
							  "xval",$tmpx,
							  "yval",$curRowPos+$j*($rowWidth+$s{ROW_GAP})+($list[$i]{Width}-($list[$i]{Compact} ? 0 : $s{LINE_GAP}+$s{YSPACE}))/2
									 -((@mm-1)/2-$k)*($w{Char}-$s{YSPACE}*3),
							  "style",style($d{font}),
							 );
					}
				}
			}
			if ($param{LMarkScale}!=1) {
				$d{font}{'font-size'}/=$param{LMarkScale};
				$g->setFontSize($d{font}{'font-size'});
			}
		}
		$lastRowPos=$curRowPos;
		if ($list[$i]{IsHead} && $nohead) {
			$curRowPos+=$list[$i]{Width};
		}else{
			if ($list[$i]{IsHead}) {
				$g->b("g","transform","scale($param{MarkScale})");
			}
			if ($ltype eq $t{Scale}) {
				$curRowPos=hDrawScaleBar($list[$i],$curRowPos);
			}elsif ($ltype eq $t{Rect}) {
				$curRowPos=hDrawRectBar($list[$i],$curRowPos);
			}elsif ($ltype eq $t{Text}) {
				$curRowPos=hDrawTextBar($list[$i],$curRowPos);
			}elsif ($ltype eq $t{TextScale}) {
				$curRowPos=hDrawTextScaleBar($list[$i],$curRowPos);
			}elsif ($ltype eq $t{TextBar}) {
				$curRowPos=hDrawTextBarBar($list[$i],$curRowPos);
			}elsif ($ltype eq $t{Space}) {
				$curRowPos+=$list[$i]{Width};
			}elsif ($ltype eq $t{V_Line}) {
				hDrawVLine($list[$i]);
			}
			if ($list[$i]{IsHead}) {
				$g->e();
			}
		}
		if (!$list[$i]{Mix} && $list[$i]{IsHead}) {
			$reduce+=$list[$i]{Width}*(1-$param{MarkScale});
		}
	}
}
$g->e();
$g->e();
$g->e();
$svg->close($g);
close(F);

#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#	Subprogram
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sub con {
	my ($start,$end,$label,$needCut,%pop)=@_;
	my $tmp1=$d{path}{'stroke-width'}*$start->{lineMove};
	my $tmp2=$d{path}{'stroke-width'}*$end->{lineMove};
	%pop=();
	if (!$param{NoPop}) {
		%pop=('onclick'=>"alert('connect: $label')");
	}
	$g->d("line","x1",$start->{x1}+$tmp1,"y1",$start->{y2},"x2",$end->{x1}+$tmp2,"y2",$end->{y1},"style",style($d{path}).($needCut ? ";clip-path:url(#rectClip)"  :""),%pop);
}
sub hDrawTextScaleBar{ #_START_=1
	my ($line,$curRowPos)=@_;
	my ($x,$y,$i,$j,$tmp,
		$long,$unit,$color);
	my ($txt,$num,$space);
	$x = 0;
	$y = $curRowPos;
	$long = $LONG;
	$unit = $line->{Unit} ? $line->{Unit} : $param{Unit};
	$color = $line->{Color} ne '' ? $line->{Color} : 'black';
	$d{path}{'stroke-width'}=$w{Line};
	$txt='';
	$num=$unit+$START-1;
	$space=$unit-1;
	for ($i=0;$i<$rowNum;$i++) {
		if ($i==$rowNum-1) {
			$long = $LEN % $LONG ? $LEN % $LONG : $LONG;
		}
		$d{path}{'stroke'}=$color;
		if ($line->{ScaleUp}) {
			$g->d("line","x1",$x,"y1",$y+$w{Char}+$w{Line},"x2",($x+($long)*txtWidth('0')),"y2",$y+$w{Char}+$w{Line},"style",style($d{path}));
			$txt='';
			$tmp=length($txt)-(length($num)-1)+($unit-1);
			while ($tmp<=$long-1) {
				$txt.=' ' x $space . $num;
				$tmp=length($txt)-(length($num)-1)+($unit-1);
				#print "$tmp\t$long\n";
				if ($tmp>$long-1) {
					$space=$tmp-$long;
				}else{
					$space=$unit-1-(length($num)-1);
				}
				$num+=$unit;
			}
			$g->d("txtLB",$txt,"xval",$x,"yval",$y+$w{Char},"style",style($d{font}),);
		}else{
		}
		$y+=$rowWidth+$s{ROW_GAP};
	}
	$curRowPos+=$line->{Width};
}

sub hDrawTextBarBar{ #_START_=1
	my ($line,$curRowPos)=@_;
	my ($x,$y,$i,$j,$tmp,$long,$start,$color,$prelen);
	my ($txt,$txtLine,$tmpRow);
	$x = 0;
	$y = $curRowPos;
	foreach $i (@{$line->{Data}}) {
		$start=$i->[$i{s}];
		next if ($start > $START+$LEN-1);
		if ($start < $START) {
			$prelen=$START-$start;
			$start=$START;
		}else{
			$prelen=0;
		}
		$tmpRow=int(($start-$START)/$LONG); #_START_=1
		$color=$i->[$i{color}] ? $i->[$i{color}] : ($line->{Color} ? $line->{Color} : 'black');
		$y = $curRowPos+$tmpRow*($rowWidth+$s{ROW_GAP});
		$txt=$i->[$i{label}];
		#$txt=' ' x (($start-$START) % $LONG) . $txt;
		$long=$LONG;
		for ($j=$tmpRow;$j<$rowNum;$j++) {
			if ($j==$rowNum-1) {
				$long = $LEN % $LONG ? $LEN % $LONG : $LONG;
			}
			#print "$rowNum+$tmpRow-1\n";
			$d{font}{fill}=$color;
			#print "$txtLine=substr($txt,($j-$tmpRow)*$LONG,$long);\n";
			if ($j==$tmpRow) {
				$tmp=($start-$START) % $LONG;
				$txtLine=substr($txt,($j-$tmpRow)*$LONG+$prelen,$long-$tmp);
				#print $tmp,"\t",$prelen,"\n";
				$x=txtWidth(' ')*(($start-$START) % $LONG);
			}else{
				$txtLine=substr($txt,($j-$tmpRow)*$LONG-$tmp+$prelen,$long);
				$x=0;
			}
			last if ($txtLine eq '');
			if ($line->{Background} ne '') {
				$d{rect}{fill}=$line->{Background};
				$g->d("rect",'xval',$x,'yval',$y-$w{Char}/6,'width',txtWidth($txtLine),'height',$w{Char}*2/3,'style',style($d{rect}),"opacity",(1-$line->{BackgroundTransparence}));
			}
			$g->d("txtLM",$txtLine,"xval",$x,"yval",$y,"style",style($d{font}),);

			$y+=$rowWidth+$s{ROW_GAP};
		}
	}
	$curRowPos+=$line->{Width};
}

sub hDrawTextBar{ #_START_=0
	my ($line,$curRowPos)=@_;
	my ($x,$y,$i,$len,$start,$end,$tmp,$tmp2,$tmpy,$tmpx,$fontRotate,$fontScale,$iL,$layerNum,$Shift);
	my (@label,@labels);
	$Shift=$line->{Shift} ? $line->{Shift} : 0 ;
	$fontRotate=$line->{FontRotate};
	$fontScale=defined($line->{FontScale}) ? $line->{FontScale} : 1 ;
	$layerNum=defined($line->{LayerNum}) ? $line->{LayerNum} : 1;
	$tmp2=$line->{wChar}/$layerNum;
	@labels=move($line,0);
	$iL=-1;
	foreach $i (@{$line->{Data}}) {
		$iL++;
		$start=$i->[$i{s}]+$Shift;
		$end=$i->[$i{e}]+$Shift;
		if ($line->{IsHead}) {
			$start+=$START;
			$end+=$START;
		}
		next if ($end < $START);
		next if ($start > $START+$LEN-1);
		$d{font}{'fill'}=$i->[$i{color}] ? $i->[$i{color}] : ($line->{Color} ? $line->{Color} : 'black');
		$start=$START if ($start < $START);
		$end=$START+$LEN-1 if ($end > $START+$LEN-1);
		$x = ($start-$START+1) % $LONG;
		$y = $curRowPos+int(($start-$START+1)/$LONG)*($rowWidth+$s{ROW_GAP}); #_START_=0
		if ($line->{Pos}=~/u/i) { #up
			$y -= $s{LINE_GAP};#+$w{Char}/4;
		}
		@label=split(/\|/,$i->[$i{label}]);
		if ($fontRotate) {
			$y+=$line->{wChar};
			($tmpx,$tmpy)=getRealXY(int(($end-$start+1)/2),$x,$y);
			$tmpy-=$s{YSPACE}*2;
			$tmpy-=($labels[$iL]{layer})*$tmp2;
			$g->d("txtLB",$i->[$i{name}] ?  $i->[$i{name}] : $label[0],
				  "xval",0,
				  "yval",0,
				  "transform","translate(".($labels[$iL]{pos}*$SCALE).",$tmpy) rotate(-$fontRotate) scale($fontScale)",
				  "style",style($d{font}),
				);
		}else{
			($tmpx,$tmpy)=getRealXY(int(($end-$start+1)/2),$x,$y);
			$tmpy+=($layerNum-1-$labels[$iL]{layer})*$tmp2;
			$g->d("txtCT",$i->[$i{name}] ?  $i->[$i{name}] : $label[0],
				  "xval",0,
				  "yval",0,
				  "transform","translate(".($labels[$iL]{pos}*$SCALE).",$tmpy) scale($fontScale)",
				  "style",style($d{font}),
				);
			$y+=$line->{wChar};
		}
	}
	$curRowPos+=$line->{Width};
}

sub hDrawRectBar{ #_START_=0
	my ($line,$curRowPos)=@_;
	my ($x,$y,$i,$iL,$len,$start,$tmpStart,$end,
		$tmpy,$tmpx,$tmpl,$tmph,$tmpi,$last,$tmp,$tmp2,
		$fontScale,$fontRotate,$fontPos,$nopop,
		$rStroke,$rStrokeWidth,$layerNum,$Shift);
	my (@labels,@icolor,%pop);
	%pop=();
	$Shift=$line->{Shift} ? $line->{Shift} : 0 ;
	if ($line->{LongScale}) {
		$SCALE*=$line->{LongScale};
	}
	if ($line->{NoOutLine}) {
		$rStroke='none';
	}else{
		$rStroke=defined($line->{StrokeColor}) ? $line->{StrokeColor} : 'black';
	}
	$rStrokeWidth=defined($line->{StrokeWidth}) ? $line->{StrokeWidth} : $rectStrokeWidth;
	$line->{ExtScale} = $param{ExtScale} if (!$line->{ExtScale} && $param{ExtScale});
	$fontRotate=$line->{FontRotate};
	$fontScale=defined($line->{FontScale}) ? $line->{FontScale} : 1 ;
	$layerNum=defined($line->{LayerNum}) ? $line->{LayerNum} : 1;
	$nopop=defined($line->{NoPop}) ? $line->{NoPop} : defined($param{NoPop}) ? $param{NoPop} : 0;
	if ($line->{WithLabel} && $line->{WithLabel} !~ /^[lr]/i) {
		@labels=move($line,1);
	}
	$iL=-1;
	foreach $i (@{$line->{Data}}) {
		$iL++;
		$start=$i->[$i{s}]+$Shift;
		$end=$i->[$i{e}]+$Shift;
		if ($line->{IsHead}) {
			$start+=$START;
			$end+=$START;
		}
		if ($end < $START || $start > $START+$LEN-1) {
			if ($line->{WithArrow} && $i->[$i{dir}] ne '') {
				if ($end < $START) {
					$last=$i;
				}elsif ($start > $START+$LEN-1 && $last->[$i{s}]+$Shift <= $START+$LEN-1) {
					if (substr($i->[$i{dir}],0,1) ne substr($last->[$i{dir}],0,1)
						|| $i->[$i{dir}] == -1 
						|| $last->[$i{dir}] == +1 
						|| !$last 
						|| $last->[$i{e}] > $i->[$i{s}]
						) {
					}else{
						$d{path}{'stroke-width'}=$w{ArrowLine};
						$d{path}{'stroke'}=$line->{Color} ? $line->{Color} : $d{rect}{'fill'};
						if ($d{path}{'stroke'} eq 'none') {
							$d{path}{'stroke'}='black';
						}
						$tmp=$curRowPos+$w{Rect}+$s{LINE_GAP}/2;
						if ($line->{WithLabel} && $line->{WithLabel} !~ /^[lr]/i) {
							$tmp+=$line->{wChar};#+$s{YSPACE}*2;
						}
						hDrawLine($tmp,$last->[$i{e}]+$Shift,$i->[$i{s}]+$Shift,$d{path}{'stroke'},$w{ArrowLine},$i->[$i{dir}]);
					}
					$last=$i;
				}
			}
			next;
		}
		$end = $start+($end-$start+1) * $line->{ExtScale}-1 if ($line->{ExtScale});
		@icolor=split(/\|/,$i->[$i{color}]);
		if (int($icolor[0]) > 0) {
			$d{rect}{'fill'}=$color[$icolor[0]-1][0];
		}else{
			$d{rect}{'fill'}=$icolor[0] ? $icolor[0] : ($line->{Color} ? $line->{Color} : 'black');
		}
		if (int($icolor[1]) > 0) {
			$d{rect}{'stroke'}=$color[$icolor[1]-1][0];
		}else{
			$d{rect}{'stroke'}=$icolor[1] ? $icolor[1] : $rStroke;
		}
		$d{rect}{'stroke-width'}=($icolor[2] ne '') ? $icolor[2] : $rStrokeWidth;

		$start=$START if ($start < $START);
		$end=$START+$LEN-1 if ($end > $START+$LEN-1);
		$y = $curRowPos+int(($start-$START+1)/$LONG)*($rowWidth+$s{ROW_GAP}); #_START_=0
		$fontPos=$y;
		if ($line->{WithLabel}  && $line->{WithLabel} !~ /^[lr]/i) {
			$y+=$line->{wChar};
			if ($fontRotate) {
				$fontPos=$y;
			}
		}
		$tmpStart=$start;
		if (!$nopop) {
			%pop=("onclick"=>"alert('start:$i->[$i{s}]\\nend:$i->[$i{e}]".($i->[$i{name}] ? "\\nname:$i->[$i{name}]" : '')."')");
		}
		while ($end>=$tmpStart) {
			$len = $end-$tmpStart+1;
			#print "$tmpStart\t$end\t$len\n";
			#printf("$end\t$tmpStart\t$LONG\t%d\t%d\n",(($end-$START+1) % $LONG),(($tmpStart-$START+1) % $LONG));
			$x = ($tmpStart-$START+1) % $LONG; #_START_=0
			$len = ($len > $LONG || (($end-$START+1) % $LONG < $x)) 
					? ($LONG-$x+1) : $len;
			#print "$x\t$len\t$LONG\n";
			$d{polygon}{'stroke'}=$d{rect}{'stroke'};
			$d{polygon}{'fill'}=$d{rect}{'fill'};
			$tmpy=$y;
			$tmpl=min($w{ArrowSize},$len*$SCALE);
			$tmph=$tmpl/$w{ArrowSize}*($w{Rect}/2);
			if ($line->{IsArrow} && $i->[$i{dir}] ne '' && ($i->[$i{dir}] == +1 && (($x+$len-1) < $LONG))) {	#Rigth Arrow
				$tmpx=($x+$len-1)*$SCALE;
				$tmpy+=$w{Rect}/2;
				if ($w{ArrowSize}>=$len*$SCALE) {
					$g->d("polygon","points",($tmpx)." ".($tmpy).","
											.($tmpx-$tmpl)." ".($tmpy-$tmph).","
											.($tmpx-$tmpl)." ".($tmpy+$tmph),
						  "style",style($d{polygon}),%pop
					);
				}else{
					$g->d("polygon","points",($tmpx)." ".($tmpy).","
											.($tmpx-$tmpl)." ".($tmpy-$tmph).","
											.($x*$SCALE)." ".($tmpy-$tmph).","
											.($x*$SCALE)." ".($tmpy+$tmph).","
											.($tmpx-$tmpl)." ".($tmpy+$tmph),
						  "style",style($d{polygon}),%pop
					);
				}
			}elsif ($line->{IsArrow} && $i->[$i{dir}] ne '' && ($i->[$i{dir}] == -1 && ($x > 1))) {	#Left Arrow
				$tmpx=($x*$SCALE);
				$tmpy+=$w{Rect}/2;
				if ($w{ArrowSize}>=$len*$SCALE) {
					$g->d("polygon","points",($tmpx)." ".($tmpy).","
											.($tmpx+$tmpl)." ".($tmpy-$tmph).","
											.($tmpx+$tmpl)." ".($tmpy+$tmph),
						  "style",style($d{polygon}),%pop
					);
				}else{
					$g->d("polygon","points",($tmpx)." ".($tmpy).","
											.($tmpx+$tmpl)." ".($tmpy-$tmph).","
											.(($x+$len-1)*$SCALE)." ".($tmpy-$tmph).","
											.(($x+$len-1)*$SCALE)." ".($tmpy+$tmph).","
											.($tmpx+$tmpl)." ".($tmpy+$tmph),
						  "style",style($d{polygon}),%pop
					);
				}
			}else{
				$g->d("rect","xval",$x*$SCALE,
					  "yval",$tmpy,
					  "width",$len*$SCALE,
					  "height",$w{Rect},
					  "style",style($d{rect}),%pop
				);
			}
			if ($line->{WithArrow} && $i->[$i{dir}] ne '') {
				$d{path}{'stroke-width'}=$w{ArrowLine};
				$d{path}{'stroke'}=$line->{Color} ? $line->{Color} : $d{rect}{'fill'};
				if ($d{path}{'stroke'} eq 'none') {
					$d{path}{'stroke'}='black';
				}
				$d{polygon}{'stroke'}='none';
				$d{polygon}{'fill'}=$d{path}{'stroke'};
				$tmpy=$y+$w{Rect}+$s{LINE_GAP}/2;
				if ($i->[$i{dir}] == +1 || (($x+$len-1) >= $LONG && $i->[$i{dir}] eq '+')) {	#Rigth Arrow
					$tmpx=($x+$len-1)*$SCALE;
					$g->d("polygon","points",($tmpx)." ".($tmpy).","
											.($tmpx-$w{ArrowSize})." ".($tmpy-$w{ArrowSize}).","
											.($tmpx-$w{ArrowSize})." ".($tmpy+$w{ArrowSize}),
						  "style",style($d{polygon}));
					if ($x*$SCALE<=($x+$len-1)*$SCALE-$w{ArrowSize}) {
						$g->d("line","x1",$x*$SCALE,"y1",$tmpy,"x2",($x+$len-1)*$SCALE-$w{ArrowSize},"y2",$tmpy,"style",style($d{path}));
					}
				}elsif ($i->[$i{dir}] == -1 || ($x <= 1 && $i->[$i{dir}] eq '-')) {	#Left Arrow
					$tmpx=($x*$SCALE);
					$g->d("polygon","points",($tmpx)." ".($tmpy).","
											.($tmpx+$w{ArrowSize})." ".($tmpy-$w{ArrowSize}).","
											.($tmpx+$w{ArrowSize})." ".($tmpy+$w{ArrowSize}),
						  "style",style($d{polygon}));
					if ($x*$SCALE+$w{ArrowSize}<=($x+$len-1)*$SCALE) {
						$g->d("line","x1",$x*$SCALE+$w{ArrowSize},"y1",$tmpy,"x2",($x+$len-1)*$SCALE,"y2",$tmpy,"style",style($d{path}));
					}
				}else{
					$g->d("line","x1",$x*$SCALE,"y1",$tmpy,"x2",($x+$len-1)*$SCALE,"y2",$tmpy,"style",style($d{path}));
				}
			}
			$tmpStart+=$len;
			$y+=$rowWidth+$s{ROW_GAP};
		}
		if ($line->{WithArrow} && $i->[$i{dir}] ne '') {	#两个exon之间的线
			if (substr($i->[$i{dir}],0,1) ne substr($last->[$i{dir}],0,1)
				|| $i->[$i{dir}] == -1 
				|| $last->[$i{dir}] == +1 
				|| !$last 
				|| $last->[$i{e}] > $i->[$i{s}]
				) {
			}else{
				$tmp=$curRowPos+$w{Rect}+$s{LINE_GAP}/2;
				if ($line->{WithLabel} && $line->{WithLabel} !~ /^[lr]/i) {
					$tmp+=$line->{wChar};#+$s{YSPACE}*2;
				}
				hDrawLine($tmp,$last->[$i{e}]+$Shift,$i->[$i{s}]+$Shift,$d{path}{'stroke'},$w{ArrowLine},$i->[$i{dir}]);
			}
			$last=$i;
		}
		if ($line->{WithLabel}) {
			#print "$tmpx\t$tmpy\t$i->[$i{label}] ? $i->[$i{label}] : $i->[$i{name}]\n";
			$tmp2=$line->{wChar}/$layerNum;
			$i->[$i{label}]=~/[^\|]+/;
			$tmp=$&;
			if ($line->{WithLabel} !~ /^[lr]/i) {
				($tmpx,$tmpy)=getRealXY(int(($end-$start+1)/2),$start,$fontPos);
				if ($fontRotate) {
					$tmpy-=$s{YSPACE}*2;
					$tmpy-=($labels[$iL]{layer})*$tmp2;
					$g->d("txtLB",$i->[$i{label}] ? $tmp : $i->[$i{name}],
						  "xval",0,
						  "yval",0,
						  "transform","translate(".($labels[$iL]{pos}*$SCALE).",$tmpy) rotate(-$fontRotate) scale($fontScale)",
						  "style",style($d{font}),
					);
				}else{
					$tmpy+=($layerNum-1-$labels[$iL]{layer})*$tmp2;
					$g->d("txtCT",$i->[$i{label}] ? $tmp : $i->[$i{name}],
						  "xval",0,
						  "yval",0,
						  "transform","translate(".($labels[$iL]{pos}*$SCALE).",$tmpy) scale($fontScale)",
						  "style",style($d{font}),
					);
				}
			}else{
				if ($line->{WithLabel} =~ /^l/i) {
					$g->d("txtRM",$i->[$i{label}] ? $tmp : $i->[$i{name}],
						  "xval",0,
						  "yval",0,
						  "transform","translate(".($start*$SCALE-$s{XSPACE}*2).",".($fontPos+$w{Rect}/2).") scale($fontScale)",
						  "style",style($d{font}),
					);
				}else{
					($tmpx,$tmpy)=getRealXY($end-$start+1,$start,$fontPos);
					$g->d("txtLM",$i->[$i{label}] ? $tmp : $i->[$i{name}],
						  "xval",0,
						  "yval",0,
						  "transform","translate(".($tmpx*$SCALE+$s{XSPACE}*2).",".($tmpy+$w{Rect}/2).") scale($fontScale)",
						  "style",style($d{font}),
					);
				}
			}
		}
	}
	if ($line->{LongScale}) {
		$SCALE/=$line->{LongScale};
	}
	$curRowPos+=$line->{Width};
}

sub hDrawLine{ #_START_=0
	my ($curRowPos,$start,$end,$color,$width,$arrowDir)=@_;
	my ($x,$y,$len,$tmpx,$tmp);
	return if ($end < $START);
	return if ($start > $START+$LEN-1);
	$d{path}{'stroke-width'}=$width;
	$d{path}{'stroke'}=$color ? $color : 'black';
	$start=$START if ($start < $START);
	$end=$START+$LEN-1 if ($end > $START+$LEN-1);
	$y = $curRowPos+int(($start-$START+1)/$LONG)*($rowWidth+$s{ROW_GAP}); #_START_=0
	while ($end>=$start) {
		$len = $end-$start+1;
		#printf("$end\t$start\t$LONG\t%d\t%d\n",(($end-$START+1) % $LONG),(($start-$START+1) % $LONG));
		$x = ($start-$START+1) % $LONG; #_START_=0
		$len = ($len > $LONG || (($end-$START+1) % $LONG < $x)) 
				? ($LONG-$x+1) : $len;
		if ($arrowDir) {
			$d{polygon}{'stroke'}='none';
			$d{polygon}{'fill'}=$color;
			if ($arrowDir =~ /\+/ && ($x+$len-1) >= $LONG-$w{ArrowSize}) {
				$tmpx=($x+$len-1)*$SCALE;
				$g->d("polygon","points",($tmpx)." ".($y).","
										.($tmpx-$w{ArrowSize})." ".($y-$w{ArrowSize}).","
										.($tmpx-$w{ArrowSize})." ".($y+$w{ArrowSize}),
					  "style",style($d{polygon}));
				$tmp=max(($x+$len-1)*$SCALE-$w{ArrowSize},$x*$SCALE);
				#print "$tmp=max(($x+$len-1)*$SCALE-$w{ArrowSize},$x*$SCALE);\n";
				if ($x*$SCALE<=($x+$len-1)*$SCALE-$w{ArrowSize}) {
					$g->d("line","x1",$x*$SCALE,"y1",$y,"x2",($x+$len-1)*$SCALE-$w{ArrowSize},"y2",$y,"style",style($d{path}));
				}
			}elsif ($arrowDir =~ /\-/ && $x <= 1+$w{ArrowSize} ) {
				$tmpx=($x*$SCALE);
				$g->d("polygon","points",($tmpx)." ".($y).","
										.($tmpx+$w{ArrowSize})." ".($y-$w{ArrowSize}).","
										.($tmpx+$w{ArrowSize})." ".($y+$w{ArrowSize}),
					  "style",style($d{polygon}));
				$tmp=min($x*$SCALE+$w{ArrowSize},($x+$len-1)*$SCALE);
				#print "$tmp=min($x*$SCALE+$w{ArrowSize},($x+$len-1)*$SCALE);\n";
				if ($x*$SCALE+$w{ArrowSize}<=($x+$len-1)*$SCALE) {
					$g->d("line","x1",$x*$SCALE+$w{ArrowSize},"y1",$y,"x2",($x+$len-1)*$SCALE,"y2",$y,"style",style($d{path}));
				}
			}else{
				$g->d("line","x1",$x*$SCALE,"y1",$y,"x2",($x+$len-1)*$SCALE,"y2",$y,"style",style($d{path}));
			}
		}else{
			$g->d("line","x1",$x*$SCALE,"y1",$y,"x2",($x+$len-1)*$SCALE,"y2",$y,"style",style($d{path}));
		}
		$start+=$len;
		$y+=$rowWidth+$s{ROW_GAP};
	}
}

sub hDrawScaleBar{ #_START_=0
	my ($line,$curRowPos)=@_;
	my ($x,$y,$i,$j,$tmp,$lastx,$lasty,
		$long,$unit,$unitDiv,$divLen,
		$scaleUnit,$start,$color,$mark,$scaleMark,
		$xMark,$jstart,$yOffset,$prolong,$anum);
	my ($Start,$End,$startRow,$endRow,$Shift,$tmpShift);
	$Shift=$line->{Shift} ? $line->{Shift} : 0 ;
	$tmpShift=$START>$Shift ? 0 : $Shift-$START;
	$Start=defined($line->{Start}) ? $line->{Start} : $START ;
	$End=defined($line->{End}) ? $line->{End} : $END;
	$Start+=$tmpShift;
	$End+=$tmpShift;
	if ($Start>$END || $End<$START) {
		$curRowPos+=$line->{Width};
		return $curRowPos;
	}
	$Start-=$START;
	$Start=0 if ($Start<0);
	$End-=$START;
	$End=min($End,$LEN);
	$startRow=$Start ? int(($Start-1)/$LONG) : 0 ;
	$endRow=int(($End-1)/$LONG);
	$y = $curRowPos+($rowWidth+$s{ROW_GAP})*$startRow;
	$yOffset=0;
	if (!$line->{NoScale} && !$line->{ScaleAside} && $line->{ScaleUp}) {
		$yOffset+=$w{Char};
	}
	if (!$line->{NoScaleLine} && $line->{ScaleLineUp}){
		$yOffset+=$w{Scale};
	}

	$prolong=$line->{Prolong} ? $line->{Prolong} : 1;
	$unit = $line->{Unit} ? $line->{Unit} : $param{Unit};
	$unitDiv = $line->{UnitDiv} ? $line->{UnitDiv} : $param{UnitDiv};
	$divLen = $unit/$unitDiv;
	$scaleUnit = $line->{ScaleUnit} ? $line->{ScaleUnit} : ($param{ScaleUnit} ? $param{ScaleUnit} : 1);
	$scaleMark = $scaleUnit==1 ? '' : 'x'.$scaleUnit;
	$scaleMark = "e".log($scaleUnit) if (int(log($scaleUnit)) == log($scaleUnit) && $scaleUnit > 1);
	$scaleMark = "K" if ($scaleUnit == 1000);
	$scaleMark = "M" if ($scaleUnit == 1000000);
	$anum=$scaleUnit;
	$anum *= $prolong if ($prolong > 0);
	$color = $line->{Color} ne '' ? $line->{Color} : 'black';
	$d{path}{'stroke-width'}=defined($line->{LineWidth}) ? $line->{LineWidth} : $w{Line};
	if ($d{path}{'stroke-width'}<=0) {
		$curRowPos+=$line->{Width};
		return $curRowPos;
	}
	for ($i=$startRow;$i<=$endRow;$i++) {
		if ($i==$startRow) {
			$x=$Start % $LONG;
		}else{
			$x=0;
		}
		if ($i==$endRow) {
			$long = ($End % $LONG ? $End % $LONG : $LONG) - $x;
		}else{
			$long = $LONG - $x;
		}
		$d{path}{'stroke'}=$color;
		$g->d("line","x1",$x*$SCALE,"y1",$y+$yOffset,"x2",($x+$long)*$SCALE,"y2",$y+$yOffset,"style",style($d{path}));
		{
			$mark=$start=$i*$LONG+$START-$ZERO_VAL;
			if (!$line->{NoScale} && $line->{ScaleAside}) {
				$g->d("txtRM",nint($mark/$anum,$scaleUnit),"xval",-$s{XGAP1},"yval",$y,"style",style($d{font}));
				$g->d("txtLM",nint(($mark+$long)/$anum,$scaleUnit).($scaleMark),"xval",$long*$SCALE+$s{XGAP1},"yval",$y,"style",style($d{font}));
				#$tmp=$long*$SCALE+$s{XGAP1}+txtWidth(nint($mark+$long)/$anum,$scaleUnit);
				#$d{font}{'font-size'}*=3/4;
				#$g->d("txtLT",$scaleMark,"xval",$tmp,"yval",$y,"style",style($d{font}));
				#$d{font}{'font-size'}/=3/4;
			}
			$jstart=($start) % $divLen ? ($divLen - ($start) % $divLen) : 0;
			for ($j=0;$j<($long+$x)/$divLen;$j++) {
				$xMark=($j*$divLen+$jstart)+$Shift%$divLen;
				#$xMark/=-$prolong if ($prolong<0);
				next if ($xMark < $x);
				last if ($xMark > ($long+$x));
				if ((($start+$jstart)/$divLen+$j-int($Shift/$divLen)) % $unitDiv == 0) {
					$g->d("line",
						  "x1",$xMark*$SCALE,
						  "y1",$y+$yOffset,
						  "x2",$xMark*$SCALE,
						  "y2",$y+$yOffset+($line->{ScaleLineUp} ? -$w{Scale} : $w{Scale}),
						  "style",style($d{path}),
						 ) if (!$line->{NoScaleLine});
					if (!$line->{NoScale} && !$line->{ScaleAside}) {
						#print "$xMark\t".style($d{font})."\n";
						$mark=$xMark+$start-$Shift;
						$mark/=$anum;
						$g->d("txtCT",nint($mark,$scaleUnit),"xval",$xMark*$SCALE,"yval",$y+($line->{ScaleUp} ? 0 : $w{Scale})+$s{YSPACE},"style",style($d{font}));
						$lastx=$xMark*$SCALE+txtWidth(nint($mark,$scaleUnit))/2;
						$lasty=$y+($line->{ScaleUp} ? 0 : $w{Scale})+$s{YSPACE};
					}
				}else{
					$d{path}{'stroke-width'}*=2/3;
					$g->d("line",
						  "x1",$xMark*$SCALE,
						  "y1",$y+$yOffset,
						  "x2",$xMark*$SCALE,
						  "y2",$y+$yOffset+($line->{ScaleLineUp} ? -$w{Scale} : $w{Scale})*1/2,
						  "style",style($d{path})
						 ) if (!$line->{NoScaleLine});
					$d{path}{'stroke-width'}*=3/2;
				}
			}
			if (!$line->{NoScale} && !$line->{ScaleAside} && !$line->{NoScaleMark} && !$nosmark && defined($lastx) && defined($lasty)) {
				#$lasty+=$w{Char}/4;
				#$d{font}{'font-size'}*=3/4;
				$g->d("txtLT",$scaleMark,"xval",$lastx,"yval",$lasty,"style",style($d{font}));
				#$d{font}{'font-size'}/=3/4;
			}
		}
		$y+=$rowWidth+$s{ROW_GAP};
	}
	$curRowPos+=$line->{Width};
}

sub hDrawVLine {
	my ($line)=@_;
	my (@icolor,@label);
	my ($i,$j,$x,$y,$start,$Shift,$rowPos,
		$sl,$el,$s,$e,$tmps,$tmpe,$tsl,$tel);
	$Shift=$line->{Shift} ? $line->{Shift} : 0 ;
	$sl=$line->{StartLine}>0 ? $line->{StartLine} : 0;
	$el=($line->{EndLine} ne '') ? $line->{EndLine} : $#list;
	($sl,$el)=($el,$sl) if ($sl > $el);
	if ($sl>$#list || $sl<0 || $el>$#list || $el<0) {
		$sl=0;$el=$#list;
	}
	$s=$rowHeight[$sl];
	$e=$rowHeight[$el]+$list[$el]->{Width};
	foreach $i (@{$line->{Data}}) {
		$start=$i->[$i{s}]+$Shift;
		if ($start>$END || $start<$START) {
			next;
		}
		$rowPos=int(($start-$START+1)/$LONG)*($rowWidth+$s{ROW_GAP});
		$x = ($start-$START+1) % $LONG;
		$tmps=$s;$tmpe=$e;
		if ($i->[$i{dir}] ne '') {
			($tsl,$tel)=split(/\|/,$i->[$i{dir}]);
			($tsl,$tel)=($tel,$tsl) if ($tsl > $tel);
			if ($tsl eq '' || $tsl>$#list || $tsl<0) {
				$tsl=$sl;
			}
			if ($tel eq '' || $tel>$#list || $tel<0) {
				$tel=$el;
			}
			$tmps=$rowHeight[$tsl];
			$tmpe=$rowHeight[$tel]+$list[$tel]->{Width};
		}
		@icolor=split(/\|/,$i->[$i{color}]);
		if ($icolor[1]>0) {
			$d{path}{'stroke'}=($icolor[0] ne '') ? $icolor[0] : ($line->{Color} ? $line->{Color} : 'black');
			$d{path}{'stroke-width'}=($icolor[1] ne '') ? $icolor[1] : $w{Line};
			if ($line->{LineDash} ne '') {
				$d{path}{'stroke-dasharray'}=$line->{LineDash} ;
			}
			$g->d("line","x1",$x*$SCALE,"y1",$rowPos+$tmps,"x2",$x*$SCALE,"y2",$rowPos+$tmpe,"style",style($d{path}));
			if ($line->{LineDash} ne '') {
				delete($d{path}{'stroke-dasharray'});
			}
		}
		if ($i->[$i{label}] ne '' || $i->[$i{name}] ne '') {
			@label=split(/\|/,$i->[$i{label}]);
			if ($label[1] > 0) {
				$d{font}{'font-size'}*=$label[1];
				$g->setFontSize($d{font}{'font-size'});
			}
			$g->d("txtCM",($label[0] ne '' ? $label[0] : $i->[$i{name}]),
				  "xval",$x*$SCALE,
				  "yval",$rowPos+($tmps+$tmpe)/2,
				  "style",style($d{font}),
				);
			if ($label[1] > 0) {
				$d{font}{'font-size'}/=$label[1];
				$g->setFontSize($d{font}{'font-size'});
			}
		}
	}
}

sub nint {
	my ($num,$i)=@_;
	return $num if ($i<=0);
	$i=10**int((log($i)/log(10)).'');
	return(int($num*$i+0.5)/$i);
}

sub getRealXY{
	my ($len,$start,$y)=@_; #入口: $len为长度 $y为$start对应的$y
	my ($end,$x);
	$end=$start+$len-1;
	if ($len==0) {
		$x=$start;
	}elsif ($len>0) {
		$x=($end-$START+1) % $LONG;
		if ($len > $LONG) {
			while ($len > $LONG) {
				$y+=$rowWidth+$s{ROW_GAP};
				$len-=$LONG;
			}
		}
		if ($x < ($start-$START+1) % $LONG) {
			$y+=$rowWidth+$s{ROW_GAP};
		}
	}elsif ($end>=$START) {
		$x=($end-$START+1) % $LONG;
		$len=-$len;
		if ($len > $LONG) {
			while ($len > $LONG) {
				$y-=$rowWidth+$s{ROW_GAP};
				$len-=$LONG;
			}
		}
		if ($x > ($start-$START+1) % $LONG) {
			$y-=$rowWidth+$s{ROW_GAP};
		}
	}else{
		$len = $START-$end;
		$x=-$len;
	}
	return ($x,$y);
}

sub move{
	my ($line,$isLabel)=@_;
	my (@lines,@ret,@tmp);
	my ($i,$j,$tmp,$label,$fontScale,$fontRotate,$radin,$maxLen,$Shift);
	my $MOVE_NUM=2;
	my $MOVE_PER=1/5;
	local our ($wordWidth,$layerNum,$xEnd);
	$xEnd=min($LONG,$LEN);
	my $maxLen=$isLabel ? ($line->{MaxLabelLen} ? $line->{MaxLabelLen} : $line->{MaxNameLen}) : ($line->{MaxNameLen} ? $line->{MaxNameLen} : $line->{MaxLabelLen});
	@lines=();
	@ret=();
	$Shift=$line->{Shift} ? $line->{Shift} : 0 ;
	$fontRotate=$line->{FontRotate};
	$fontScale=defined($line->{FontScale}) ? $line->{FontScale} : 1 ;
	$layerNum=defined($line->{LayerNum}) ? $line->{LayerNum} : 1;
	$radin = PI*$fontRotate/180;
	$tmp=abs(sin($radin));
	if ($tmp!=0) {
		$tmp=$w{Char}/$tmp;
		if (cos($radin)==0) {
			$wordWidth=$tmp;
		}else{
			$wordWidth=($tmp > $maxLen/cos($radin)) ? $maxLen/cos($radin) : $tmp;
		}
	}else{
		$wordWidth=$maxLen;
	}
	$wordWidth*=$fontScale;
	foreach $i (@{$line->{Data}}) {
		$tmp={};
		$tmp->{start}=$i->[$i{s}]+$Shift;
		$tmp->{end}=$i->[$i{e}]+$Shift;
		if ($line->{IsHead}) {
			$tmp->{start}+=$START;
			$tmp->{end}+=$START;
		}
		if ($tmp->{end} < $START || $tmp->{start} > $START+max($LONG,$LEN)-1) {
			push(@ret,{});
			next;
		}
#		$label=(split(/\|/,$i->[$i{label}]))[0];
#		$tmp->{name}=$i->[$i{name}];
#		$tmp->{label}=$i->[$i{label}];

		$tmp->{start}=$START if ($tmp->{start} < $START);
		$tmp->{end}=$START+max($LONG,$LEN)-1 if ($tmp->{end}> $START+max($LONG,$LEN)-1);
		$tmp->{start}-=$START+1;
		$tmp->{end}-=$START+1;
#		$tmp->{name}=$i->[$i{name}];

#		$tmp->{moveable}=1;
		$tmp->{pos}=int(($tmp->{start}+$tmp->{end})/2) % $xEnd;
		$tmp->{row}=int(($tmp->{start}+$tmp->{end})/2 / $xEnd)+1;
		$tmp->{layer}= defined($i->[$i{layer}]) ? ($i->[$i{layer}] > $layerNum-1 ? $layerNum-1 : $i->[$i{layer}]) : 0;
		push(@{$lines[$tmp->{layer}]},$tmp);
		push(@ret,$tmp);
	}
	#@tmp=();
	if ($line->{AutoAlign}) {
		for ($i=0;$i<=$#lines;$i++) {
			last if (!defined($lines[$i]));
			@{$lines[$i]}=sort {$a->{start} <=> $b->{start}} @{$lines[$i]};
			@tmp=move_part($lines[$i],$width1st);
			foreach  (@tmp) {
				push (@{$lines[$_->{layer}]},$_);
			}
			#push(@tmp,@{$line[$i]});
		}
	}
	return @ret;

	sub move_part{
		my ($list,$width1st)=@_;
		my ($i,$j,$k,@tmp,$tmp,$tmp2,
			$spos,$epos,$mpos,$mi,
			$num,$lastEpos,$row);
		$i=0;
		$num=$#$list;
		$lastEpos=0;
		@tmp=();
		L1:while ($i<=$num) {
			$row=$$list[$i]->{row};
			$spos=int($$list[$i]->{pos}-$wordWidth/$SCALE/2);
			if ($i>0 && $$list[$i-1]->{row} == $row) {
				$tmp=int($$list[$i-1]->{pos}+$wordWidth/$SCALE/2);
				$tmp=$lastEpos if ($spos<$lastEpos);
			}else{
				$tmp=-int($wordWidth/$SCALE);
			}
			if ($width1st || $spos<$tmp) {
				$spos=$tmp;
			}

			$epos=int($$list[$i]->{pos}+$wordWidth/$SCALE/2);
			if ($i<$num && $row == $$list[$i+1]->{row}) {
				$tmp=int($$list[$i+1]->{pos}-$wordWidth/$SCALE/2);
			}else{
				$tmp=int($xEnd+$wordWidth/$SCALE);
			}
			if ($width1st || $epos>$tmp) {
				$epos=$tmp;
			}
			$j=$i+1;
			while (($row == $$list[$j]->{row}) && ($epos-$spos)*$SCALE < ($j-$i)*$wordWidth-1 && $j<$num) {
				$epos=int($$list[$j]->{pos}+$wordWidth/$SCALE/2);
				if ($$list[$j]->{row} == $$list[$j+1]->{row}) {
					$tmp=int($$list[$j+1]->{pos}-$wordWidth/$SCALE/2);
				}else{
					$tmp=int($xEnd+$wordWidth/$SCALE);
					if ($width1st) {
						$epos=$tmp;
						last;
					}
				}
				if ($width1st || $epos>$tmp) {
					$epos=$tmp;
				}
				$mi=int(($j+$i)/2);
				#$mi=$i+1 if ($mi==$i);
				if (int(($j-$i)/$MOVE_NUM)%2) {
					for ($tmp=0;$tmp<=$mi-$i;$tmp++) {
						foreach (($mi-$tmp,$mi+$tmp)) {
							if ($list->[$_]{layer}<$layerNum-1 && $_<$j) {
								$$list[$_]->{layer}++;
#								if ($$list[$_+1]->{moveable}) {
#									$$list[$_+1]->{moveable}=0;
#								}
								push(@tmp,$$list[$_]);
								for ($k=$_;$k<$num;$k++) {
									$$list[$k]=$$list[$k+1];
								}
								$num--;
								next L1;
							}
						}
					}
				}
				$j++;
			}
			if ($width1st) {
				$mi=int(($j+$i)/2);
				if (($$list[$j-1]->{end}-$$list[$i]->{start})*$SCALE <= ($j-$i)*$wordWidth*$MOVE_PER && $j-$i>3) {
					for ($tmp=0;$tmp<=$mi-$i;$tmp++) {
						foreach (($mi-$tmp,$mi+$tmp)) {
							if ($list->[$_]{layer}<$layerNum-1) {
								$$list[$_]->{layer}++;
#								if ($$list[$_+1]->{moveable}) {
#									$$list[$_+1]->{moveable}=0;
#								}
								push(@tmp,$$list[$_]);
								for ($k=$_;$k<$num;$k++) {
									$$list[$k]=$$list[$k+1];
								}
								$num--;
								next L1;
							}
						}
					}
				}
			}
			$mpos=$$list[$mi]->{pos};
			if ($mpos+($j-1-$mi)*$wordWidth/$SCALE > $epos-$wordWidth/$SCALE/2) {
				$mpos=$epos-$wordWidth/$SCALE/2-($j-1-$mi)*$wordWidth/$SCALE;
			}
			if ($mpos-($mi-$i)*$wordWidth/$SCALE < $spos+$wordWidth/$SCALE/2) {
				$mpos=$spos+$wordWidth/$SCALE/2+($mi-$i)*$wordWidth/$SCALE;
			}
			$lastEpos=$mpos+$wordWidth/$SCALE/2+($j-1-$mi)*$wordWidth/$SCALE;
			#print STDERR "$spos,$epos,$mpos,$lastEpos\n";
			while ($i<$j) {
				if ($i!=$j-1 || $$list[$i]->{pos}<int($mpos-($mi-$i)*$wordWidth/$SCALE)) {
					$$list[$i]->{pos}=int($mpos-($mi-$i)*$wordWidth/$SCALE);
				}
				$i++;
			}
		}
		$#$list=$num;
		return @tmp;
	}
}

sub style{
	my($style)=@_;
	my $str="";
	for (keys %$style) {
		$str.="$_:$style->{$_};";
	}
	chop($str);
	return $str;
}

sub availDigit{
	my ($num,$n,$rounding)=@_;
	my $log10=log($num)/log(10);
	$log10 = $log10 >0 ? int($log10) : int($log10)==$log10 ? $log10 : int($log10-1);
	return int($num*10**($n-1)/10**$log10+0.5*$rounding)*10**$log10/10**($n-1);
}

sub uint{
	my($num,$div)=@_;
	$div = 1 if (!$div);
	my $tmp=$num/$div;
	if ($tmp!=oint($tmp)) {
		$tmp=oint($tmp+1);
	}
	$tmp*=$div;
	return $tmp;
}

sub oint{
	my($num)=@_;
	if ($num>0) {
		return int($num);
	}else{
		return int($num)==$num ? $num : int($num)-1;
	}
}

sub fx{
	my ($num)=@_;
	#return uint($num,1);
	return sprintf("%f",$num);
}

sub fy{
	my ($num)=@_;
	#return uint($num,1);
	return sprintf("%f",$num);
}

sub cut{
	my ($num)=@_;
	return oint($num*1000000000)/1000000000;
}

sub txtWidth{
	my($str)=@_;
	return $g->textWidth($d{font}{'font-size'},$g->{charspacing},$g->{wordspacing},$g->{hscaling},$str);
}

sub max{
	my($m1,$m2)=@_;
	$m1 > $m2 ? $m1 : $m2;
}

sub min{
	my($m1,$m2)=@_;
	$m1 < $m2 ? $m1 : $m2;
}

sub rev{
	my($m1,$m2)=@_;
	my($tmp);
	$tmp=$$m2;
	$$m2=$$m1;
	$$m1=$tmp;
}

sub error{
	my($str,$ret)=@_;
	foreach (@errhis) {
		return if ($_ eq $str);
	}
	push(@errhis,$str);
	warn "\n|~|~|~|~|~|~|~|~|~|~|~|~|~|~|\n";
	warn "$str\n";
	warn "|_|_|_|_|_|_|_|_|_|_|_|_|_|_|\n";
	die "\n" if (!$ret);
	print "\n";
	return $str;
}
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#	End
#/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
