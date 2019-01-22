# frozen_string_literal: true

class Scrapper
  attr_accessor  :ville, :email
  @@ensemble = [] # Un petite variable de classe accessible pour tout nos save_as

  def initialize
    @ville = [] # Je vais me servir de ces array car ce sera bien plus simple pour la sauvegarde
    @email = [] 
  end

  def get_townhall_email(urls)
    compteur = urls.count # creation d'un compteur pour le visuel et suivre l'avancee
    urls.each do |townhall_url| # recuperation nom de ville et emails
      break if compteur == 165 # Je break au bout de 20 mails car 185 c'est long =)
      doc = Nokogiri::HTML(open(townhall_url))
      doc.xpath('//html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').each { |node| @email << node.text }
      puts "Collection des emails en cours.. Numero : #{compteur -= 1}" # Le compteur en question
      doc.xpath('//strong/a[@class = "lientxt4"]').each { |node| @ville << node.text.capitalize }
    end
    @ville.size.times { |i| @@ensemble << { @ville[i] => @email[i] } } # creation du hash
  end

  def get_townhall_urls
    urls = []
    doc = Nokogiri::HTML(open('http://annuaire-des-mairies.com/val-d-oise.html')) 
    doc.xpath('//p/a').each { |node| urls << node['href'][1..-1] } # recuperation des urls des mairies du 92, suppression des caracteres superflus
    urls.map! { |url| "https://www.annuaire-des-mairies.com" + url } # restructuration des urls
  end

  def save_as_json
    File.open('db/emails.json', 'w') do |f| # On ouvre le fichier de stockage json, autorisE en ecriture (w)
      f.write(@@ensemble.to_json) # Et on y ecrit le contenu de nos hash
    end
    puts "\nEmails des mairies enregistrees au format Json dans 'db/emails.json'"
  end

  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config('config.json') # Creation de la session googledrive
    ws = session.spreadsheet_by_key('1WJYxDWKD7UwFH8MLUTKqheEAzl3mg7U7n1iglWG29u8').worksheets[0] # Lien de la spreadsheet

    @ville.size.times do |i| # Et on envoie le tout sur les deux premieres colonnes
      ws[i + 1, 1] = @ville[i] # C'est presque de la triche de faire ca a partir des arrays, mais pourquoi se compliquer la vie?
      ws[i + 1, 2] = @email[i] # Je ferait avec les hash dans la prochaine fonction, c'est promis
    end
    ws.save # On oublie pas de sauvegarder sur le drive!
    puts "\nEmails des mairies enregistrees sur votre drive"
  end

  def save_as_csv
    CSV.open('db/emails.csv', 'w') do |csv| # On ouvre le fichier csv
      @@ensemble.each.with_index { |haash, i| csv << [i + 1, haash.keys.to_s[2..-3], haash.values.to_s[2..-3]] } # Et on stock nos valeurs sans leurs guillemets, avec un numero de ligne devant
    end
    puts "\nEmails des mairies enregistrees au format CSV dans 'db/emails.csv'"
  end
end
