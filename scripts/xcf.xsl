<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" version="1.0" indent="yes" omit-xml-declaration="no" doctype-system="IspXCF.dtd" />
<xsl:strip-space elements="*"/>
<xsl:param name="FPGA_CHIP"/>
<xsl:param name="CHIP_ID"/>
<xsl:param name="BITSTREAM_FILE"/>
<xsl:template match="node()|@*">
  <xsl:copy>
    <xsl:apply-templates select="node()|@*"/>
  </xsl:copy>
</xsl:template>
<xsl:template match="ispXCF/Chain/Device/Name">
  <Name><xsl:value-of select="$FPGA_CHIP"/></Name>
</xsl:template>
<xsl:template match="ispXCF/Chain/Device/PON">
  <PON><xsl:value-of select="$FPGA_CHIP"/></PON>
</xsl:template>
<xsl:template match="ispXCF/Chain/Device/IDCode">
  <IDCode><xsl:value-of select="$CHIP_ID"/></IDCode>
</xsl:template>
<xsl:template match="ispXCF/Chain/Device/File">
  <File><xsl:value-of select="$BITSTREAM_FILE"/></File>
</xsl:template>
</xsl:stylesheet>
