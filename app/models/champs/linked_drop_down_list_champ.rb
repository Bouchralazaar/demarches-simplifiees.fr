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
class Champs::LinkedDropDownListChamp < Champ
  delegate :primary_options, :secondary_options, to: 'type_de_champ.dynamic_type'

  def options?
    drop_down_list_options?
  end

  def primary_value
    if value.present?
      JSON.parse(value)[0]
    else
      ''
    end
  end

  def secondary_value
    if value.present?
      JSON.parse(value)[1]
    else
      ''
    end
  end

  def primary_value=(value)
    if value.blank?
      pack_value("", "")
    else
      pack_value(value, secondary_value)
    end
  end

  def secondary_value=(value)
    pack_value(primary_value, value)
  end

  def main_value_name
    :primary_value
  end

  def to_s
    value.present? ? [primary_value, secondary_value].filter(&:present?).join(' / ') : ""
  end

  def for_tag
    value.present? ? [primary_value, secondary_value].filter(&:present?).join(' / ') : ""
  end

  def for_export
    value.present? ? "#{primary_value || ''};#{secondary_value || ''}" : nil
  end

  def for_api
    value.present? ? { primary: primary_value, secondary: secondary_value } : nil
  end

  def blank?
    primary_value.blank? ||
      (has_secondary_options_for_primary? && secondary_value.blank?)
  end

  def search_terms
    [primary_value, secondary_value]
  end

  def has_secondary_options_for_primary?
    primary_value.present? && secondary_options[primary_value]&.any?(&:present?)
  end

  private

  def pack_value(primary, secondary)
    self.value = JSON.generate([primary, secondary])
  end
end
