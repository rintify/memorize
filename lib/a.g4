grammar a;

start : segment (SEG+ segment)* EOF;

segment : tags frag+;

tags : (TAG S)*;

frag : (kanjis | NUM | ~KANJI)+ ;

kanjis : KANJI+ HURIGANA? ;

NUM: '(' [0-9]+ ')';
SEG: '/';
HURIGANA: '{' .*? '}';
KANJI : [\u2E80-\u2FDF\u3005\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF\u{20000}-\u{3FFFF}]+;
S: ' ';
TAG: '#' ~[ #]+;