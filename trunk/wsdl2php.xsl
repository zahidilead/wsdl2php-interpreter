<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
<wsdl2php>
    <classes>
        <xsl:apply-templates select="//*[name()='wsdl:types']" />
    </classes>
    <services>
        <xsl:apply-templates select="//*[name()='wsdl:service']" />
    </services>
</wsdl2php>
</xsl:template>

<xsl:template match="*[name()='wsdl:types']">
    <xsl:apply-templates select=".//*[name()='complexType' and not(starts-with(@name, 'ArrayOf_'))]" />
</xsl:template>

<xsl:template match="*[name()='complexType']">
    <class name="{@name | ../@name}">
        <xsl:if test=".//*[name()='extension']">
            <extends>
                <xsl:value-of select="substring-after(.//*[name()='extension']/@base,':')" />
            </extends>
        </xsl:if>
        <xsl:if test=".//*[name()='element']">
            <properties>
                <xsl:for-each select=".//*[name()='element']">
                    <xsl:choose>
                        <xsl:when test="substring-before(@type,':')='xsd'">
                            <property name="{@name}" type="{substring-after(@type,':')}" />
                        </xsl:when>
                        <xsl:when test="//*[name()='complexType' and @name=substring-after(current()/@type,':')]//*[@ref='soapenc:arrayType']">
                            <xsl:variable name="type"
                                select="//*[name()='complexType' and @name=substring-after(current()/@type,':')]//*[@ref='soapenc:arrayType']/@*[name()='wsdl:arrayType']" />
                            <property name="{@name}" type="{substring-after($type,':')}" />
                        </xsl:when>
                        <xsl:when test="not(@type) and @ref">
                            <xsl:choose>
                                <xsl:when test="@name">
                                    <property name="{@name}" type="{substring-after(@ref,':')}" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <property name="{substring-after(@ref,':')}" type="{substring-after(@ref,':')}" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <property name="{@name}" type="{@type}" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </properties>
        </xsl:if>
    </class>
</xsl:template>

<xsl:template match="*[name()='wsdl:service']">
    <service name="{@name}">
        <xsl:apply-templates select="*[name()='wsdl:port']" />
    </service>
</xsl:template>

<xsl:template match="*[name()='wsdl:port']">
    <xsl:apply-templates select="//*[name()='wsdl:binding' and @name=substring-after(current()/@binding,':')]" />
</xsl:template>

<xsl:template match="*[name()='wsdl:binding']">
    <functions>
        <xsl:apply-templates select=".//*[name()='wsdl:operation']" />
    </functions>
</xsl:template>

<xsl:template match="*[name()='wsdl:operation']">
    <function name="{@name}">
        <parameters>
            <xsl:apply-templates select="//*[name()='wsdl:message' and @name=current()/*[name()='wsdl:input']/@name]" />
        </parameters>
        <returns>
            <xsl:apply-templates select="//*[name()='wsdl:message' and @name=current()/*[name()='wsdl:output']/@name]" />
        </returns>
    </function>
</xsl:template>

<xsl:template match="*[name()='wsdl:message']">
    <xsl:for-each select="*[name()='wsdl:part']">
        <xsl:choose>
            <xsl:when test="substring-before(@type,':')='xsd'">
                <variable name="{@name}" type="{substring-after(@type,':')}" />
            </xsl:when>
            <xsl:when test="//*[name()='complexType' and @name=substring-after(current()/@type,':')]//*[@ref='soapenc:arrayType']">
                <xsl:variable name="type"
                    select="//*[name()='complexType' and @name=substring-after(current()/@type,':')]//*[@ref='soapenc:arrayType']/@*[name()='wsdl:arrayType']" />
                <variable name="{@name}" type="{substring-after($type,':')}" />
            </xsl:when>
            <xsl:when test="not(@type) and @element">
                <xsl:choose>
                    <xsl:when test="@name">
                        <variable name="{@name}" type="{substring-after(@element,':')}" />
                    </xsl:when>
                    <xsl:otherwise>
                        <variable name="{substring-after(@element,':')}" type="{substring-after(@element,':')}" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <variable name="{@name}" type="{@type}" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
