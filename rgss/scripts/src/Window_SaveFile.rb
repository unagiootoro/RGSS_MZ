#==============================================================================
# ■ Window_SaveFile
#------------------------------------------------------------------------------
# 　セーブ画面およびロード画面で表示する、セーブファイルのウィンドウです。
#==============================================================================

class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :filename                 # ファイル名
  attr_reader   :selected                 # 選択状態
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     file_index : セーブファイルのインデックス (0～3)
  #     filename   : ファイル名
  #--------------------------------------------------------------------------
  def initialize(file_index, filename)
    super(0, 64 + file_index % 4 * 104, 640, 104)
    self.contents = Bitmap.new(width - 32, height - 32)
    @file_index = file_index
    @filename = "Save#{@file_index + 1}.rxdata"
    @time_stamp = Time.at(0)
    @file_exist = FileTest.exist?(@filename)
    if @file_exist
      file = File.open(@filename, "r")
      @time_stamp = file.mtime
      @characters = Marshal.load(file)
      @frame_count = Marshal.load(file)
      @game_system = Marshal.load(file)
      @game_switches = Marshal.load(file)
      @game_variables = Marshal.load(file)
      @total_sec = @frame_count / Graphics.frame_rate
      file.close
    end
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    # ファイル番号を描画
    self.contents.font.color = normal_color
    name = "ファイル #{@file_index + 1}"
    self.contents.draw_text(4, 0, 600, 32, name)
    @name_width = contents.text_size(name).width
    # セーブファイルが存在する場合
    if @file_exist
      # キャラクターを描画
      for i in 0...@characters.size
        bitmap = RPG::Cache.character(@characters[i][0], @characters[i][1])
        cw = bitmap.rect.width / 4
        ch = bitmap.rect.height / 4
        src_rect = Rect.new(0, 0, cw, ch)
        x = 300 - @characters.size * 32 + i * 64 - cw / 2
        self.contents.blt(x, 68 - ch, bitmap, src_rect)
      end
      # プレイ時間を描画
      hour = @total_sec / 60 / 60
      min = @total_sec / 60 % 60
      sec = @total_sec % 60
      time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 8, 600, 32, time_string, 2)
      # タイムスタンプを描画
      self.contents.font.color = normal_color
      time_string = @time_stamp.strftime("%Y/%m/%d %H:%M")
      self.contents.draw_text(4, 40, 600, 32, time_string, 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 選択状態の設定
  #     selected : 新しい選択状態 (true=選択 false=非選択)
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● カーソルの矩形更新
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @selected
      self.cursor_rect.set(0, 0, @name_width + 8, 32)
    else
      self.cursor_rect.empty
    end
  end
end
