<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" indent="yes" />
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
        <xsl:variable name="rest" select="$nodes[position() > 1]" />
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
        <xsl:variable name="rest" select="$nodes[position() > 1]" />
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
    <table>
      <xsl:for-each select="ingresos/ingreso">
        <xsl:variable name="empresaActual" select="empresa" />
        <xsl:if test="not(preceding-sibling::ingreso[empresa = $empresaActual])">
          <tr>
            <td><xsl:value-of select="$empresaActual" /></td>
            <td>
              <xsl:value-of select="count(../ingreso[empresa = $empresaActual])" />
            </td>
          </tr>
        </xsl:if>
      </xsl:for-each>
    </table>
  </xsl:template>


  <xsl:template match="/">
    <html>
      <head>
        <title>Resumen de Ingresos</title>
        <link rel="stylesheet" href="estilos.css" />
      </head>
      <body>
        <!-- Titulo  -->
        <div class="titulo">
          <h1>Resumen de Ingresos</h1>
          <img src="logo_mini.png" alt="Logo TicketsNow" />
        </div>

        <!-- Tarjetas  -->
        <div class="tarjetas">
          <!-- Total agosto -->
          <div class="tarjeta">
            <h3>Ingresos Totales - Agosto</h3>
            <p>
              <xsl:variable name="totalAgosto"
                select="sum(ingresos/ingreso/monto)" />
              <xsl:value-of
                select="format-number($totalAgosto, '#,##0.00')" /> € 
            </p>
          </div>

          <!-- Totales por tipo -->
          <div class="tarjeta">
            <h3>Totales por Tipo</h3>
            <ul>
              <xsl:for-each select="ingresos/ingreso">
                <xsl:variable name="tipoActual" select="@tipo" />
                <xsl:if test="not(preceding-sibling::ingreso[@tipo = $tipoActual])">
                  <li>
                    <strong><xsl:value-of select="$tipoActual" />: </strong>
                    <xsl:value-of
                      select="format-number(sum(//ingreso[@tipo = $tipoActual]/monto), '#,##0.00')" /> €
                  </li>
                </xsl:if>
              </xsl:for-each>
            </ul>
          </div>

          <!-- Top 5 empresas -->
          <div class="tarjeta">
            <h3>Top 5 Empresas</h3>
            <ol>
              <xsl:for-each select="ingresos/ingreso[not(empresa = preceding::ingreso/empresa)]">
                <xsl:sort select="sum(//ingreso[empresa = current()/empresa]/monto)" data-type="number" order="descending" />
                <xsl:if test="position() &lt;= 5">
                  <li>
                    <strong><xsl:value-of select="empresa" />: </strong>
                    <xsl:value-of select="format-number(sum(//ingreso[empresa = current()/empresa]/monto), '#,##0.00')" /> €
                  </li>
                </xsl:if>
              </xsl:for-each>
            </ol>
          </div>

        </div>

        <!-- Listados individuales por tipo -->
        <h1>Tipos de ingresos</h1>
        <xsl:for-each select="ingresos/ingreso">
          <xsl:variable name="tipo" select="@tipo" />
          <xsl:if test="not(preceding-sibling::ingreso[@tipo = $tipo])">
            <h2><xsl:value-of select="$tipo" /></h2>
            <table>
              <tr>
                <th>Fecha</th>
                <th>Monto (€)</th>
                <th>Descripción</th>
                <th>Empresa</th>
                <th>Concepto</th>
              </tr>
              <xsl:for-each select="../ingreso[@tipo = $tipo]">
                <xsl:sort select="fecha" order="ascending" />
                <tr>
                  <td><xsl:value-of select="fecha" /></td>
                  <td><xsl:value-of select="monto" /></td>
                  <td><xsl:value-of select="descripcion" /></td>
                  <td><xsl:value-of select="empresa" /></td>
                  <td><xsl:value-of select="concepto" /></td>
                </tr>
              </xsl:for-each>
              <xsl:variable name="subtotal" select="sum(../ingreso[@tipo = $tipo]/monto)" />
              <xsl:variable name="countTipo" select="count(../ingreso[@tipo = $tipo])" />
              <tr>
                <th>Subtotal</th>
                <th>
                  <xsl:value-of select="format-number($subtotal, '#,##0.00')" /> €
                </th>
                <th colspan="3"></th>
              </tr>
              <tr>
                <th>Promedio</th>
                <th>
                  <xsl:value-of select="format-number($subtotal div $countTipo, '#,##0.00')" /> €
                </th>
                <th colspan="3"></th>
              </tr>
            </table>
          </xsl:if>
        </xsl:for-each>

        <!-- Máximo y mínimo general -->
        <h1>Máximo y mínimo general</h1>
        <p>
          <strong>Máximo ingreso: </strong>
          <xsl:call-template name="maximo">
            <xsl:with-param name="nodes" select="ingresos/ingreso/monto" />
          </xsl:call-template>
          €
        </p>
        <p>
          <strong>Mínimo ingreso: </strong>
          <xsl:call-template name="minimo">
            <xsl:with-param name="nodes" select="ingresos/ingreso/monto" />
          </xsl:call-template>
          € 
        </p>

        <!-- Conteo de ingresos por empresa -->
        <h1>Conteo de ingresos por empresa</h1>
        <table>
          <tr>
            <th>Empresa</th>
            <th>Cantidad de ingresos</th>
          </tr>
          <xsl:for-each select="ingresos/ingreso">
            <xsl:variable name="empresaActual" select="empresa" />
            <xsl:if test="not(preceding-sibling::ingreso[empresa = $empresaActual])">
              <tr>
                <td><xsl:value-of select="$empresaActual" /></td>
                <td><xsl:value-of select="count(../ingreso[empresa = $empresaActual])" /></td>
              </tr>
            </xsl:if>
          </xsl:for-each>
        </table>

        <!-- Ingreso más alto-->
        <h1>Ingreso individual más alto</h1>
        <xsl:for-each select="ingresos/ingreso">
          <xsl:sort select="monto" data-type="number" order="descending"/>
          <xsl:if test="position() = 1">
            <p>
              <strong>Empresa: </strong> <xsl:value-of select="empresa" /><br/>
              <strong>Monto: </strong> <xsl:value-of select="monto" /> €<br/>
              <strong>Fecha: </strong> <xsl:value-of select="fecha" />
            </p>
          </xsl:if>
        </xsl:for-each>

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>