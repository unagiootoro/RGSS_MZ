#==============================================================================
# ■ Window_NameEdit
#------------------------------------------------------------------------------
# 　名前入力画面で、名前を編集するウィンドウです。
#==============================================================================

class Window_NameEdit < Window_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :name                     # 名前
  attr_reader   :index                    # カーソル位置
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor    : アクター
  #     max_char : 最大文字数
  #--------------------------------------------------------------------------
  def initialize(actor, max_char)
    super(0, 0, 640, 128)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    @name = actor.name
    @max_char = max_char
    # 名前を最大文字数以内に収める
    name_array = @name.split(//)[0...@max_char]
    @name = ""
    for i in 0...name_array.size
      @name += name_array[i]
    end
    @default_name = @name
    @index = name_array.size
    refresh
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● デフォルトの名前に戻す
  #--------------------------------------------------------------------------
  def restore_default
    @name = @default_name
    @index = @name.split(//).size
    refresh
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● 文字の追加
  #     character : 追加する文字
  #--------------------------------------------------------------------------
  def add(character)
    if @index < @max_char and character != ""
      @name += character
      @index += 1
      refresh
      update_cursor_rect
    end
  end
  #--------------------------------------------------------------------------
  # ● 文字の削除
  #--------------------------------------------------------------------------
  def back
    if @index > 0
      # 一字削除
      name_array = @name.split(//)
      @name = ""
      for i in 0...name_array.size-1
        @name += name_array[i]
      end
      @index -= 1
      refresh
      update_cursor_rect
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    # 名前を描画
    name_array = @name.split(//)
    for i in 0...@max_char
      c = name_array[i]
      if c == nil
        c = "＿"
      end
      x = 320 - @max_char * 14 + i * 28
      self.contents.draw_text(x, 32, 28, 32, c, 1)
    end
    # グラフィックを描画
    draw_actor_graphic(@actor, 320 - @max_char * 14 - 40, 80)
  end
  #--------------------------------------------------------------------------
  # ● カーソルの矩形更新
  #--------------------------------------------------------------------------
  def update_cursor_rect
    x = 320 - @max_char * 14 + @index * 28
    self.cursor_rect.set(x, 32, 28, 32)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_cursor_rect
  end
end
