# == Schema Information
#
# Table name: champs
#
#  id                             :integer          not null, primary key
#  data                           :jsonb
#  fetch_external_data_exceptions :string           is an Array
#  private                        :boolean          default(FALSE), not null
#  rebased_at                     :datetime
#  row                            :integer
#  type                           :string
#  value                          :string
#  value_json                     :jsonb
#  created_at                     :datetime
#  updated_at                     :datetime
#  dossier_id                     :integer
#  etablissement_id               :integer
#  external_id                    :string
#  parent_id                      :bigint
#  type_de_champ_id               :integer
#
class Champs::TitreIdentiteChamp < Champ
  FILE_MAX_SIZE = 20.megabytes
  ACCEPTED_FORMATS = ['image/png', 'image/jpeg']
  validates :piece_justificative_file, content_type: ACCEPTED_FORMATS, size: { less_than: FILE_MAX_SIZE }

  def main_value_name
    :piece_justificative_file
  end

  def search_terms
    # We don’t know how to search inside documents yet
  end

  def mandatory_blank?
    mandatory? && !piece_justificative_file.attached?
  end

  def for_export
    nil
  end

  def for_api
    nil
  end
end
