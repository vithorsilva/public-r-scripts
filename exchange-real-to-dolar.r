# **********************************************************************************
# Obter Dados do Banco Central Brasileiro em relacao a Taxa de Cambio do Dolar
# Get Data About Exchange Rate of Brazilian Central Bank
# Developed by Vithor Silva - vithor@vssti.com.br
# Twitter : vithorsilva
# Blog: http://blog.vssti.com.br
# Youtube: 
# **********************************************************************************

#   Copyright (C) 2017 Vithor Silva, VSSTI.com.br
#   All rights reserved. 
#
#   For more scripts and sample code, check out 
#      http://blog.vssti.com.br.com/
#
#   You may alter this code for your own *non-commercial* purposes. You may
#   republish altered code as long as you include this copyright and give due credit. 
#
#
#   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#   PARTICULAR PURPOSE. 
# **********************************************************************************
# References:
# https://dadosabertos.bcb.gov.br/dataset/10813-taxa-de-cambio---livre---dolar-americano-compra

url_venda <- ("http://api.bcb.gov.br/dados/serie/bcdata.sgs.1/dados?formato=csv");
url_compra <- ("http://api.bcb.gov.br/dados/serie/bcdata.sgs.10813/dados?formato=csv");
cambio_venda <- read.csv(url_venda,  header = TRUE, sep = ";");
cambio_compra <- read.csv(url_compra, header = TRUE, sep = ";");

names(cambio_venda)[names(cambio_venda) == "valor"] <- "valor_venda";
names(cambio_compra)[names(cambio_compra) == "valor"] <- "valor_compra";
cambio <- merge(cambio_venda, cambio_compra, by="data");
rm(cambio_venda);
rm(cambio_compra);
