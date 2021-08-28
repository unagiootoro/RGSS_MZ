#==============================================================================
# ■ Window_NameInput
#------------------------------------------------------------------------------
# 　名前入力画面で、文字を選択するウィンドウです。
#==============================================================================

class Window_NameInput < Window_Base
  CHARACTER_TABLE =
  [
    "あ","い","う","え","お",
    "か","き","く","け","こ",
    "さ","し","す","せ","そ",
    "た","ち","つ","て","と",
    "な","に","ぬ","ね","の",
    "は","ひ","ふ","へ","ほ",
    "ま","み","む","め","も",
    "や", "" ,"ゆ", "" ,"よ",
    "ら","り","る","れ","ろ",
    "わ", "" ,"を", "" ,"ん",
    "が","ぎ","ぐ","げ","ご",
    "ざ","じ","ず","ぜ","ぞ",
    "だ","ぢ","づ","で","ど",
    "ば","び","ぶ","べ","ぼ",
    "ぱ","ぴ","ぷ","ぺ","ぽ",
    "ゃ","ゅ","ょ","っ","ゎ",
    "ぁ","ぃ","ぅ","ぇ","ぉ",
    "ー","・", "" , "" , "" ,
    "ア","イ","ウ","エ","オ",
    "カ","キ","ク","ケ","コ",
    "サ","シ","ス","セ","ソ",
    "タ","チ","ツ","テ","ト",
    "ナ","ニ","ヌ","ネ","ノ",
    "ハ","ヒ","フ","ヘ","ホ",
    "マ","ミ","ム","メ","モ",
    "ヤ", "" ,"ユ", "" ,"ヨ",
    "ラ","リ","ル","レ","ロ",
    "ワ", "" ,"ヲ", "" ,"ン",
    "ガ","ギ","グ","ゲ","ゴ",
    "ザ","ジ","ズ","ゼ","ゾ",
    "ダ","ヂ","ヅ","デ","ド",
    "バ","ビ","ブ","ベ","ボ",
    "パ","ピ","プ","ペ","ポ",
    "ャ","ュ","ョ","ッ","ヮ",
    "ァ","ィ","ゥ","ェ","ォ",
    "ー","・","ヴ", "" , "" ,
  ]
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 128, 640, 352)
    self.contents = Bitmap.new(width - 32, height - 32)
    @index = 0
    refresh
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● 文字の取得
  #--------------------------------------------------------------------------
  def character
    return CHARACTER_TABLE[@index]
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0..179
      x = 4 + i / 5 / 9 * 152 + i % 5 * 28
      y = i / 5 % 9 * 32
      self.contents.draw_text(x, y, 28, 32, CHARACTER_TABLE[i], 1)
    end
    self.contents.draw_text(544, 9 * 32, 64, 32, "決定", 1)
  end
  #--------------------------------------------------------------------------
  # ● カーソルの矩形更新
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # カーソル位置が [決定] の場合
    if @index >= 180
      self.cursor_rect.set(544, 9 * 32, 64, 32)
    # カーソル位置が [決定] 以外の場合
    else
      x = 4 + @index / 5 / 9 * 152 + @index % 5 * 28
      y = @index / 5 % 9 * 32
      self.cursor_rect.set(x, y, 28, 32)
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # カーソル位置が [決定] の場合
    if @index >= 180
      # カーソル下
      if Input.trigger?(Input::DOWN)
        $game_system.se_play($data_system.cursor_se)
        @index -= 180
      end
      # カーソル上
      if Input.repeat?(Input::UP)
        $game_system.se_play($data_system.cursor_se)
        @index -= 180 - 40
      end
    # カーソル位置が [決定] 以外の場合
    else
      # 方向ボタンの右が押された場合
      if Input.repeat?(Input::RIGHT)
        # 押下状態がリピートでない場合か、
        # カーソル位置が右端ではない場合
        if Input.trigger?(Input::RIGHT) or
           @index / 45 < 3 or @index % 5 < 4
          # カーソルを右に移動
          $game_system.se_play($data_system.cursor_se)
          if @index % 5 < 4
            @index += 1
          else
            @index += 45 - 4
          end
          if @index >= 180
            @index -= 180
          end
        end
      end
      # 方向ボタンの左が押された場合
      if Input.repeat?(Input::LEFT)
        # 押下状態がリピートでない場合か、
        # カーソル位置が左端ではない場合
        if Input.trigger?(Input::LEFT) or
           @index / 45 > 0 or @index % 5 > 0
          # カーソルを左に移動
          $game_system.se_play($data_system.cursor_se)
          if @index % 5 > 0
            @index -= 1
          else
            @index -= 45 - 4
          end
          if @index < 0
            @index += 180
          end
        end
      end
      # 方向ボタンの下が押された場合
      if Input.repeat?(Input::DOWN)
        # カーソルを下に移動
        $game_system.se_play($data_system.cursor_se)
        if @index % 45 < 40
          @index += 5
        else
          @index += 180 - 40
        end
      end
      # 方向ボタンの上が押された場合
      if Input.repeat?(Input::UP)
        # 押下状態がリピートでない場合か、
        # カーソル位置が上端ではない場合
        if Input.trigger?(Input::UP) or @index % 45 >= 5
          # カーソルを上に移動
          $game_system.se_play($data_system.cursor_se)
          if @index % 45 >= 5
            @index -= 5
          else
            @index += 180
          end
        end
      end
      # L ボタンか R ボタンが押された場合
      if Input.repeat?(Input::L) or Input.repeat?(Input::R)
        # ひらがな / カタカナ 移動
        $game_system.se_play($data_system.cursor_se)
        if @index / 45 < 2
          @index += 90
        else
          @index -= 90
        end
      end
    end
    update_cursor_rect
  end
end
