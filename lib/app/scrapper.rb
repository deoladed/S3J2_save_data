# frozen_string_literal: true

class Scrapper
  attr_accessor :urlsdepartement, :ville, :email
  @@ensemble = [] # Un petite variable de classe accessible pour tout nos save_as

  def initialize(url)
    @urlsdepartement = url # On est pas oblige mais j'avais pour projet de recuperer toutes les emails de toutes les mairies de france alors c'est pratique de pouvoir changer l'url
    @ville = [] # Je vais me servir de ces array car ce sera bien plus simple pour la sauvegarde
    @email = [] # Idem
  end

  def get_townhall_email(urls)
    compteur = urls.count # creation d'un compteur pour le fun, plus visuel et interactif
    urls.each do |townhall_url| # recuperation nom de ville et emails
      break if compteur == 175 # Je break au bout de 10 mails car 185 c'est long =)
      doc = Nokogiri::HTML(open(townhall_url))
      doc.xpath('//html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').each { |node| @email << node.text }
      puts "Collection des emails en cours.. Numero : #{compteur -= 1}" # Le compteur en question
      doc.xpath('//strong/a[@class = "lientxt4"]').each { |node| @ville << node.text.capitalize }
    end
    @ville.size.times { |i| @@ensemble << { @ville[i] => @email[i] } } # creation du hash
  end

  def get_townhall_urls
    urls = []
    urlcomplete = []
    doc = Nokogiri::HTML(open(@urlsdepartement)) # recuperation des urls des mairies du 92
    doc.xpath('//p/a').each { |node| urls << node['href'][1..-1] }
    urls.each { |url| urlcomplete << "https://www.annuaire-des-mairies.com#{url}" } # restructuration des urls
    urlcomplete
  end

  def save_as_json
    File.open('db/emails.json', 'w') do |f| # On ouvrir le fichier de stockage json autorise en ecriture (w)
      f.write(@@ensemble.to_json) # Et on ecrit le contenu de nos hash
    end
    puts "Emails des mairies enregistrees au format Json"
  end

  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config('config.json') # Creation de la session googledrive
    ws = session.spreadsheet_by_key('1WJYxDWKD7UwFH8MLUTKqheEAzl3mg7U7n1iglWG29u8').worksheets[0] # Lien de la spreadsheet

    @ville.size.times do |i| # Et on envoie le tout sur les deux premieres colonnes
      ws[i + 1, 1] = @ville[i] # C'est presque de la triche de faire ca a partir des arrays, mais pourquoi se compliquer la vie?
      ws[i + 1, 2] = @email[i] # Je ferait avec les hash dans la prochaine fonction, c'est promis
    end
    ws.save # On oublie pas de sauvegarder sur le drive!
    puts "Emails des mairies enregistrees sur votre drive"
  end

  def save_as_csv
    CSV.open('db/emails.csv', 'w') do |csv| # On ouvre le fichier csv
      @@ensemble.each.with_index do |haash, i|
        csv << [i + 1, haash.keys.to_s[2..-3], haash.values.to_s[2..-3]] # Et on stock nos valeurs denudees de leurs guillemets, avec un numero de ligne devant
        # Ou a partir des array: @ville.size.times {|i| csv << [i+1, @ville[i], @email[i]]}
    puts "Emails des mairies enregistrees au format CSV"
      end
    end
  end

  def menu # Un petit menu pour laisser un peu le choix
    puts 'Hey salut! On pompe les emails des mairies de France'
    puts 'Je te les enregistre en quoi ?'
    puts '1 - Json powpowpow'
    puts '2 - Google spreadshIt'
    puts '3 - Csv style'
    puts '4 - Je suis gourmand(e), je veux tout'
    puts '99 - R'
    reponse = gets.chomp.to_i
  end

  def launcher(reponse) # Et la fonction qui lance le choix, on coupe parce que ca faisait plus de 10 lignes #face_d'ange
    case reponse
    when 1
      get_townhall_email(get_townhall_urls) && save_as_json
    when 2
      get_townhall_email(get_townhall_urls) && save_as_spreadsheet
    when 3
      get_townhall_email(get_townhall_urls) && save_as_csv
    when 4
      get_townhall_email(get_townhall_urls) && save_as_json && save_as_spreadsheet
      save_as_csv
    else
      return
    end
  end

  def perform
    launcher(menu)
    puts "Mefait accompli !"
  end
end
