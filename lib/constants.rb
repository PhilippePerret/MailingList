

#
# Expressions régulières pour les mails
# 
BASE_REG_MAIL = /((?:[a-zA-Z0-9._\-]+)@(?:[^ .,]+)\.[a-zA-Z]{2,10})/
REG_SIMPLE_MAIL = /^#{BASE_REG_MAIL}$/
REG_MAIL_PATRO  = /^(.+?)<#{BASE_REG_MAIL}>$/
