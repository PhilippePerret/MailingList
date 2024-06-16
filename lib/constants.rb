

#
# Expressions régulières pour les mails
# 
BASE_REG_MAIL = /((?:[a-zA-Z0-9._\-]+)@(?:[^ ,]+)\.[a-zA-Z]{2,10})/
REG_SIMPLE_MAIL = /^#{BASE_REG_MAIL}$/
REG_MAIL_PATRO  = /^(.+?)<#{BASE_REG_MAIL}>$/

#
# Pour l'envoi proprement dit du mail
# 
require '/Users/philippeperret/.secret/mail'
DSMTP = MAILS_DATA[:smtp]
SERVER_DATA = [DSMTP[:server],DSMTP[:port],DSMTP[:domain],DSMTP[:user_name],DSMTP[:password],:login]


#
# Pour les images
# 
VALID_IMG_EXTNAMES = ['.svg','.jpg','.jpeg','.gif','.png','.tiff']
CODE_IMAGE_TEMPLATE = '<img style="width:inherit;height:inherit;%{style}" src="data:image/%{format};base64,%{code64}" alt="%{alt}" />'.freeze
CODE_IMAGE_TEMPLATE_LINKED = ('<a href="%{link}">'+CODE_IMAGE_TEMPLATE+'</a>').freeze
