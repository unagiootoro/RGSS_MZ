#==============================================================================
# ■ Main
#------------------------------------------------------------------------------
# 　各クラスの定義が終わった後、ここから実際の処理が始まります。
#==============================================================================

# begin
#   # トランジション準備
#   Graphics.freeze
#   # シーンオブジェクト (タイトル画面) を作成
#   $scene = Scene_Title.new
#   # $scene が有効な限り main メソッドを呼び出す
#   while $scene != nil
#     $scene.main
#   end
#   # フェードアウト
#   Graphics.transition(20)
# rescue Errno::ENOENT
#   # 例外 Errno::ENOENT を補足
#   # ファイルがオープンできなかった場合、メッセージを表示して終了する
#   filename = $!.message.sub("No such file or directory - ", "")
#   print("ファイル #{filename} が見つかりません。")
# end

module Kernel
  if RUBY_ENGINE == "opal"
    def load_data(path)
      file = RGSSEnv.file_read(path)
      obj = JSON.parse(file)
      if obj.is_a?(Array)
        obj3 = obj.map do |val|
          if val
            if val.is_a?(Hash)
              cls = Kernel.const_get(val["class_name"])
              obj2 = cls.allocate
              obj2.rpg_hash_load(val)
              obj2
            else
              val
            end
          else
            nil
          end
        end
      else
        cls = Kernel.const_get(obj["class_name"])
        obj2 = cls.allocate
        obj2.rpg_hash_load(obj)
        obj3 = obj2
      end
      obj3
    end
  elsif RUBY_ENGINE == "mruby"
    def load_data(path)
      if RGSS_ENABLE_MARSHAL
        if RGSS_MODE == :client
          file = RGSSEnv.file_read("rgss/" + path)
        else
          file = File.read(path)
        end
        Marshal.load(file)
      else
        if RGSS_MODE == :client
          file = RGSSEnv.file_read(path)
        else
          file = File.read("../" + path)
        end
        obj = JSON.parse(file)
        if obj.is_a?(Array)
          obj3 = obj.map do |val|
            if val
              if val.is_a?(Hash)
                cls = Kernel.const_get(val["class_name"])
                obj2 = cls.allocate
                obj2.rpg_hash_load(val)
                obj2
              else
                val
              end
            else
              nil
            end
          end
        else
          cls = Kernel.const_get(obj["class_name"])
          obj2 = cls.allocate
          obj2.rpg_hash_load(obj)
          obj3 = obj2
        end
        obj3
      end
    end
  else
    def load_data(path)
      file = File.binread(path)
      Marshal.load(file)
    end
  end
end

# # トランジション準備
# Graphics.freeze
# # シーンオブジェクト (タイトル画面) を作成
# $scene = Scene_Title.new
# # $scene が有効な限り main メソッドを呼び出す
# while $scene != nil
#   $scene.main
# end
# # フェードアウト
# Graphics.transition(20)

# class Cls
#   def initialize(val)
#     @val = val
#   end

#   def val
#     @val
#   end
# end

# obj = Cls.new(100)
# obj = "test"
# bin = Marshal.dump(obj)
# obj2 = Marshal.load(bin)
# p obj2

module RGSSMain
  def self.init_rgss
    $main_fiber = Fiber.new do
      # トランジション準備
      Graphics.freeze
      # シーンオブジェクト (タイトル画面) を作成
      $scene = Scene_Title.new
      # $scene が有効な限り main メソッドを呼び出す
      while $scene != nil
        $scene.main
      end
      # フェードアウト
      Graphics.transition(20)
    end
  end

  def self.update_rgss
    $main_fiber.resume
  end
end

if RGSS_MODE == :server
  RGSSMain.init_rgss
  loop do
    RGSSMain.update_rgss
  end
end
