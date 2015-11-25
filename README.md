MorphGNT SBLGNT
===============

Project to merge the MorphGNT analysis with the SBLGNT text.

NOTE: most recent work is taking place on `tisch-merge` branch.

The SBLGNT text itself is subject to the [SBLGNT EULA](http://sblgnt.com/license/)
and the morphological parsing and lemmatization is made available under a
[CC-BY-SA License](http://creativecommons.org/licenses/by-sa/3.0/).

Columns
-------

 * book/chapter/verse
 * part of speech
 * parsing code
 * text (including punctuation)
 * word (with punctuation stripped)
 * normalized word
 * lemma

Part of Speech Code
-------------------

A- adjective  
C- conjunction  
D- adverb  
I- interjection  
N- noun  
P- preposition  
RA definite article  
RD demonstrative pronoun  
RI interrogative/indefinite pronoun  
RP personal pronoun  
RR relative pronoun  
V- verb  
X- particle  

Parsing Code
------------

 * person (1=1st, 2=2nd, 3=3rd)
 * tense (P=present, I=imperfect, F=future, A=aorist, X=perfect, Y=pluperfect) 
 * voice (A=active, M=middle, P=passive)
 * mood (I=indicative, D=imperative, S=subjunctive, O=optative, N=infinitive, P=participle)
 * case (N=nominative, G=genitive, D=dative, A=accusative)
 * number (S=singular, P=plural)
 * gender (M=masculine, F=feminine, N=neuter)
 * degree (C=comparative, S=superlative)

NOTE: The part of speech and parsing codes were inherited from the CCAT tagging and will be deprecated in the next major release of MorphGNT.
