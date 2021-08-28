#==============================================================================
# ■ Window_InputNumber
#------------------------------------------------------------------------------
# 　メッセージウィンドウの内部で使用する、数値入力用のウィンドウです。
#==============================================================================

class Window_InputNumber < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     digits_max : 桁数
  #--------------------------------------------------------------------------
  def initialize(digits_max)
    @digits_max = digits_max
    @number = 0
    # 数字の幅からカーソルの幅を計算 (0～9 は等幅と仮定)
    dummy_bitmap = Bitmap.new(32, 32)
    @cursor_width = dummy_bitmap.text_size("0").width + 8
    dummy_bitmap.dispose
    super(0, 0, @cursor_width * @digits_max + 32, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.z += 9999
    self.opacity = 0
    @index = 0
    refresh
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● 数値の取得
  #--------------------------------------------------------------------------
  def number
    return @number
  end
  #--------------------------------------------------------------------------
  # ● 数値の設定
  #     number : 新しい数値
  #--------------------------------------------------------------------------
  def number=(number)
    @number = [[number, 0].max, 10 ** @digits_max - 1].min
    refresh
  end
  #--------------------------------------------------------------------------
  # ● カーソルの矩形更新
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(@index * @cursor_width, 0, @cursor_width, 32)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # 方向ボタンの上か下が押された場合
    if Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN)
      $game_system.se_play($data_system.cursor_se)
      # 現在の位の数字を取得し、いったん 0 にする
      place = 10 ** (@digits_max - 1 - @index)
      n = @number / place % 10
      @number -= n * place
      # 上なら +1、下なら -1
      n = (n + 1) % 10 if Input.repeat?(Input::UP)
      n = (n + 9) % 10 if Input.repeat?(Input::DOWN)
      # 現在の位の数字を再設定
      @number += n * place
      refresh
    end
    # カーソル右
    if Input.repeat?(Input::RIGHT)
      if @digits_max >= 2
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + 1) % @digits_max
      end
    end
    # カーソル左
    if Input.repeat?(Input::LEFT)
      if @digits_max >= 2
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + @digits_max - 1) % @digits_max
      end
    end
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    s = sprintf("%0*d", @digits_max, @number)
    for i in 0...@digits_max
      self.contents.draw_text(i * @cursor_width + 4, 0, 32, 32, s[i,1])
    end
  end
end
