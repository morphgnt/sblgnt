<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="tag:textalign.net,2015:ns" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tan fn" version="3.0">
    <!-- Transformation to convert morphgnt/sblgnt to TAN-LM. This stylesheet is written with 
    the following assumptions: (1) this stylesheet lives in the same directory as the sblgnt plain text 
    files; (2) the sblgnt plain text files have been converted to a very general XML file, where the 
    body is wrapped by a root element (of any name), preceded by the prolog <?xml version="1.0" 
    encoding="UTF-8"?>; (3) there is access to a previous version of the TAN-LM file, and through it, 
    access to the source TAN-T file for the SBL Greek New Testament.-->
    <!-- Why bother?
         - Data in XML format unlocks amazing possibilities for data analysis
         - Data in the TAN XML format allows data to be shared, distributed, and provides a model of data
         that is richer than a simple plain text file that depends upon one entry per word
         - See the first phase of results at https://github.com/Arithmeticus/TAN-bible
         - See some of the possibilities for how the data can be used at http://textalign.net
    -->

    <xsl:variable name="current-tan-lm-file"
        select="doc('../../../library/bible/TAN-LM/nt.grc.sbl-2010.TAN-LM.xml')"/>
    <xsl:variable name="sblgnc-morph-docs" select="collection('./?select=*.txt')"/>
    <xsl:variable name="sblgnc-morph-data" select="string-join($sblgnc-morph-docs/*, '&#xA;')"/>
    <xsl:variable name="data-analyzed" select="analyze-string($sblgnc-morph-data, '\n')"/>
    <xsl:variable name="gnt"
        select="doc(resolve-uri($current-tan-lm-file/tan:TAN-LM/tan:head/tan:source/tan:location[1]/@href, base-uri($current-tan-lm-file/*)))"/>
    <xsl:variable name="gnt-book-abbrvs" select="$gnt//tan:body/tan:div/@n"/>

    <xsl:variable name="data-structured" as="element()*">
        <xsl:for-each-group select="$data-analyzed/fn:non-match"
            group-by="substring(current(), 1, 6)">
            <xsl:variable name="ref-1" select="analyze-string(current-grouping-key(), '\d\d')"/>
            <xsl:variable name="ref-2" as="xs:string">
                <xsl:value-of
                    select="$gnt-book-abbrvs[xs:integer(($ref-1/fn:match)[1])] || ' ' || xs:integer(($ref-1/fn:match)[2]) || ' ' || xs:integer(($ref-1/fn:match)[3])"
                />
            </xsl:variable>
            <xsl:for-each select="current-group()">
                <xsl:variable name="this-line" select="tokenize(., '\s+')"/>
                <xsl:variable name="this-tok-no" select="position()"/>
                <xsl:variable name="this-code" as="element()+">
                    <sbl code="{$this-line[2]}" pos="1"/>
                    <xsl:for-each select="analyze-string($this-line[3], '.')/fn:match">
                        <xsl:if test="matches(., '[^-]')">
                            <sbl code="{.}" pos="{position() + 2}"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="converted-code" as="element()*">
                    <xsl:for-each select="$this-code">
                        <xsl:copy-of
                            select="$morph-code-key[tan:sbl[deep-equal(., current())]]/tan:perseus"
                        />
                    </xsl:for-each>
                </xsl:variable>
                <ana>
                    <tok ref="{$ref-2}" pos="{$this-tok-no}"/>
                    <lm>
                        <l>
                            <xsl:value-of select="$this-line[7]"/>
                        </l>
                        <xsl:for-each
                            select="
                                1 to max(for $i in (1 to 10)
                                return
                                    count($converted-code[@pos = $i]))">
                            <xsl:variable name="this-m" select="."/>
                            <m>
                                <xsl:value-of
                                    select="
                                        for $i in (1 to 10)
                                        return
                                            (($converted-code[@pos = $i]/@code)[$this-m], ($converted-code[@pos = $i]/@code)[last()], '-')[1]"
                                />
                            </m>
                        </xsl:for-each>

                    </lm>
                </ana>
            </xsl:for-each>
        </xsl:for-each-group>
    </xsl:variable>
    <xsl:variable name="data-compacted" as="item()*">
        <xsl:for-each-group select="$data-structured" group-by="for $i in tan:lm, $j in $i/tan:l, $k in $i/tan:m return ($j || '###' || $k)">
            <xsl:variable name="this-l-and-m" select="tokenize(current-grouping-key(),'###')"/>
            <ana>
                <xsl:copy-of select="current-group()/tan:tok"/>
                <lm>
                    <l><xsl:value-of select="$this-l-and-m[1]"/></l>
                    <m><xsl:value-of select="$this-l-and-m[2]"/></m>
                </lm>
            </ana>
        </xsl:for-each-group>
    </xsl:variable>
         
    <xsl:template match="/*">
        <xsl:document>
            <xsl:apply-templates select="$current-tan-lm-file" mode="start"/>
        </xsl:document>
    </xsl:template>
    <xsl:template match="/processing-instruction() | /comment()" mode="start">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="node()" mode="start">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="start"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tan:head" mode="start">
        <xsl:copy>
            <xsl:copy-of select="@* | *"/>
            <change when="{current-dateTime()}" who="kalvesmaki">Refreshed data from
                morphgnt/sblgnt</change>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tan:body" mode="start">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="$data-compacted"/>
            <!--<xsl:copy-of select="$data-structured"/>-->
        </xsl:copy>
    </xsl:template>

    <xsl:variable name="morph-code-key" as="element()+">
        <feature>
            <sbl code="A-" pos="1"/>
            <perseus code="a" pos="1"/>
            <desc>adjective</desc>
        </feature>
        <feature>
            <sbl code="C-" pos="1"/>
            <perseus code="c" pos="1"/>
            <desc>conjunction</desc>
        </feature>
        <feature>
            <sbl code="D-" pos="1"/>
            <perseus code="d" pos="1"/>
            <desc>adverb</desc>
        </feature>
        <feature>
            <sbl code="I-" pos="1"/>
            <perseus code="i" pos="1"/>
            <desc>interjection</desc>
        </feature>
        <feature>
            <sbl code="N-" pos="1"/>
            <perseus code="n" pos="1"/>
            <desc>noun</desc>
        </feature>
        <feature>
            <sbl code="P-" pos="1"/>
            <perseus code="r" pos="1"/>
            <desc>preposition</desc>
        </feature>
        <feature>
            <sbl code="RA" pos="1"/>
            <perseus code="p" pos="1"/>
            <perseus code="a" pos="2"/>
            <desc>definite article</desc>
        </feature>
        <feature>
            <sbl code="RD" pos="1"/>
            <perseus code="p" pos="1"/>
            <perseus code="d" pos="2"/>
            <desc>demonstrative pronoun</desc>
        </feature>
        <feature>
            <sbl code="RI" pos="1"/>
            <perseus code="p" pos="1"/>
            <perseus code="i" pos="2"/>
            <perseus code="x" pos="2"/>
            <desc>interrogative/indefinite pronoun</desc>
        </feature>
        <feature>
            <sbl code="RP" pos="1"/>
            <perseus code="p" pos="1"/>
            <perseus code="p" pos="2"/>
            <desc>personal pronoun</desc>
        </feature>
        <feature>
            <sbl code="RR" pos="1"/>
            <perseus code="p" pos="1"/>
            <perseus code="r" pos="2"/>
            <desc>relative pronoun</desc>
        </feature>
        <feature>
            <sbl code="V-" pos="1"/>
            <perseus code="v" pos="1"/>
            <desc>verb</desc>
        </feature>
        <feature>
            <sbl code="X-" pos="1"/>
            <perseus code="g" pos="1"/>
            <desc>particle</desc>
        </feature>
        <feature>
            <sbl code="1" pos="3"/>
            <perseus code="1" pos="3"/>
            <desc>1st</desc>
        </feature>
        <feature>
            <sbl code="2" pos="3"/>
            <perseus code="2" pos="3"/>
            <desc>2nd</desc>
        </feature>
        <feature>
            <sbl code="3" pos="3"/>
            <perseus code="3" pos="3"/>
            <desc>3rd</desc>
        </feature>
        <feature>
            <sbl code="P" pos="4"/>
            <perseus code="p" pos="5"/>
            <desc>present</desc>
        </feature>
        <feature>
            <sbl code="I" pos="4"/>
            <perseus code="i" pos="5"/>
            <desc>imperfect</desc>
        </feature>
        <feature>
            <sbl code="F" pos="4"/>
            <perseus code="f" pos="5"/>
            <desc>future</desc>
        </feature>
        <feature>
            <sbl code="A" pos="4"/>
            <perseus code="a" pos="5"/>
            <desc>aorist</desc>
        </feature>
        <feature>
            <sbl code="X" pos="4"/>
            <perseus code="r" pos="5"/>
            <desc>perfect</desc>
        </feature>
        <feature>
            <sbl code="Y" pos="4"/>
            <perseus code="l" pos="5"/>
            <desc>pluperfect</desc>
        </feature>
        <feature>
            <sbl code="A" pos="5"/>
            <perseus code="a" pos="7"/>
            <desc>active</desc>
        </feature>
        <feature>
            <sbl code="M" pos="5"/>
            <perseus code="m" pos="7"/>
            <desc>middle</desc>
        </feature>
        <feature>
            <sbl code="P" pos="5"/>
            <perseus code="p" pos="7"/>
            <desc>passive</desc>
        </feature>
        <feature>
            <sbl code="I" pos="6"/>
            <perseus code="i" pos="6"/>
            <desc>indicative</desc>
        </feature>
        <feature>
            <sbl code="D" pos="6"/>
            <perseus code="m" pos="6"/>
            <desc>imperative</desc>
        </feature>
        <feature>
            <sbl code="S" pos="6"/>
            <perseus code="s" pos="6"/>
            <desc>subjunctive</desc>
        </feature>
        <feature>
            <sbl code="O" pos="6"/>
            <perseus code="o" pos="6"/>
            <desc>optative</desc>
        </feature>
        <feature>
            <sbl code="N" pos="6"/>
            <perseus code="n" pos="6"/>
            <desc>infinitive</desc>
        </feature>
        <feature>
            <sbl code="P" pos="6"/>
            <perseus code="p" pos="6"/>
            <desc>participle</desc>
        </feature>
        <feature>
            <sbl code="N" pos="7"/>
            <perseus code="n" pos="9"/>
            <desc>nominative</desc>
        </feature>
        <feature>
            <sbl code="G" pos="7"/>
            <perseus code="g" pos="9"/>
            <desc>genitive</desc>
        </feature>
        <feature>
            <sbl code="D" pos="7"/>
            <perseus code="d" pos="9"/>
            <desc>dative</desc>
        </feature>
        <feature>
            <sbl code="A" pos="7"/>
            <perseus code="a" pos="9"/>
            <desc>accusative</desc>
        </feature>
        <feature>
            <sbl code="S" pos="8"/>
            <perseus code="s" pos="4"/>
            <desc>singular</desc>
        </feature>
        <feature>
            <sbl code="P" pos="8"/>
            <perseus code="p" pos="4"/>
            <desc>plural</desc>
        </feature>
        <feature>
            <sbl code="M" pos="9"/>
            <perseus code="m" pos="8"/>
            <desc>masculine</desc>
        </feature>
        <feature>
            <sbl code="F" pos="9"/>
            <perseus code="f" pos="8"/>
            <desc>feminine</desc>
        </feature>
        <feature>
            <sbl code="N" pos="9"/>
            <perseus code="n" pos="8"/>
            <desc>neuter</desc>
        </feature>
        <feature>
            <sbl code="C" pos="10"/>
            <perseus code="c" pos="10"/>
            <desc>comparative</desc>
        </feature>
        <feature>
            <sbl code="S" pos="10"/>
            <perseus code="s" pos="10"/>
            <desc>superlative</desc>
        </feature>
    </xsl:variable>

</xsl:stylesheet>
