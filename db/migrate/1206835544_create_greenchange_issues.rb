class CreateGreenchangeIssues < ActiveRecord::Migration
  ISSUES = { 
    'Climate crisis' => 'We are for: new carbon taxes to reduce greenhouse gas emissions by 30% in 2020 and 80% in 2050, to prevent global temperatures from rising more than 2 C over pre-industrial levels; massive subsidies for renewable energy, conservation and mass transit.', 
    'Corporate power' => 'We are for: reducing the power and influence of corporations; controlling the insatiable greed of big business;  tough punishments for corporate crime, lawlessness and violence.', 

    'Economic justice' => 'We are for: a $10 per hour minimum wage, guaranteeing workers rights to organize unions, and tough enforcement of occupational safety and health laws;  a 15% cap on credit card interest rates.', 

    'Environment' => 'We rejoice in nature and the diversity of life. We have a duty to care for plants, animals, ecosystems and the planet.', 

    'Human Rights' => 'All people deserve equal treatment and respect. We must ensure that everyone can meet their basic human needs.', 

    'Politics' => 'We believe in democratic participation and accountability. Decisions should be made at the most local level possible.', 

    'Social justice' => 'We are for: a country of people who embrace diversity, are proud of it, and know that it makes us stronger, not weaker, as a nation;  vigorous enforcement of civil rights laws, prosecution of hate crimes, and strengthening of legal services for the poor; ensuring that all citizens have the right to vote, and to have their votes counted;', 

    'War and peace' => 'We believe that violence is wrong, except in self-defense. We want to end the death penalty and torture, and the existence of nuclear weapons.', 
  } 
  def self.up
    add_column :issues, :description, :text
    #ISSUES.each { |issue_name,issue_description| Issue.find_or_create_by_name( :name => issue_name, :description => issue_description ) }
  end

  def self.down
    remove_column :issues, :description
    #ISSUES.each { |issue_name,issue_description| Issue.find_by_name(issue_name).try(:destroy) }
  end
end
