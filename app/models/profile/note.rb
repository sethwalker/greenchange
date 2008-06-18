=begin

=end
class Profile::Note < ActiveRecord::Base
  validates_presence_of :note_type

  set_table_name 'profile_notes'

  belongs_to :profile
  NOTE_TYPES = Crabgrass::Config.profile_note_types.map(&:first)
  validates_inclusion_of :note_type, :in => NOTE_TYPES

  #after_save {|record| record.profile.save if record.profile}
  #after_destroy {|record| record.profile.save if record.profile}

  def note_type
    read_attribute( :note_type ).to_sym
  end
  def note_type=(value)
    write_attribute :note_type, value.to_s
  end

end
