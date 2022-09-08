Gem::Specification.new do |s|
  s.name = 'name_gender_classifier'
  s.version     = '0.0.2'
  s.summary     = 'Gender detection for brazilian first names.'
  s.description = 'The name_gender_classifier gem classifies Brazilian first names as either '\
                  '\'male\' or \'female\' based on the 2010 IBGE census.'
  s.authors     = ['Avantsoft']
  s.email       = 'hello@avantsoft.com.br'
  s.files       = ['lib/name_gender_classifier.rb', 'lib/name_gender_classifier/database_manager.rb',
                   'lib/name_gender_classifier/fallback_gender_detector.rb',
                   'lib/name_gender_classifier/classified_names_pt-br.db']
  s.homepage    =
    'https://rubygems.org/gems/name_gender_classifier'
  s.license = 'MIT'

  s.add_dependency 'gdbm', '~> 2.0.0'
  s.add_dependency 'iconv', '~> 1.0.0'
end
