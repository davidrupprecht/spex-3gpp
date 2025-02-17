class Document < ActiveRecord::Base
  attr_reader :desc

  belongs_to :spec_serie

  has_many :document_versions

  after_initialize :init_desc

  def self.parse_no(spec_no)
    m = spec_no.match(/(\d+)[\._](\d+)(?:-(\d))?(U)?/)
    raise "Unable to parse '#{spec_no}'" if not m

    res = {
        :serie => m[1].to_i,
        :number => m[2].to_i
    }

    res[:part] = m[3].to_i if not m[3].nil?
    res[:u] = true if not m[4].nil?

    res
  end

  def self.desc_to_name(desc)
    name  = if desc[:serie].to_i < 13 or desc[:u]
              "%02d.%02d" % [desc[:serie],desc[:number]]
            else
              "%02d.%03d" % [desc[:serie],desc[:number]]
            end
            
    name += "-#{desc[:part]}" if not desc[:part].nil?
    name += "U" if desc[:u]
    return name
  end

  def self.find_by_desc(desc)
    name = self.desc_to_name(desc)
    self.find_by_name(name)
  end

  def init_desc
    @desc = Document.parse_no(name)
  end

  def name_3gpp
    n  = "%02d" % spec_serie.index
    n += full_spec_number
    n += "-#{spec_part}" if !spec_part.nil?
    n += "U" if desc[:u]
    n
  end

  def full_spec_number
    ( ( spec_serie.index < 13 or desc[:u] ) ? "%02d" : "%03d" ) % spec_number
  end

  def info_page_url
    "http://www.3gpp.org/ftp/Specs/html-info/#{name_3gpp}.htm"
  end

  def parse_no
    spec_serie = SpecSerie.find_by_index(desc[:serie])
    raise "Unable to find serie for #{name}" if spec_serie.nil?

    spec_serie_id = spec_serie.id

    spec_part = desc[:part] if not desc[:part].nil?
    spec_number = desc[:number]

    desc
  end
end
