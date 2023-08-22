=begin
  
  class Mail
  ----------------
  Gestion de la fabrication du mail en tant que fichier transmissible
  par Net/Http.

=end
require 'securerandom'
class MailBox
class Mail
class << self


# @param [MailManager::Message] message Instance du message du fichier source
# @param [MailManager::Recipient] recipient Destinataire du message
def assemble(recipient, body_html, body_text, metadata)

  # 
  # Encoder et découper le message
  # 
  body_html = [body_html].pack("M").strip
  body_text = [body_text].pack("M").strip

  # 
  # Assemblage du code final
  # 
  cmail = TEMPLATE % {
    message_id:     message_id,
    sender:         metadata.sender,
    boundary:       boundary,
    subject:        metadata.subject,
    universal_identifier: universal_identifier,
    date_mail:      date_mail,
    message:        body_html,
    message_brut:   body_text,
    destinataire:   recipient.as_to
  }

  return cmail

rescue Exception => e
  VPLError.new(e.message, :mail_box)
end

# --- Données propres au mail ---

def boundary
  @boundary ||= begin
    "Mail-Builder=#{SecureRandom.uuid.upcase}"
  end
end

def universal_identifier
  @universal_identifier ||= SecureRandom.uuid.upcase
end

def message_id
  SecureRandom.uuid.upcase + "@icare-editions.fr"
end

def date_mail
  @date_mail ||= Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')
end


TEMPLATE = <<~EML
Content-Type: multipart/alternative;
  boundary="%{boundary}"
Subject: %{subject}
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3696.120.41.1.1\))
X-Apple-Base-Url: x-msg://7/
X-Universally-Unique-Identifier: %{universal_identifier}
X-Apple-Mail-Remote-Attachments: YES
From: %{sender}
X-Apple-Windows-Friendly: 1
Date: %{date_mail}
Message-Id: <%{message_id}>
X-Uniform-Type-Identifier: com.phil.mail-draft
To: %{destinataire}

--%{boundary}
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

%{message_brut}

=20

=20

--%{boundary}
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
  charset=utf-8

%{message}
--%{boundary}--
EML

end #/class << self Mail
end #/class Mail
end #/class MailBox
