#==============================================================================
# ■ Window_Command
#------------------------------------------------------------------------------
# 　一般的なコマンド選択を行うウィンドウです。
#==============================================================================

class Window_Command < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     width    : ウィンドウの幅
  #     commands : コマンド文字列の配列
  #--------------------------------------------------------------------------
  def initialize(width, commands)
    # コマンドの個数からウィンドウの高さを算出
    super(0, 0, width, commands.size * 32 + 32)
    @item_max = commands.size
    @commands = commands
    self.contents = Bitmap.new(width - 32, @item_max * 32)
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, normal_color)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #     index : 項目番号
  #     color : 文字色
  #--------------------------------------------------------------------------
  def draw_item(index, color)
    self.contents.font.color = color
    rect = Rect.new(4, 32 * index, self.contents.width - 8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index])
  end
  #--------------------------------------------------------------------------
  # ● 項目の無効化
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def disable_item(index)
    draw_item(index, disabled_color)
  end
end
