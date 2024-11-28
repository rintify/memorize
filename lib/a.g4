grammar a;

start : segment (SEG+ segment)* EOF;

segment : tags? frag;

tags : (TAG S)+;

frag : (kanjis | NUM | MOJI)+ ;

kanjis : KANJI+ HURIGANA? ;

NUM: '(' [0-9]+ ')';
SEG: '/';
HURIGANA: '{' [^}]* '}';
KANJI: [A-Z]+;
MOJI: [a-z]+;
S: ' ';
TAG: '#' [^ #]+;