class AddLanguagesToDb < ActiveRecord::Migration
  def self.up
    create_table :language_strings, :id => false do |t|
      t.string :name
      t.string :code, :limit => 5
    end
    add_index :language_strings, :code, :name => "index_on_code", :unique => true
    LANGUAGES.each do |language|
      ls = LanguageString.new :name => language[1]
      ls.code = language[0]
      ls.save
    end
  end

  def self.down
    drop_table :language_strings
  end

  LANGUAGES = [
    ['ar', 'Arabic'],
    ['bn', 'Bengali; Bangla'],
    ['en', 'English'],
    ['fr', 'French'],
    ['de', 'German'],
    ['el', 'Greek'],
    ['he', 'Hebrew'],
    ['hi', 'Hindi'],
    ['ja', 'Japanese'],
    ['jw', 'Javanese'],
    ['ko', 'Korean'],
    ['zh', 'Mandarin'],
    ['mr', 'Marathi'],
    ['fa', 'Persian'],
    ['pt', 'Portuguese'],
    ['ru', 'Russian'],
    ['es', 'Spanish'],
    ['sw', 'Swahili'],
    ['ta', 'Tamil'],
    ['te', 'Telugu'],
    ['bo', 'Tibetan'],
    ['vi', 'Vietnamese'],
  ]
    
end
