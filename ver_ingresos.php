<?php
$xml = new DOMDocument();
$xml->load('ingresos.xml');

$xsl = new DOMDocument();
$xsl->load('transformacion_ingresos.xsl');

$proc = new XSLTProcessor();
$proc->importStylesheet($xsl);

echo $proc->transformToXml($xml);
?>