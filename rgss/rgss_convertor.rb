require "zlib"

class RGSS_Convertor
  class ConvertException < StandardError; end
  
  def initialize(bin_dir="./Data", text_dir=".", ext="rvdata2")
    @bin_dir = bin_dir
    @text_dir = text_dir
    @ext = ext
  end
  
  def to_text
    unless File.exist?("#{@bin_dir}/Scripts.#{@ext}")
      raise ConvertException.new("#{@bin_dir}/Scripts.#{@ext}が存在しません")
    end
    if Dir.exist?("#{@text_dir}/scripts")
      unless system %{rd #{@text_dir.gsub("/", "\\")}\\scripts /s /q}
        raise ConvertException.new("#{@text_dir}/scriptsの削除に失敗しました")
      end
    end
    Dir.mkdir("#{@text_dir}/scripts")
    Dir.mkdir("#{@text_dir}/scripts/src")
    scripts_list = ""
    begin
      scripts = Marshal.load(File.binread("#{@bin_dir}/Scripts.#{@ext}"))
    rescue
      raise ConvertException.new("#{@bin_dir}/Scripts.#{@ext}の読み込みに失敗しました")
    end
    scripts.each_index do |idx|
      name = scripts[idx][1]
      if file_name_judge(name)
        src = Zlib::Inflate.inflate(scripts[idx][2])
        File.binwrite("#{@text_dir}/scripts/src/#{name}.rb", src)
      end
      scripts_list += name
      scripts_list += "\n" unless idx == scripts.length - 1
    end
    File.write("#{@text_dir}/scripts/scriptslist.txt", scripts_list)
    nil
  end
  
  def to_bin
    unless Dir.exist?("#{@text_dir}/scripts")
      raise ConvertException.new("#{@text_dir}/scriptsが存在しません")
    end
    scripts = []
    unless File.exist?("#{@text_dir}/scripts/scriptslist.txt")
      raise ConvertException.new("#{@text_dir}/scripts/scriptslist.txtが存在しません")
    end
    scripts_list = File.read("#{@text_dir}/scripts/scriptslist.txt", encoding: "UTF-8")
    scripts_list.each_line.with_index do |name, idx|
      scripts << []
      name.chomp!
      scripts[idx] << idx << name
      if file_name_judge(name)
        unless File.exist?("#{@text_dir}/scripts/src/#{name}.rb")
          raise ConvertException.new("#{@text_dir}/scripts/src/#{name}.rbが存在しません")
        end
        src = File.binread("#{@text_dir}/scripts/src/#{name}.rb")
        bin = Zlib::Deflate.deflate(src)
        scripts[idx] << bin
      else
        bin = Zlib::Deflate.deflate("")
        scripts[idx] << bin
      end
    end
    scripts << [0, "", Zlib::Deflate.deflate("")]
    File.binwrite("#{@bin_dir}/Scripts.#{@ext}", Marshal.dump(scripts))
    nil
  end
  
  private
  
  def file_name_judge(file_name)
    if file_name =~ /^▼/ ||
       file_name =~ /^\s*$/
        return false
    end
    true
  end
end
