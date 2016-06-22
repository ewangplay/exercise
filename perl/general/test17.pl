#!/usr/bin/perl -w

push(@INC, "package");
use Student;
use GraduateStudent;

$student1 = new Student("name"=>"Tom", "age"=>20, "major"=>"English");
$major = $student1->getMajor();
print "student1's major is ".$major."\n";

$major = "Chinese";
$student1->setMajor($major);
print "student1's major is ".$student1->getMajor()."\n";

$stu2 = new GraduateStudent("name"=>"Marry", "age"=>21, "major"=>"Computer", "doctor"=>"Bean");
print "student2's name is ".$stu2->{"name"}."\n";
print "student2's age is ".$stu2->{"age"}."\n";
print "student2's major is ".$stu2->getMajor()."\n";
print "student2's doctor is ".$stu2->getDoctor()."\n";

$stu2->setMajor("English");
$stu2->setDoctor("Recho");
print "student2's major is ".$stu2->getMajor()."\n";
print "student2's doctor is ".$stu2->getDoctor()."\n";


