Gem::Specification.new do |s|
  s.name = 'name_gender_classifier'
  s.version     = '0.0.1'
  s.summary     = 'Detecção de gênero pt-br.'
  s.description = 'Utilizando a base de dados do censo IBGE 2010, classificamos primeiros nomes como :male ou :female'
  s.authors     = ['Avantsoft']
  s.email       = 'admin@avantsoft.com.br'
  s.files       = ['lib/name_gender_classifier.rb', 'lib/name_gender_classifier/database_manager.rb',
                   'lib/name_gender_classifier/fallback_gender_detector.rb',
                   'lib/name_gender_classifier/classified_names_pt-br.db']
  s.homepage    =
    'https://rubygems.org/gems/name_gender_classifier'
  s.license = 'MIT'

  s.add_dependency 'gdbm', '~> 2.0.0'
  s.add_dependency 'iconv', '~> 1.0.0'
end
