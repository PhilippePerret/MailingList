class MailingReport

  attr_reader :lines

  def initialize(filebox)
    @filebox = filebox
    @lines   = []
    @ok      = false
  end

  # Pour ajouter une ligne de rapport
  def add(line)
    @lines << line.strip
  end
  alias :<< :add

  # Affiche le rapport final
  def display_report
    add "-"*40
    add ERRORS[:report][@ok ? :mailing_succeeded : :mailing_failed]
    unless @ok

    end
    add "Début : #{t(@start_time)} — Fin : #{t(@end_time)} — Durée : #{duree} s"
    puts lines.join("\n").send(@ok ? :vert : :rouge)
  end

  # Si tout s'est bien passé, on appelle cette méthode
  def set_ok
    @ok = true
  end

  def start
    @start_time = Time.now.freeze
  end
  def stop
    @end_time = Time.now.freeze
  end
  def duree
    (@end_time - @start_time)
  end

  private

    def t(time)
      time.strftime('%H:%M:%S')
    end

    def now_formated
      Time.now
    end
end
