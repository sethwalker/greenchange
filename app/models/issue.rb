class Issue < ActiveRecord::Base
  GRASSROOTS_DEMOCRACY = ['Civil Liberties', 'Corporations', 'Corruption', 'Education', 'Elections', 'Trade']
  JUSTICE = ['Civil Rights', 'Drugs', 'Economy', 'Health', 'Law', 'Poverty', 'Taxes']
  NON_VIOLENCE = ['Africa', 'Americas', 'Asia-Pacific', 'Europe', 'Middle East', 'U.S.']
  SUSTAINABILITY = ['Climate Change', 'Conservation', 'Energy', 'Food', 'Nature', 'Pollution']

  def self.top_level_issues
    [GRASSROOTS_DEMOCRACY, JUSTICE, NON_VIOLENCE, SUSTAINABILITY]
  end
end
