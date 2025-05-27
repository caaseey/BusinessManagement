<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" indent="yes" />
<!-- tres tarjetas: mes + total, por categorias de manera ordenada, empresas de manera ordenada (top 3)-->
  <!-- Agrupar ingresos por tipo -->
  <xsl:key name="por-tipo" match="ingreso" use="@tipo" />
  <xsl:key name="por-empresa" match="ingreso" use="empresa/text()" />

  <!-- Función para máximo valor -->
  <xsl:template name="maximo">
    <xsl:param name="nodes" />
    <xsl:param name="max" select="number($nodes[1])" />
    <xsl:choose>
      <xsl:when test="not($nodes)">
        <xsl:value-of select="$max" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="first" select="$nodes[1]" />
        <xsl:variable name="rest"
          select="$nodes[position() > 1]" />
        <xsl:choose>
          <xsl:when test="number($first) &gt; number($max)">
            <xsl:call-template name="maximo">
              <xsl:with-param name="nodes" select="$rest" />
              <xsl:with-param name="max" select="number($first)" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="maximo">
              <xsl:with-param name="nodes" select="$rest" />
              <xsl:with-param name="max" select="$max" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Función para mínimo valor -->
  <xsl:template name="minimo">
    <xsl:param name="nodes" />
    <xsl:param name="min" select="number($nodes[1])" />
    <xsl:choose>
      <xsl:when test="not($nodes)">
        <xsl:value-of select="$min" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="first" select="$nodes[1]" />
        <xsl:variable name="rest"
          select="$nodes[position() > 1]" />
        <xsl:choose>
          <xsl:when test="number($first) &lt; number($min)">
            <xsl:call-template name="minimo">
              <xsl:with-param name="nodes" select="$rest" />
              <xsl:with-param name="min" select="number($first)" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="minimo">
              <xsl:with-param name="nodes" select="$rest" />
              <xsl:with-param name="min" select="$min" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Contar ingresos por empresa -->
  <xsl:template name="contarPorEmpresa">
    <xsl:param name="empresa" />
    <xsl:value-of select="count(ingresos/ingreso[empresa = $empresa])" />
    <xsl:for-each
      select="ingresos/ingreso[generate-id() = generate-id(key('por-empresa', empresa)[1])]">
      <tr>
        <td>
          <xsl:value-of select="empresa" />
        </td>
        <td>
          <xsl:value-of select="count(key('por-empresa', empresa))" />
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/">
    <html>
      <head>
        <title>Resumen de Ingresos</title>
        <link rel="stylesheet" href="estilos.css" />
      </head>
      <body>
        <h1>Resumen de Ingresos</h1>

        <!-- Tabla resumen por tipo -->
        <h2>Totales por tipo</h2>
        <table>
          <tr>
            <th>Tipo</th>
            <th>Total (€)</th>
          </tr>
          <xsl:for-each
            select="ingresos/ingreso[generate-id() = generate-id(key('por-tipo', @tipo)[1])]">
            <tr>
              <td>
                <xsl:value-of select="@tipo" />
              </td>
              <td>
                <xsl:value-of select="format-number(sum(key('por-tipo', @tipo)/monto), '#,##0.00')" />
    € </td>
            </tr>
          </xsl:for-each>
          <tr>
            <th>Total general</th>
            <th>
              <xsl:value-of select="format-number(sum(ingresos/ingreso/monto), '#,##0.00')" /> € </th>
          </tr>
        </table>

        <!-- Máximo y mínimo general -->
        <h2>Máximo y mínimo general</h2>
        <p>
          <strong>Máximo ingreso:</strong>
          <xsl:call-template name="maximo">
            <xsl:with-param name="nodes" select="ingresos/ingreso/monto" />
          </xsl:call-template>
    € </p>
        <p>
          <strong>Mínimo ingreso:</strong>
          <xsl:call-template name="minimo">
            <xsl:with-param name="nodes" select="ingresos/ingreso/monto" />
          </xsl:call-template>
    € </p>

        <!-- Conteo de ingresos por empresa -->
        <h2>Conteo de ingresos por empresa</h2>
        <table>
          <tr>
            <th>Empresa</th>
            <th>Cantidad de ingresos</th>
          </tr>
          <xsl:for-each
            select="ingresos/ingreso[generate-id() = generate-id(key('por-empresa', empresa)[1])]">
            <tr>
              <td>
                <xsl:value-of select="empresa" />
              </td>
              <td>
                <xsl:value-of select="count(key('por-empresa', empresa))" />
              </td>
            </tr>
          </xsl:for-each>
        </table>

        <!-- Listados individuales por tipo -->
        <xsl:for-each
          select="ingresos/ingreso[generate-id() = generate-id(key('por-tipo', @tipo)[1])]">
          <xsl:variable name="tipo" select="@tipo" />
          <h2>
            <xsl:value-of select="$tipo" />
          </h2>
          <table>
            <tr>
              <th>Fecha</th>
              <th>Monto (€)</th>
              <th>Descripción</th>
              <th>Empresa</th>
              <th>Concepto</th>
            </tr>
            <xsl:for-each select="key('por-tipo', $tipo)">
              <xsl:sort select="fecha" order="ascending" />
              <tr>
                <td>
                  <xsl:value-of select="fecha" />
                </td>
                <td>
                  <xsl:value-of select="monto" />
                </td>
                <td>
                  <xsl:value-of select="descripcion" />
                </td>
                <td>
                  <xsl:value-of select="empresa" />
                </td>
                <td>
                  <xsl:value-of select="concepto" />
                </td>
              </tr>
            </xsl:for-each>
            <tr>
              <th>Subtotal</th>
              <th>
                <xsl:value-of select="format-number(sum(key('por-tipo', $tipo)/monto), '#,##0.00')" />
    € </th>
              <th colspan="3"></th>
            </tr>
          </table>
        </xsl:for-each>

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>